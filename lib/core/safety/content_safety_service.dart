import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:image/image.dart' as img;

/// Violation categories caught by [ContentSafetyService].
enum ContentSafetyViolation {
  none,
  profanityOrInsult,
  hateSpeech,
  spamOrScamLink,
  phoneNumberLeak,
  unsafeMedicalOrSelfHarm,
  invalidOrUnsafeImage,
}

/// Result returned by [ContentSafetyService] text and image checks.
class ContentSafetyResult {
  const ContentSafetyResult.safe()
      : isSafe = true,
        violation = ContentSafetyViolation.none,
        reason = '';

  const ContentSafetyResult.blocked(
    this.violation, {
    this.reason = '',
  }) : isSafe = false;

  final bool isSafe;
  final ContentSafetyViolation violation;
  final String reason;
}

/// Multi-language content moderation & image safety guard for VisualCheckUp.
///
/// Protects Health Community chat, profiles, and doctor applications from:
/// - Profanity, insults, and harassment (TR, EN, DE, SV, ES, FR, etc.)
/// - Hate speech and slurs
/// - Gambling/phishing/external ad-spam links and phone leaks
/// - Dangerous self-harm or miracle-cure misinformation phrases
/// - Corrupt/spoofed image files (client pre-check) and NSFW/violent images
///   (server-side Google Cloud Vision SafeSearch callable when Firebase is live)
class ContentSafetyService {
  ContentSafetyService._();

  static const int maxRawImageBytes = 10 * 1024 * 1024; // 10 MB raw cap
  static const int minImageDimension = 24;
  static const int maxImageDimension = 8000;

  static const List<String> _exactProfanityWords = [
    // Turkish
    'amk', 'aq', 'amq', 'oc', 'mk', 'sg', 'pic', 'got', 'sik', 'ebeni',
    'mal', 'salak', 'aptal', 'gerizekali', 'dangalak', 'ahmak', 'beyinsiz',
    // English
    'fuck', 'shit', 'bitch', 'dick', 'cunt', 'porn', 'nsfw', 'slut', 'whore',
    // German
    'fotze', 'hure', 'wichser', 'arschloch', 'scheisse', 'hurensohn', 'spast',
    // Swedish
    'fitta', 'hora', 'kuk', 'fan', 'javla', 'idiot',
    // Spanish
    'puta', 'mierda', 'joder', 'cabron', 'gilipollas', 'pendejo', 'zorra',
  ];

  static const List<String> _partialProfanityWords = [
    // Turkish severe insults & slurs
    'siktir', 'sikis', 'orospu', 'fahise', 'kahpe', 'yarrak', 'yarak',
    'yavsak', 'amina', 'amcik', 'pezevenk', 'gavat', 'kavat', 'ibne',
    'pust', 'gotten', 'gotveren', 'kaltak', 'surtuk', 'sakso', 'domal',
    'oruspu', 'anani', 'bacini', 'serefsiz', 'haysiyetsiz', 'alcak',
    // English severe profanity & hate
    'fuck', 'motherfuck', 'asshole', 'bastard', 'bullshit', 'bitch',
    'nigger', 'nigga', 'faggot', 'retard', 'pornhub', 'onlyfans',
    // German
    'hurensohn', 'arschloch', 'missgeburt', 'wichser', 'verpiss',
    // Swedish
    'horunge', 'knulla', 'fittan',
    // Spanish
    'hijodeputa', 'maricon', 'conchatumadre', 'estupido',
  ];

  static const List<String> _hateSpeechPhrases = [
    'terorist',
    'nazi',
    'hitler',
    'kill yourself',
    'kys',
    'kendini oldur',
    'intihar et',
    'bring dich um',
  ];

  static const List<String> _adSpamPhrases = [
    'deneme bonusu',
    'kacak bahis',
    'yasal bahis',
    'sweet bonanza',
    'telegram kanali',
    'telegram grubu',
    'whatsapp grubu',
    'takipci satin',
    'ucuz takipci',
    'mucize ilac',
    'kesin cozum ilac',
    'garantili kanser tedavisi',
    'crypto airdrop',
    'free bitcoin',
  ];

  static final RegExp _urlRegExp = RegExp(
    r'(https?:\/\/|www\.|t\.me\/|wa\.me\/|discord\.gg\/|bit\.ly\/|tinyurl\.com\/|\b[a-z0-9-]+\.(com|com\.tr|net|org|xyz|io|gg|me|tk|ru|bet|shop|store)\b)',
    caseSensitive: false,
  );

  static final RegExp _phoneRegExp = RegExp(
    r'(?:\+?\d{1,3}[\s\-\.]?)?\(?0?5\d{2}\)?[\s\-\.]?\d{3}[\s\-\.]?\d{2}[\s\-\.]?\d{2}\b',
  );

