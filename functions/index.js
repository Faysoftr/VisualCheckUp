const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

admin.initializeApp();

// ── VisualCheckUp Cloudflare R2 Configuration ──────────────────────────────
const R2_ACCOUNT_ID = process.env.R2_ACCOUNT_ID;
const R2_ACCESS_KEY_ID = process.env.R2_ACCESS_KEY_ID;
const R2_SECRET_ACCESS_KEY = process.env.R2_SECRET_ACCESS_KEY;
const R2_BUCKET = process.env.R2_BUCKET || 'visualcheckup-images';
const R2_PUBLIC_BASE_URL = process.env.R2_PUBLIC_BASE_URL;

const ALLOWED_FOLDERS = new Set([
  'community_avatars',
  'community_chat',
  'doctor_docs',
]);
const VISION_API_KEY = process.env.VISION_API_KEY || '';
const HIGH_RISK_LEVELS = new Set(['LIKELY', 'VERY_LIKELY']);
const MAX_UPLOAD_BYTES = 1 * 1024 * 1024; // 1 MB
const RATE_WINDOW_MS = 2 * 60 * 1000;     // 2 minutes
const MAX_UPLOADS_PER_WINDOW = 5;

const R2_CONFIGURED = Boolean(
  R2_ACCOUNT_ID && R2_ACCESS_KEY_ID && R2_SECRET_ACCESS_KEY && R2_PUBLIC_BASE_URL
);

const r2 = R2_CONFIGURED
  ? new S3Client({
      region: 'auto',
      endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: R2_ACCESS_KEY_ID,
        secretAccessKey: R2_SECRET_ACCESS_KEY,
      },
    })
  : null;

async function destroyR2Object(key) {
  if (!key || !r2) return;
  try {
    await r2.send(new DeleteObjectCommand({ Bucket: R2_BUCKET, Key: key }));
  } catch (e) {
    console.error('VisualCheckUp R2 delete error:', key, e);
  }
}

/**
 * Generates a short-lived presigned PUT URL so the VisualCheckUp app uploads
 * compressed profile avatars, chat images & doctor verification docs directly
 * to Cloudflare R2 with zero client-side secrets.
 */
exports.getR2UploadUrl = functions.region('europe-west1').https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required to upload images.'
    );
  }
  if (!r2) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Image upload storage is not configured on the server.'
    );
  }

  const uid = context.auth.uid;
  const contentType = (data && data.contentType) || 'image/jpeg';
  const sizeBytes = Number(data && data.sizeBytes) || 0;

  if (sizeBytes <= 0 || sizeBytes > MAX_UPLOAD_BYTES) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Image must be between 1 byte and 1 MB.'
    );
  }

  // Server-side upload rate limit
  try {
    const eventsRef = admin
      .firestore()
      .collection('community_safety')
      .doc(uid)
      .collection('upload_events');
    const since = new Date(Date.now() - RATE_WINDOW_MS);
    const recent = await eventsRef.where('timestamp', '>', since).get();
    if (recent.size >= MAX_UPLOADS_PER_WINDOW) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Upload rate limit reached. Please wait a couple of minutes.'
      );
    }
    await eventsRef.add({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    console.error('Upload rate-limit check warning:', e);
  }

  const rawFolder = (data && typeof data.folder === 'string') ? data.folder : 'community_chat';
  const folder = ALLOWED_FOLDERS.has(rawFolder) ? rawFolder : 'community_chat';
  const ext = contentType.includes('png')
    ? 'png'
    : contentType.includes('webp')
      ? 'webp'
      : 'jpg';
  const rand = Math.random().toString(36).substring(2, 10);
  const key = `${folder}/${uid}/${Date.now()}_${rand}.${ext}`;

  const putCmd = new PutObjectCommand({
    Bucket: R2_BUCKET,
    Key: key,
    ContentType: contentType,
  });
  const uploadUrl = await getSignedUrl(r2, putCmd, { expiresIn: 120 });
  const publicUrl = `${R2_PUBLIC_BASE_URL.replace(/\/$/, '')}/${key}`;

  return { uploadUrl, publicUrl, key };
});

