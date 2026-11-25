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

const ALLOWED_FOLDERS = new Set(['community_avatars', 'community_chat']);
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
 * compressed profile avatars & chat images directly to Cloudflare R2 with
 * zero client-side secrets.
 */
exports.getR2UploadUrl = functions.https.onCall(async (data, context) => {
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

/** Deletes profile avatar object from R2 when a user leaves the community. */
exports.cleanupCommunityProfileImage = functions.firestore
  .document('community_profiles/{uid}')
  .onDelete(async (snap) => {
    const data = snap.data() || {};
    if (data.photoKey) {
      await destroyR2Object(data.photoKey);
    }
    return null;
  });

/** Deletes chat image attachment from R2 when a message is deleted for everyone. */
exports.cleanupCommunityMessageImage = functions.firestore
  .document('community_conversations/{chatId}/messages/{messageId}')
  .onDelete(async (snap) => {
    const data = snap.data() || {};
    if (data.imageKey) {
      await destroyR2Object(data.imageKey);
    }
    return null;
  });