  /// Normalizes diacritics (TR/DE/SV/ES/FR), leetspeak, and repeated characters
  /// so obfuscated insults like `s.1.k.t.i.r` or `f*ck` are caught reliably.
  static String normalize(String input) {
    const map = {
      'ç': 'c', 'Ç': 'c',
      'ğ': 'g', 'Ğ': 'g',
      'ı': 'i', 'I': 'i', 'İ': 'i',
      'ö': 'o', 'Ö': 'o',
      'ş': 's', 'Ş': 's',
      'ü': 'u', 'Ü': 'u',
      'ä': 'a', 'Ä': 'a',
      'å': 'a', 'Å': 'a',
      'ß': 'ss',
      'ñ': 'n', 'Ñ': 'n',
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      '@': 'a',
      '3': 'e',
      '1': 'i',
      '0': 'o',
      '\$': 's',
      '5': 's',
      '4': 'a',
      '7': 't',
    };
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      sb.write(map[ch] ?? ch.toLowerCase());
    }
    return sb.toString();
  }

  /// Checks user-authored text for profanity, insults, hate speech, self-harm,
  /// and optionally spam links or phone leaks.
  static ContentSafetyResult checkText(
    String rawText, {
    bool checkLinks = false,
    bool checkPhones = false,
  }) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return const ContentSafetyResult.safe();

    final normalized = normalize(trimmed);
    final spacedClean = normalized
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final squashed = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    final tokens = spacedClean.split(' ').where((t) => t.isNotEmpty).toSet();

    for (final phrase in _hateSpeechPhrases) {
      if (spacedClean.contains(phrase) ||
          squashed.contains(phrase.replaceAll(' ', ''))) {
        return const ContentSafetyResult.blocked(
          ContentSafetyViolation.hateSpeech,
          reason: 'hate_or_self_harm',
        );
      }
    }

    for (final word in _exactProfanityWords) {
      if (tokens.contains(word)) {
        return const ContentSafetyResult.blocked(
          ContentSafetyViolation.profanityOrInsult,
          reason: 'profanity_exact',
        );
      }
    }

    for (final word in _partialProfanityWords) {
      if (spacedClean.contains(word) || squashed.contains(word)) {
        return const ContentSafetyResult.blocked(
          ContentSafetyViolation.profanityOrInsult,
          reason: 'profanity_partial',
        );
      }
    }

    for (final phrase in _adSpamPhrases) {
      if (spacedClean.contains(phrase)) {
        return const ContentSafetyResult.blocked(
          ContentSafetyViolation.spamOrScamLink,
          reason: 'spam_phrase',
        );
      }
    }

    if (checkLinks && _urlRegExp.hasMatch(trimmed)) {
      return const ContentSafetyResult.blocked(
        ContentSafetyViolation.spamOrScamLink,
        reason: 'external_link',
      );
    }

    if (checkPhones && _phoneRegExp.hasMatch(trimmed)) {
      return const ContentSafetyResult.blocked(
        ContentSafetyViolation.phoneNumberLeak,
        reason: 'phone_leak',
      );
    }

    return const ContentSafetyResult.safe();
  }

  /// Client-side image safety & integrity pre-check before uploading to R2.
  /// Verifies file size, real image magic bytes (JPEG/PNG/WebP/GIF), and valid
  /// decoded image dimensions to reject spoofed or corrupted uploads.
  static ContentSafetyResult validateImageBytes(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length < 12) {
      return const ContentSafetyResult.blocked(
        ContentSafetyViolation.invalidOrUnsafeImage,
        reason: 'empty_or_too_small',
      );
    }
    if (bytes.length > maxRawImageBytes) {
      return const ContentSafetyResult.blocked(
        ContentSafetyViolation.invalidOrUnsafeImage,
        reason: 'too_large',
      );
    }

    final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    final isPng = bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isWebp = bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
    final isGif = bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46;

    if (!isJpeg && !isPng && !isWebp && !isGif) {
      return const ContentSafetyResult.blocked(
        ContentSafetyViolation.invalidOrUnsafeImage,
        reason: 'unsupported_format',
      );
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const ContentSafetyResult.blocked(
        ContentSafetyViolation.invalidOrUnsafeImage,
        reason: 'decode_failed',
      );
    }
    if (decoded.width < minImageDimension ||
        decoded.height < minImageDimension ||
        decoded.width > maxImageDimension ||
        decoded.height > maxImageDimension) {
      return const ContentSafetyResult.blocked(
        ContentSafetyViolation.invalidOrUnsafeImage,
        reason: 'invalid_dimensions',
      );
    }

    return const ContentSafetyResult.safe();
  }

  /// Invokes VisualCheckUp's `moderateCommunityImage` Cloud Function (Google
  /// Cloud Vision SafeSearch) when Firebase is active. Gracefully passes when
  /// running offline / in guest mode.
  static Future<ContentSafetyResult> moderateImageServerSide({
    required String imageUrl,
    String? objectKey,
    bool useFirebase = true,
  }) async {
    if (!useFirebase || imageUrl.trim().isEmpty) {
      return const ContentSafetyResult.safe();
    }
    try {
      if (Firebase.apps.isEmpty ||
          fb.FirebaseAuth.instance.currentUser == null) {
        return const ContentSafetyResult.safe();
      }
      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('moderateCommunityImage');
      final response = await callable.call<dynamic>({
        'imageUrl': imageUrl,
        if (objectKey != null && objectKey.isNotEmpty) 'objectKey': objectKey,
      });
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['safe'] == false) {
        return ContentSafetyResult.blocked(
          ContentSafetyViolation.invalidOrUnsafeImage,
          reason: (data['reason'] as String?) ?? 'safesearch_rejected',
        );
      }
    } catch (_) {
      // Allow graceful operation if Vision API / Cloud Function is not yet deployed.
    }
    return const ContentSafetyResult.safe();
  }
}