/**
 * Moderates an uploaded community image via Google Cloud Vision SafeSearch
 * (adult / violence / racy). Automatically deletes unsafe images from R2.
 */
exports.moderateCommunityImage = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Auth required.');
    }
    const imageUrl = data && typeof data.imageUrl === 'string' ? data.imageUrl.trim() : '';
    const objectKey = data && typeof data.objectKey === 'string' ? data.objectKey.trim() : '';
    if (!imageUrl || !VISION_API_KEY) {
      return { safe: true, skipped: !VISION_API_KEY };
    }

    try {
      const endpoint = `https://vision.googleapis.com/v1/images:annotate?key=${encodeURIComponent(VISION_API_KEY)}`;
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          requests: [
            {
              image: { source: { imageUri: imageUrl } },
              features: [{ type: 'SAFE_SEARCH_DETECTION' }],
            },
          ],
        }),
      });
      const json = await res.json();
      const annotation =
        json && json.responses && json.responses[0] && json.responses[0].safeSearchAnnotation;
      if (!annotation) return { safe: true };

      const adult = annotation.adult || 'UNKNOWN';
      const violence = annotation.violence || 'UNKNOWN';
      const racy = annotation.racy || 'UNKNOWN';
      if (HIGH_RISK_LEVELS.has(adult) || HIGH_RISK_LEVELS.has(violence) || racy === 'VERY_LIKELY') {
        const callerUid = context.auth.uid;
        const isOwnedKey =
          Boolean(objectKey) &&
          !objectKey.includes('..') &&
          Array.from(ALLOWED_FOLDERS).some((folder) =>
            objectKey.startsWith(`${folder}/${callerUid}/`),
          );
        if (isOwnedKey) {
          await destroyR2Object(objectKey);
        } else if (objectKey) {
          console.warn(
            `Blocked unauthorized R2 delete attempt by uid=${callerUid} for key=${objectKey}`,
          );
        }
        return {
          safe: false,
          reason: `SafeSearch violation (adult=${adult}, violence=${violence}, racy=${racy})`,
        };
      }
      return { safe: true };
    } catch (err) {
      console.error('SafeSearch moderation warning:', err);
      return { safe: true };
    }
  });

/**
 * Automatically suspends a community profile if 3+ distinct users report it.
 */
exports.onCommunityReportCreated = functions
  .region('europe-west1')
  .firestore.document('community_reports/{reportId}')
  .onCreate(async (snap) => {
    const data = snap.data() || {};
    if (data.targetType !== 'profile' || !data.targetId) return null;

    const targetUid = data.targetId;
    const reportsSnap = await admin
      .firestore()
      .collection('community_reports')
      .where('targetType', '==', 'profile')
      .where('targetId', '==', targetUid)
      .get();

    const uniqueReporters = new Set();
    reportsSnap.forEach((doc) => {
      const r = doc.data() || {};
      if (r.reporterId) uniqueReporters.add(r.reporterId);
    });

    if (uniqueReporters.size >= 3) {
      await admin
        .firestore()
        .collection('community_profiles')
        .doc(targetUid)
        .set(
          {
            isSuspended: true,
            moderationStatus: 'auto_hidden_by_reports',
            updatedAt: new Date().toISOString(),
          },
          { merge: true }
        );
    }
    return null;
  });

/** Deletes profile avatar object from R2 when a user leaves the community. */
exports.cleanupCommunityProfileImage = functions
  .region('europe-west1')
  .firestore.document('community_profiles/{uid}')
  .onDelete(async (snap) => {
    const data = snap.data() || {};
    if (data.photoKey) {
      await destroyR2Object(data.photoKey);
    }
    return null;
  });

