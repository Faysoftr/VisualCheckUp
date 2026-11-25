import 'package:flutter/material.dart';

enum CheckCategory {
  eye,
  nail,
  tongue,
  face,
  skinCondition,
  urine,
  stool,
}

extension CheckCategoryX on CheckCategory {
  String get id => name;

  String get title {
    switch (this) {
      case CheckCategory.eye:
        return 'Göz (Sklera)';
      case CheckCategory.nail:
        return 'Tırnak';
      case CheckCategory.tongue:
        return 'Dil';
      case CheckCategory.face:
        return 'Yüz & Cilt';
      case CheckCategory.skinCondition:
        return 'Cilt Hastalıkları';
      case CheckCategory.urine:
        return 'İdrar Rengi';
      case CheckCategory.stool:
        return 'Dışkı Rengi';
    }
  }

  String get subtitle {
    switch (this) {
      case CheckCategory.eye:
        return 'Kızarıklık, sarılık ve göz akı tonu';
      case CheckCategory.nail:
        return 'Solukluk, morarma ve sararma kontrolü';
      case CheckCategory.tongue:
        return 'Renk, beyaz/sarı tabaka ve kuruluk';
      case CheckCategory.face:
        return 'Cilt tonu, solgunluk ve kızarıklık';
      case CheckCategory.skinCondition:
        return 'Ben, siğil, morluk, yüz lekesi ve döküntü';
      case CheckCategory.urine:
        return 'Hidrasyon ve renk skalası kontrolü';
      case CheckCategory.stool:
        return 'Sindirim ve renk uyarı kontrolü';
    }
  }

  IconData get icon {
    switch (this) {
      case CheckCategory.eye:
        return Icons.visibility_outlined;
      case CheckCategory.nail:
        return Icons.back_hand_outlined;
      case CheckCategory.tongue:
        return Icons.record_voice_over_outlined;
      case CheckCategory.face:
        return Icons.face_retouching_natural_outlined;
      case CheckCategory.skinCondition:
        return Icons.healing_outlined;
      case CheckCategory.urine:
        return Icons.water_drop_outlined;
      case CheckCategory.stool:
        return Icons.health_and_safety_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case CheckCategory.eye:
        return const Color(0xFF2B7A78);
      case CheckCategory.nail:
        return const Color(0xFF7B5EA7);
      case CheckCategory.tongue:
        return const Color(0xFFD65A6F);
      case CheckCategory.face:
        return const Color(0xFFE07A5F);
      case CheckCategory.skinCondition:
        return const Color(0xFFC8553D);
      case CheckCategory.urine:
        return const Color(0xFFD99B26);
      case CheckCategory.stool:
        return const Color(0xFF8C5E3C);
    }
  }

  /// Soft photorealistic editorial background image for HomeScreen & Hub cards.
  String get cardBackgroundAsset {
    switch (this) {
      case CheckCategory.eye:
        return 'assets/images/card_eye.jpg';
      case CheckCategory.nail:
        return 'assets/images/card_nail.jpg';
      case CheckCategory.tongue:
        return 'assets/images/card_tongue.jpg';
      case CheckCategory.face:
        return 'assets/images/card_face.jpg';
      case CheckCategory.skinCondition:
        return 'assets/images/card_skin.jpg';
      case CheckCategory.urine:
        return 'assets/images/card_urine.jpg';
      case CheckCategory.stool:
        return 'assets/images/card_stool.jpg';
    }
  }

  String get captureGuide {
    switch (this) {
      case CheckCategory.eye:
        return 'Doğal gün ışığında göz akını (sklera) çerçeve içine ortalayın. Flaş kullanmayın.';
      case CheckCategory.nail:
        return 'Ojesiz temiz bir tırnağınızı beyaz bir zemin önünde çerçeveye yerleştirin.';
      case CheckCategory.tongue:
        return 'Yemek/içecekten en az 30 dk sonra, gün ışığında dilinizi hafifçe dışarı çıkarıp çerçeveleyin.';
      case CheckCategory.face:
        return 'Makyajsız ve doğrudan gün ışığı alan bir ortamda yüzünüzü çerçeveye ortalayın.';
      case CheckCategory.skinCondition:
        return 'Doğal gün ışığında, 10–15 cm mesafeden lezyon veya döküntüyü ortalayın; çevresinde sağlıklı ciltten de küçük bir alan bulunsun.';
      case CheckCategory.urine:
        return 'İyi aydınlatılmış beyaz bir arka plan önünde örneği çerçeve içine alın.';
      case CheckCategory.stool:
        return 'Doğrudan ışık altında, gölge düşmeyecek şekilde rengi çerçeve içine ortalayın.';
    }
  }

  bool get prefersFrontCamera {
    switch (this) {
      case CheckCategory.eye:
      case CheckCategory.tongue:
      case CheckCategory.face:
        return true;
      case CheckCategory.nail:
      case CheckCategory.skinCondition:
      case CheckCategory.urine:
      case CheckCategory.stool:
        return false;
    }
  }

  /// Categories where placing a white paper/surface inside the secondary frame
  /// is practical and yields the highest white-balance calibration accuracy.
  bool get recommendsWhiteReference {
    switch (this) {
      case CheckCategory.nail:
      case CheckCategory.urine:
      case CheckCategory.stool:
        return true;
      case CheckCategory.eye:
      case CheckCategory.tongue:
      case CheckCategory.face:
      case CheckCategory.skinCondition:
        return false;
    }
  }

  /// Categories where a camera-free 2-second color chart picker is offered
  /// alongside camera capture for privacy and convenience.
  bool get supportsQuickColorCard {
    switch (this) {
      case CheckCategory.urine:
      case CheckCategory.stool:
        return true;
      case CheckCategory.eye:
      case CheckCategory.nail:
      case CheckCategory.tongue:
      case CheckCategory.face:
      case CheckCategory.skinCondition:
        return false;
    }
  }

  /// Non-diagnostic clinic/specialty guidance shown on doctor-visit summaries
  /// when follow-up or medical consultation is advised.
  String get recommendedSpecialty {
    switch (this) {
      case CheckCategory.eye:
        return 'Göz Hastalıkları veya Dahiliye';
      case CheckCategory.nail:
        return 'Dermatoloji veya Dahiliye';
      case CheckCategory.tongue:
        return 'KBB, Ağız & Diş Sağlığı veya Dahiliye';
      case CheckCategory.face:
        return 'Dermatoloji veya Dahiliye';
      case CheckCategory.skinCondition:
        return 'Dermatoloji';
      case CheckCategory.urine:
        return 'Üroloji veya Dahiliye';
      case CheckCategory.stool:
        return 'Gastroenteroloji veya Dahiliye';
    }
  }

  static CheckCategory fromId(String id) {
    return CheckCategory.values.firstWhere(
      (c) => c.name == id,
      orElse: () => CheckCategory.eye,
    );
  }
}
