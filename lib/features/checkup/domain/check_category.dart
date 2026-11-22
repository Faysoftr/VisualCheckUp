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
        return 'Döküntü, leke, pullanma ve ben ön kontrolü';
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

  static CheckCategory fromId(String id) {
    return CheckCategory.values.firstWhere(
      (c) => c.name == id,
      orElse: () => CheckCategory.eye,
    );
  }
}