/** Deletes chat image attachment from R2 when a message is deleted for everyone. */
exports.cleanupCommunityMessageImage = functions
  .region('europe-west1')
  .firestore.document('community_conversations/{chatId}/messages/{messageId}')
  .onDelete(async (snap) => {
    const data = snap.data() || {};
    if (data.imageKey) {
      await destroyR2Object(data.imageKey);
    }
    return null;
  });

/**
 * Broadcasts an admin push notification queued in `admin_push_queue` via FCM
 * to topic `vc_all` (or `vc_lang_{lang}` when a language is targeted).
 */
exports.onAdminPushQueued = functions
  .region('europe-west1')
  .firestore.document('admin_push_queue/{pushId}')
  .onCreate(async (snap) => {
    const data = snap.data() || {};
    const title = String(data.title || '').slice(0, 100);
    const body = String(data.body || '').slice(0, 300);
    if (!title || !body) {
      await snap.ref.set({ status: 'invalid' }, { merge: true });
      return null;
    }
    const lang = String(data.targetLanguage || '').toLowerCase();
    const topic = /^[a-z]{2}$/.test(lang) ? `vc_lang_${lang}` : 'vc_all';
    try {
      await admin.messaging().send({
        topic,
        notification: { title, body },
        data: { type: 'admin_push' },
      });
      await snap.ref.set(
        { status: 'sent', topic, sentAt: new Date().toISOString() },
        { merge: true }
      );
    } catch (e) {
      await snap.ref.set({ status: 'failed', error: String(e) }, { merge: true });
    }
    return null;
  });

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const ALLOWED_GEMINI_MODELS = new Set([
  'gemini-2.5-flash',
  'gemini-2.5-flash-lite',
]);

/**
 * Server-side Gemini Vision proxy so GEMINI_API_KEY stays strictly in
 * Cloud Functions environment variables (`process.env.GEMINI_API_KEY`) and
 * never needs to be embedded in client APK/IPA binaries.
 */
exports.analyzeVisualHealth = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Authentication required for cloud visual analysis.'
      );
    }
    if (!GEMINI_API_KEY) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Server Gemini Vision API key is not configured.'
      );
    }

    const imageBase64 = String((data && data.imageBase64) || '');
    const mimeType = String((data && data.mimeType) || 'image/jpeg');
    const systemInstruction = String((data && data.systemInstruction) || '');
    const userPrompt = String((data && data.userPrompt) || '');
    const maxOutputTokens = Math.min(
      Math.max(Number(data && data.maxOutputTokens) || 400, 64),
      1024
    );
    const requestedModel = String((data && data.model) || 'gemini-2.5-flash-lite');
    const model = ALLOWED_GEMINI_MODELS.has(requestedModel)
      ? requestedModel
      : 'gemini-2.5-flash-lite';

    if (!imageBase64 || imageBase64.length > 2 * 1024 * 1024) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Invalid or oversized image payload.'
      );
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
    const payload = {
      ...(systemInstruction
        ? { systemInstruction: { parts: [{ text: systemInstruction }] } }
        : {}),
      contents: [
        {
          role: 'user',
          parts: [
            { inlineData: { mimeType, data: imageBase64 } },
            { text: userPrompt },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.2,
        maxOutputTokens,
        responseMimeType: 'application/json',
      },
    };

    const resp = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': GEMINI_API_KEY,
      },
      body: JSON.stringify(payload),
    });

    if (!resp.ok) {
      const errBody = await resp.text();
      console.error('Gemini Vision upstream HTTP error:', resp.status, errBody);
      throw new functions.https.HttpsError(
        'internal',
        `Gemini Vision HTTP ${resp.status}`
      );
    }

    const json = await resp.json();
    const text =
      json &&
      json.candidates &&
      json.candidates[0] &&
      json.candidates[0].content &&
      json.candidates[0].content.parts &&
      json.candidates[0].content.parts[0] &&
      json.candidates[0].content.parts[0].text;

    if (!text || !String(text).trim()) {
      throw new functions.https.HttpsError(
        'internal',
        'Gemini Vision returned empty content.'
      );
    }

    return { text: String(text) };
  });

