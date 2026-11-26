import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/visual_announcement_effect_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Single evidence-based health tip item with category and clinical source.
class HealthDailyTip {
  const HealthDailyTip({
    required this.category,
    required this.quote,
    this.source,
  });

  final String category;
  final String quote;
  final String? source;
}

/// Evidence-based daily health tips (rotates deterministically by day of year)
/// plus birthday celebration helper for VisualCheckUp HomeScreen.
class DailyWellnessExtras {
  DailyWellnessExtras._();

  static const String _birthdayMonthKey = 'visualcheckup_birthday_month_v1';
  static const String _birthdayDayKey = 'visualcheckup_birthday_day_v1';

  static Future<void> saveBirthday({
    required int month,
    required int day,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_birthdayMonthKey, month.clamp(1, 12));
    await prefs.setInt(_birthdayDayKey, day.clamp(1, 31));
  }

  static Future<(int, int)?> loadBirthday() async {
    final prefs = await SharedPreferences.getInstance();
    final m = prefs.getInt(_birthdayMonthKey);
    final d = prefs.getInt(_birthdayDayKey);
    if (m == null || d == null) return null;
    return (m, d);
  }

  static Future<bool> isTodayBirthday({DateTime? now}) async {
    final saved = await loadBirthday();
    if (saved == null) return false;
    final dt = now ?? DateTime.now();
    return saved.$1 == dt.month && saved.$2 == dt.day;
  }

  static HealthDailyTip dailyTipItemForLocale(String languageCode, {DateTime? now}) {
    final dt = now ?? DateTime.now();
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays;
    final code = languageCode.toLowerCase();

    final tips = _catalogByLang[code] ?? _catalogByLang['en']!;
    return tips[dayOfYear.abs() % tips.length];
  }

  static String dailyTipForLocale(String languageCode, {DateTime? now}) {
    return dailyTipItemForLocale(languageCode, now: now).quote;
  }

  static const Map<String, List<HealthDailyTip>> _catalogByLang = {
    'tr': [
      HealthDailyTip(category: 'Göz Sağlığı', quote: 'Göz yorgunluğunu azaltmak için 20-20-20 kuralını uygulayın: Her 20 dakikada 20 saniye boyunca 6 metre (20 feet) uzağa bakın.', source: 'Oftalmoloji Kılavuzu'),
      HealthDailyTip(category: 'Tansiyon & Dolaşım', quote: 'Evde tansiyon ölçerken 5 dakika dinlenin, sırtınızı yaslayın, konuşmayın ve manşonu tam kalp hizasında tutun.', source: 'Kardiyoloji Konsensüsü'),
      HealthDailyTip(category: 'Metabolizma & Şeker', quote: 'Yemeklerden 20-30 dakika sonra yapılan 15 dakikalık hafif yürüyüş, tokluk kan şekeri dalgalanmalarını %30\'a kadar dengeler.', source: 'Diyabet & Metabolizma'),
      HealthDailyTip(category: 'Hidrasyon & Su', quote: 'Güne 1 bardak oda sıcaklığında suyla başlamak, gece kaybedilen sıvıyı tazeler ve sindirim sistemini nazikçe uyandırır.', source: 'Nefroloji & Hidrasyon'),
      HealthDailyTip(category: 'Sirkadiyen Ritim', quote: 'Uyanıştan sonraki ilk 1 saat içinde 10-15 dakika doğal gün ışığı almak, sirkadiyen ritmi kurar ve gece melatonin salınımını programlar.', source: 'Kronobiyoloji & Uyku'),
      HealthDailyTip(category: 'Uyku Hijyeni', quote: 'Yatmadan 1 saat önce telefon ve ekran ışıklarını kısmak, uykuya dalış süresini kısaltır ve derin REM uykusunu korur.', source: 'Nöroloji & Uyku Tıbbı'),
      HealthDailyTip(category: 'Cilt & Dolaşım', quote: 'Tırnak yatağınıza 3 saniye hafifçe bastırıp bırakın; pembe rengin 2 saniyede geri dönmesi sağlıklı periferik kan dolaşımını gösterir.', source: 'Fizik Muayene Kılavuzu'),
      HealthDailyTip(category: 'Nefes & Stres', quote: 'Fizyolojik iç çekiş uygulayın: Burundan üst üste iki derin nefes alıp ağızdan uzunca üfleyin; vagus siniri üzerinden dakikada kalp hızını yatıştırır.', source: 'Nörofizyoloji & Stres'),
      HealthDailyTip(category: 'Postür & Ergonomi', quote: 'Bilgisayar ekranınızın üst çizgisini göz hizanıza getirin; boynun öne sadece 15 derece eğilmesi omurgaya 12 kg ekstra yük bindirir.', source: 'Ergonomi & Fizik Tedavi'),
      HealthDailyTip(category: 'Kalp & Beslenme', quote: 'Günlük tuz tüketimini 5 gramın (1 çay kaşığı) altında tutmak, damar esnekliğini koruyarak hipertansiyon ve böbrek yükünü düşürür.', source: 'DSÖ / Kardiyoloji'),
      HealthDailyTip(category: 'Göz Nemliliği', quote: 'Ekran karşısında göz kırpma sıklığı %60 azalır; korneayı nemli tutmak için bilinçli olarak birkaç kez derin göz kırpın.', source: 'Göz Kuruluğu Rehberi'),
      HealthDailyTip(category: 'Dil & Sindirim', quote: 'Sabahları dilinizi aynada inceleyin; aşırı kalın beyaz tabaka su eksikliğine, ağız kuruluğuna veya sindirim dengesizliğine işaret edebilir.', source: 'Görsel Check-Up Kılavuzu'),
      HealthDailyTip(category: 'Beslenme Farkındalığı', quote: 'Lokmaları en az 20 kez çiğnemek, tokluk hormonları leptin ve GLP-1 salgılanmasına zaman tanıyarak aşırı yemeyi önler.', source: 'Gastroenteroloji'),
      HealthDailyTip(category: 'Kas & Metabolizma', quote: 'Masa başında otururken topukları kaldırıp indirerek baldır soleus kasını çalıştırmak, kan şekeri ve trigliserit yakımını hızlandırır.', source: 'Fizyoloji Çalışmaları'),
      HealthDailyTip(category: 'Hidrasyon Göstergesi', quote: 'Açık saman sarısı idrar rengi ideal sıvı dengesini gösterir; koyu kehribar rengi su ihtiyacınızı, tamamen şeffaf olması mineral kaybını işaret edebilir.', source: 'Nefroloji Standartları'),
      HealthDailyTip(category: 'Bağırsak Mikrobiyomu', quote: 'Haftada 25-30 farklı bitkisel kaynak (meyve, sebze, bakliyat, tohum) tüketmek, bağırsak florasını zenginleştirerek bağışıklığı güçlendirir.', source: 'Mikrobiyom Araştırmaları'),
      HealthDailyTip(category: 'Mineraller & Kaslar', quote: 'Koyu yeşil yapraklı sebzeler ve kabak çekirdeği zengin magnezyum depolarıdır; kas kramplarını önler ve sinir sistemini gevşetir.', source: 'Klinik Beslenme'),
      HealthDailyTip(category: 'Cilt Esnekliği (Turgor)', quote: 'El sırtınızdaki deriyi hafifçe yukarı çekip bırakın; anında eski haline dönmesi hücre içi sıvı seviyenizin yeterli olduğunu gösterir.', source: 'Fiziksel Değerlendirme'),
      HealthDailyTip(category: 'Kalp & Hareket', quote: 'Günde 50-60 basamak merdiven çıkmak, kalp krizi riskini düşürmede en zaman tasarruflu kardiyovasküler mikro-egzersizdir.', source: 'Kardiyoloji Araştırmaları'),
      HealthDailyTip(category: 'Uyku Kalitesi & Sıcaklık', quote: 'Yatak odasının 18-20°C serinlikte olması, çekirdek vücut ısısının doğal olarak düşmesini sağlayarak derin uyku evresini uzatır.', source: 'Uyku Tıbbı Kılavuzları'),
      HealthDailyTip(category: 'Damar & Potasyum', quote: 'Ispanak, avokado ve muzdaki zengin potasyum, sodyumun damar büzücü etkisini nötralize ederek tansiyon kontrolünü destekler.', source: 'Hipertansiyon Konsensüsü'),
      HealthDailyTip(category: 'Zihin & Odaklanma', quote: '50 dakikalık odaklanma sonrası 5 dakikalık ekransız mola vermek, prefrontal korteks yorgunluğunu sıfırlar ve dikkat hatalarını önler.', source: 'Bilişsel Nörobilim'),
      HealthDailyTip(category: 'Hücresel Yenilenme (Otofaji)', quote: 'Akşam yemeğini uykudan en az 3 saat önce bitirmek, gece boyunca hücrelerin hasarlı proteinleri temizlemesini (otofaji) destekler.', source: 'Hücre Biyolojisi & Ömür'),
      HealthDailyTip(category: 'D Vitamini & Kemik', quote: 'Gün ortasında kollar ve bacakları 15 dakika güneşle buluşturmak, kemik mineral yoğunluğu ve bağışıklık için D vitamini sentezini başlatır.', source: 'Endokrinoloji Derneği'),
      HealthDailyTip(category: 'Ağız & Kalp Bağlantısı', quote: 'Günde 1 kez diş ipi kullanmak, diş eti iltihabına yol açan bakterilerin kana karışarak damar duvarında plak oluşturmasını önler.', source: 'Periodontoloji & Kardiyoloji'),
      HealthDailyTip(category: 'Kafein & Uyku', quote: 'Kafeinin yarı ömrü 5-7 saattir; öğleden sonra 14:00\'ten sonra kahve alımını kesmek, beyinde derin uyku sağlayan adenozin birikimini korur.', source: 'Nörofarmakoloji'),
      HealthDailyTip(category: 'Solunum & Nitrik Oksit', quote: 'Burundan nefes almak havayı filtreler, ısıtır ve paranazal sinüslerde damar genişletici nitrik oksit (NO) üretimini artırarak oksijenlenmeyi güçlendirir.', source: 'Göğüs Hastalıkları'),
      HealthDailyTip(category: 'Cilt & Kollajen', quote: 'Turunçgiller, kivi ve biberdeki zengin C vitamini, eklemlerin ve cildin ana esneklik proteini olan kollajen üretiminde zorunlu bir koenzimdir.', source: 'Dermatoloji & Biyokimya'),
      HealthDailyTip(category: 'Dolaşım & Hareket Molası', quote: 'Masa başında her 45 dakikada bir 2 dakika ayağa kalkıp esnemek, bacak toplardamarlarında göllenmeyi önler ve zihni tazeler.', source: 'Damar Cerrahisi & Ergonomi'),
      HealthDailyTip(category: 'Zihinsel Dinginlik & Kalp', quote: 'Günde 1 dakika içtenlikle teşekkür etmek veya şükran duymak, kortizol stres hormonunu düşürerek kalp atım değişkenliğini (HRV) yükseltir.', source: 'Pozitif Psikofizyoloji'),
    ],
    'en': [
      HealthDailyTip(category: 'Eye Health', quote: 'Practice the 20-20-20 rule to relieve eye strain: every 20 minutes, focus on an object 20 feet away for 20 seconds.', source: 'Ophthalmology Guidelines'),
      HealthDailyTip(category: 'Blood Pressure & Heart', quote: 'Rest quietly for 5 minutes before home blood pressure checks, keep feet flat on the floor, and support your arm at heart level.', source: 'Cardiology Guidelines'),
      HealthDailyTip(category: 'Metabolism & Glucose', quote: 'A gentle 15-minute walk 20 to 30 minutes after meals blunts postprandial glucose spikes by up to 30%.', source: 'Metabolic Health Journal'),
      HealthDailyTip(category: 'Hydration & Vitality', quote: 'Starting your day with a glass of room-temperature water replenishes overnight fluid loss and gently activates digestion.', source: 'Nephrology & Hydration'),
      HealthDailyTip(category: 'Circadian Rhythm', quote: 'Getting 10 to 15 minutes of natural morning sunlight within an hour of waking sets your master circadian clock and primes nighttime melatonin.', source: 'Chronobiology & Sleep'),
      HealthDailyTip(category: 'Sleep Hygiene', quote: 'Dimming screens and blue-light devices 1 hour before bed shortens sleep latency and preserves restorative deep REM cycles.', source: 'Neurology & Sleep Medicine'),
      HealthDailyTip(category: 'Circulation Check', quote: 'Press your fingernail bed for 3 seconds; a return to healthy pink within 2 seconds indicates normal peripheral microcirculation.', source: 'Clinical Examination Guide'),
      HealthDailyTip(category: 'Breath & Stress Reset', quote: 'Try a physiological sigh: two quick inhales through the nose followed by a long, slow exhale through the mouth to rapidly engage the calming vagus nerve.', source: 'Neurophysiology & Stress'),
      HealthDailyTip(category: 'Posture & Ergonomics', quote: 'Align the top of your monitor with eye level; tilting your head forward by just 15 degrees adds 27 lbs (12 kg) of cervical spine strain.', source: 'Ergonomics & Orthopedics'),
      HealthDailyTip(category: 'Cardiovascular Nutrition', quote: 'Keeping daily salt intake under 5 grams (one teaspoon) preserves arterial elasticity and significantly reduces kidney strain.', source: 'WHO & Cardiology'),
      HealthDailyTip(category: 'Ocular Hydration', quote: 'Screen use reduces blink rates by 60%; blink intentionally every few minutes to spread a fresh, protective tear film over the cornea.', source: 'Dry Eye Consensus'),
      HealthDailyTip(category: 'Tongue & Gut Health', quote: 'Check your tongue in the mirror: a heavy white coating often signals overnight dehydration, mouth breathing, or microbiome imbalance.', source: 'Clinical Diagnostics'),
      HealthDailyTip(category: 'Mindful Eating', quote: 'Chewing each mouthful at least 20 times gives gut satiety peptides like GLP-1 and leptin time to signal genuine fullness.', source: 'Gastroenterology Journal'),
      HealthDailyTip(category: 'Muscular Metabolism', quote: 'Performing seated soleus calf push-ups while at your desk activates oxidative muscle metabolism, clearing blood sugar without fatigue.', source: 'Physiological Research'),
      HealthDailyTip(category: 'Hydration Gauge', quote: 'Pale straw-colored urine indicates optimal hydration; dark amber signals a need to drink, while clear urine warns of electrolyte dilution.', source: 'Nephrology Standards'),
      HealthDailyTip(category: 'Gut Microbiome Diversity', quote: 'Aim to eat 25 to 30 diverse plant foods weekly (vegetables, seeds, legumes, fruits) to cultivate a robust and resilient gut microbiome.', source: 'Microbiome Health Studies'),
      HealthDailyTip(category: 'Magnesium & Recovery', quote: 'Dark leafy greens and pumpkin seeds are rich in magnesium, an essential cofactor that soothes nighttime cramps and calms the nervous system.', source: 'Clinical Nutrition Guide'),
      HealthDailyTip(category: 'Skin Turgor Test', quote: 'Pinch the skin on the back of your hand and release; an immediate snap-back confirms normal cellular hydration and tissue elasticity.', source: 'Physical Assessment Manual'),
      HealthDailyTip(category: 'Cardio Micro-Habits', quote: 'Climbing 50 to 60 stairs daily is one of the most time-efficient micro-workouts to lower cardiovascular risk and boost vascular stamina.', source: 'Cardiology Research'),
      HealthDailyTip(category: 'Sleep Environment', quote: 'Maintaining a bedroom temperature around 18–20°C (65–68°F) assists the natural core body temperature drop required for deep stage-3 sleep.', source: 'Sleep Medicine Standards'),
      HealthDailyTip(category: 'Potassium & Arterial Tone', quote: 'Dietary potassium from spinach, avocados, and bananas counteracts sodium-induced vasoconstriction to promote relaxed arteries.', source: 'Hypertension Consensus'),
      HealthDailyTip(category: 'Cognitive Focus & Reset', quote: 'Taking a 5-minute screen-free break every 50 minutes clears prefrontal cortex fatigue, sustaining laser-sharp decision accuracy.', source: 'Cognitive Neuroscience'),
      HealthDailyTip(category: 'Cellular Autophagy', quote: 'Finishing dinner at least 3 hours before sleep lowers nighttime insulin, triggering cellular autophagy and tissue rejuvenation.', source: 'Cell Biology & Longevity'),
      HealthDailyTip(category: 'Vitamin D & Immunity', quote: 'Exposing your arms and legs to 15 minutes of midday sun triggers cutaneous vitamin D synthesis vital for bone density and immune defense.', source: 'Endocrine Society Guidelines'),
      HealthDailyTip(category: 'Oral-Heart Connection', quote: 'Daily flossing clears subgingival bacteria, preventing chronic periodontal microbes from entering the bloodstream and inflaming arteries.', source: 'Periodontology & Cardiology'),
      HealthDailyTip(category: 'Caffeine Curfew', quote: 'With a 5 to 7-hour metabolic half-life, stopping caffeine intake by 2:00 PM preserves natural adenosine buildup for restorative sleep.', source: 'Neuropharmacology & Sleep'),
      HealthDailyTip(category: 'Nasal Breathing Power', quote: 'Nasal breathing filters and warms incoming air while stimulating paranasal nitric oxide release, significantly enhancing lung oxygen absorption.', source: 'Pulmonology Research'),
      HealthDailyTip(category: 'Collagen & Vitamin C', quote: 'Vitamin C from citrus, kiwi, and peppers is an indispensable cofactor for enzymatic collagen synthesis, keeping joints and skin resilient.', source: 'Dermatology & Biochemistry'),
      HealthDailyTip(category: 'Vascular Movement Break', quote: 'Standing and moving for just 2 minutes every 45 minutes breaks venous stasis in the lower extremities and restores cerebral blood flow.', source: 'Vascular Surgery & Ergonomics'),
      HealthDailyTip(category: 'Mindfulness & Heart Harmony', quote: 'Spending just one minute practicing heartfelt gratitude measurably lowers cortisol and increases beneficial heart rate variability (HRV).', source: 'Psychophysiology Research'),
    ],
    'zh': [
      HealthDailyTip(category: '眼睛健康', quote: '遵循20-20-20护眼法则：每使用屏幕20分钟，抬头向20英尺（约6米）外远眺20秒。', source: '眼科临床指南'),
      HealthDailyTip(category: '血压与心脏', quote: '在家测量血压前静坐休息5分钟，背靠椅背，测量时保持安静，并将袖带置于与心脏同高位置。', source: '心血管临床共识'),
      HealthDailyTip(category: '代谢与血糖', quote: '餐后20至30分钟进行15分钟轻松散步，可使餐后血糖峰值平缓降低高达30%。', source: '内分泌与代谢临床'),
      HealthDailyTip(category: '水合与活力', quote: '清晨空腹喝一杯温开水，可迅速补充夜间流失的水分，温和唤醒肠道消化功能。', source: '消化与水合健康'),
      HealthDailyTip(category: '昼夜节律与睡眠', quote: '醒后1小时内沐浴10至15分钟自然阳光，能够校准生物钟，为夜间褪黑素正常分泌做好铺垫。', source: '时间生物学研究'),
      HealthDailyTip(category: '睡眠卫生与大脑', quote: '睡前1小时调暗屏幕或远离蓝光设备，能显著缩短入睡时间并保护大脑深度修复睡眠。', source: '神经科学与睡眠学会'),
      HealthDailyTip(category: '微循环与指甲', quote: '轻压甲床3秒后松开；如果粉红色在2秒内恢复，表明肢端微循环供血状态健康良好。', source: '体格检查临床手册'),
      HealthDailyTip(category: '呼吸与减压', quote: '尝试生理性叹息呼吸法：用鼻子连续深吸两口气，再通过嘴巴缓缓长呼气，可在数秒内激活迷走神经平静身心。', source: '神经生理学研究'),
      HealthDailyTip(category: '体态与工位健康', quote: '将电脑屏幕顶端调整至视线平齐；头部前倾仅15度就会使颈椎额外承受约12公斤的重压。', source: '人体工效学与骨科'),
      HealthDailyTip(category: '心血管营养', quote: '将每日食盐摄入量控制在5克（约一茶匙）以下，能有效保护血管弹性，显著降低高血压与肾脏负荷。', source: '世界卫生组织心血管指南'),
      HealthDailyTip(category: '眼表水润与泪膜', quote: '注视电子屏幕时眨眼频率会减少60%；有意识地多眨几次眼，让泪液均匀覆盖角膜预防眼干。', source: '干眼症防治指南'),
      HealthDailyTip(category: '舌诊与消化健康', quote: '晨起观察舌苔：若舌面附着厚白苔，往往提示机体缺水、夜间口呼吸或胃肠消化失衡。', source: '临床视诊指南'),
      HealthDailyTip(category: '细嚼慢咽与饱腹感', quote: '每口食物咀嚼约20次，能给肠道分泌GLP-1和瘦素留足时间，及时向大脑传递饱腹信号。', source: '胃肠营养临床'),
      HealthDailyTip(category: '肌肉代谢与工位微动', quote: '久坐办公时频繁抬起脚跟锻炼比目鱼肌，能有效激活局部氧化代谢，加速清理血液葡萄糖。', source: '肌力与代谢生理学'),
      HealthDailyTip(category: '尿液水合监测', quote: '浅麦秆黄色尿液代表最佳水合状态；深琥珀色提示急需补水，而完全透明无色则警惕电解质被过度稀释。', source: '肾脏内科标准'),
      HealthDailyTip(category: '肠道菌群与多样性', quote: '每周摄入25至30种不同的植物性食材（蔬果、全谷、豆类、坚果），能显著丰富有益肠道菌群并增强免疫。', source: '微生物组前沿科学'),
      HealthDailyTip(category: '镁元素与肌肉放松', quote: '深绿叶蔬菜和南瓜籽富含优质镁元素，有助于缓解夜间肌肉抽筋，温和舒缓紧张的神经系统。', source: '临床营养学指南'),
      HealthDailyTip(category: '皮肤弹性测试', quote: '轻捏手背皮肤向上提起然后松手；如果皮肤瞬间平整回弹，证实机体细胞水分充足且弹性良好。', source: '体检临床体征'),
      HealthDailyTip(category: '心血管微运动', quote: '每天爬50至60级楼梯是最省时有效的心肺微锻炼，能显著降低心血管意外风险并增强心肌活力。', source: '心血管流行病学研究'),
      HealthDailyTip(category: '睡眠环境与深睡眠', quote: '卧室温度保持在18至20°C左右的凉爽环境，有助于体温自然下降，从而显著延长深度修复睡眠时间。', source: '睡眠医学临床指南'),
      HealthDailyTip(category: '钾元素与动脉舒张', quote: '菠菜、牛油果和香蕉富含优质钾，能对抗钠引起的血管收缩，帮助平稳舒张血管并调节血压。', source: '高血压临床共识'),
      HealthDailyTip(category: '大脑专注与复位', quote: '每专注工作50分钟离开屏幕休息5分钟，能有效消除前额叶皮层疲劳，避免注意力涣散与决策错误。', source: '认知神经科学'),
      HealthDailyTip(category: '细胞自噬与抗衰', quote: '在睡前至少3小时结束晚餐，有助于夜间降低胰岛素水平，激活体内细胞自噬与组织修复机制。', source: '细胞生物学与延寿科学'),
      HealthDailyTip(category: '维生素D与骨骼免疫', quote: '正午前后将手臂与双腿适度接受约15分钟日晒，可有效促进体内合成充足的天然维生素D，呵护骨骼与免疫。', source: '内分泌学会指南'),
      HealthDailyTip(category: '口腔与心脏健康', quote: '每天使用一次牙线清洁牙缝，能有效防止牙龈厌氧菌进入血液循环引起血管内皮炎症与斑块沉积。', source: '牙周病学与心脏病学'),
      HealthDailyTip(category: '咖啡因代谢节律', quote: '咖啡因在体内的半衰期长达5至7小时；下午2点后停止饮用咖啡，可让促进深睡的腺苷在脑内自然累积。', source: '神经药理学与睡眠'),
      HealthDailyTip(category: '鼻呼吸与一氧化氮', quote: '坚持鼻呼吸不仅能过滤加温空气，还能刺激副鼻窦释放一氧化氮，显著促进肺泡对氧气的摄取。', source: '呼吸医学研究'),
      HealthDailyTip(category: '胶原蛋白与维生素C', quote: '柑橘、猕猴桃与彩椒中丰富的维生素C是胶原蛋白合成的必需辅酶，可强韧关节软骨并维持肌肤弹性。', source: '皮肤科与生物化学'),
      HealthDailyTip(category: '下肢静脉与工位起立', quote: '久坐每45分钟站立活动2分钟，能有效消除下肢静脉血液淤积，改善全身微循环并振奋精神。', source: '血管外科与人体工效学'),
      HealthDailyTip(category: '心境平和与心率变异性', quote: '每天花1分钟体验由衷的感恩与平和，能显著降低皮质醇压力激素，并提升反映心脏韧性的心率变异性（HRV）。', source: '身心生理学研究'),
    ],
    'hi': [
      HealthDailyTip(category: 'आंखों का स्वास्थ्य', quote: 'आंखों की थकान दूर करने के लिए 20-20-20 नियम अपनाएं: हर 20 मिनट बाद 20 सेकंड के लिए 20 फीट दूर देखें।', source: 'नेत्र विज्ञान दिशानिर्देश'),
      HealthDailyTip(category: 'रक्तचाप और दिल', quote: 'घर पर रक्तचाप नापने से पहले 5 मिनट शांत बैठें, पीठ सीधी रखें, बात न करें और कफ को दिल की सीध में रखें।', source: 'कार्डियोलॉजी दिशा-निर्देश'),
      HealthDailyTip(category: 'मेटाबॉलिज्म और शुगर', quote: 'भोजन के 20-30 मिनट बाद 15 मिनट की हल्की सैर खाने के बाद शुगर के उतार-चढ़ाव को 30% तक नियंत्रित रखती है।', source: 'डायबिटीज अध्ययन'),
      HealthDailyTip(category: 'हाइड्रेशन और ताजगी', quote: 'सुबह की शुरुआत एक गिलास गुनगुने पानी से करने से रात में हुई पानी की कमी पूरी होती है और पाचन क्रिया सक्रिय होती है।', source: 'जलयोजन अनुसंधान'),
      HealthDailyTip(category: 'जैविक घड़ी और नींद', quote: 'जागने के 1 घंटे के भीतर 10-15 मिनट की सुबह की धूप लेने से जैविक घड़ी सही सेट होती है और रात को अच्छी नींद आती है।', source: 'क्रोनोबायोलॉजी गाइड'),
      HealthDailyTip(category: 'गहरी नींद की आदतें', quote: 'सोने से 1 घंटा पहले मोबाइल और स्क्रीन से दूरी बनाने से मेलाटोनिन बढ़ता है और गहरी नींद आती है।', source: 'न्यूरोलॉजी और स्लीप साइंस'),
      HealthDailyTip(category: 'रक्त संचार और नाखून', quote: 'नाखून को 3 सेकंड दबाकर छोड़ें; 2 सेकंड के भीतर गुलाबी रंग का लौटना स्वस्थ रक्त संचार का संकेत है।', source: 'शारीरिक परीक्षण गाइड'),
      HealthDailyTip(category: 'श्वास और तनाव मुक्ति', quote: 'फिजियोलॉजिकल सांस लें: नाक से दो बार गहरी सांस भरें और मुंह से धीरे-धीरे लंबी सांस छोड़ें; यह तंत्रिका तंत्र को तुरंत शांत करता है।', source: 'न्यूरोसाइंस अध्ययन'),
      HealthDailyTip(category: 'मुद्रा और रीढ़ की हड्डी', quote: 'कंप्यूटर स्क्रीन को आंखों के स्तर पर रखें; सिर को 15 डिग्री आगे झुकाने से गर्दन की रीढ़ पर 12 किलो का अतिरिक्त भार पड़ता है।', source: 'एर्गोनॉमिक्स गाइड'),
      HealthDailyTip(category: 'दिल की सेहत और पोषण', quote: 'दैनिक नमक की मात्रा 5 ग्राम (एक चम्मच) से कम रखने से धमनियां लचीली रहती हैं और उच्च रक्तचाप का खतरा घटता है।', source: 'विश्व स्वास्थ्य संगठन'),
      HealthDailyTip(category: 'आंखों की नमी', quote: 'स्क्रीन देखते समय पलकें झपकाने की दर 60% कम हो जाती है; आंखों में सूखापन रोकने के लिए जानबूझकर गहरी पलकें झपकाएं।', source: 'ड्राई आई गाइड'),
      HealthDailyTip(category: 'जीभ और पाचन स्वास्थ्य', quote: 'सुबह शीशे में जीभ की जांच करें; जीभ पर मोटी सफेद परत पानी की कमी या पाचन असंतुलन का संकेत हो सकती है।', source: 'विजुअल चेक-अप गाइड'),
      HealthDailyTip(category: 'सचेत खान-पान', quote: 'हर निवाले को कम से कम 20 बार चबाएं; इससे तृप्ति हार्मोन को मस्तिष्क तक पेट भरने का संकेत भेजने का पर्याप्त समय मिलता है।', source: 'पोषण विज्ञान'),
      HealthDailyTip(category: 'मांसपेशियों का मेटाबॉलिज्म', quote: 'कुर्सी पर बैठे-बैठे एड़ी उठाकर सोलियस मांसपेशी की कसरत करने से बिना थके ब्लड शुगर और वसा जलने में मदद मिलती है।', source: 'व्यायाम फिजियोलॉजी'),
      HealthDailyTip(category: 'हाइड्रेशन का पैमाना', quote: 'हल्का पीला मूत्र आदर्श जलयोजन का संकेत है; गहरा रंग पानी की कमी दर्शाता है और बिल्कुल पारदर्शी होना मिनरल्स के नुकसान का संकेत है।', source: 'नेफ्रोलॉजी गाइड'),
      HealthDailyTip(category: 'पेट और आंतों का स्वास्थ्य', quote: 'सप्ताह में 25-30 विभिन्न प्रकार के पौधे-आधारित खाद्य पदार्थ (फल, सब्जियां, दालें, बीज) खाने से आंतों के मित्र बैक्टीरिया मजबूत होते हैं।', source: 'माइक्रोबायोम रिसर्च'),
      HealthDailyTip(category: 'मैग्नीशियम और मांसपेशियां', quote: 'गहरी हरी पत्तेदार सब्जियां और कद्दू के बीज मैग्नीशियम से भरपूर हैं; यह मांसपेशियों की ऐंठन रोकते हैं और नसों को आराम देते हैं।', source: 'क्लिनिकल पोषण गाइड'),
      HealthDailyTip(category: 'त्वचा का लचीलापन परीक्षण', quote: 'हाथ के पिछले हिस्से की त्वचा को हल्का खींचकर छोड़ें; यदि यह तुरंत सामान्य हो जाती है तो शरीर में पानी की मात्रा सही है।', source: 'शारीरिक मूल्यांकन'),
      HealthDailyTip(category: 'हृदय व्यायाम और सीढ़ियां', quote: 'दिन में 50-60 सीढ़ियां चढ़ना दिल की सेहत सुधारने और दिल के दौरे के जोखिम को घटाने का सबसे आसान तरीका है।', source: 'हृदय रोग अनुसंधान'),
      HealthDailyTip(category: 'सोने का वातावरण और तापमान', quote: 'बेडरूम का तापमान 18-20°C ठंडा रखने से शरीर का तापमान स्वाभाविक रूप से घटता है और गहरी नींद का समय बढ़ता है।', source: 'स्लीप मेडिसिन गाइड'),
      HealthDailyTip(category: 'पोटेशियम और रक्त वाहिकाएं', quote: 'पालक, एवोकाडो और केले में मौजूद पोटैशियम सोडियम के हानिकारक प्रभाव को कम करके रक्तचाप को नियंत्रित रखता है।', source: 'उच्च रक्तचाप गाइड'),
      HealthDailyTip(category: 'मानसिक एकाग्रता और रीसेट', quote: '50 मिनट काम के बाद 5 मिनट स्क्रीन से दूर ब्रेक लेने से मस्तिष्क की थकान दूर होती है और कार्यकुशलता बढ़ती है।', source: 'संज्ञानात्मक तंत्रिका विज्ञान'),
      HealthDailyTip(category: 'कोशिकीय नवीनीकरण (ऑटोफैगी)', quote: 'सोने से कम से कम 3 घंटे पहले रात का खाना खाने से रात में इंसुलिन गिरता है और शरीर में क्षतिग्रस्त कोशिकाओं की सफाई होती है।', source: 'सेलुलर बायोलॉजी'),
      HealthDailyTip(category: 'विटामिन डी और हड्डियां', quote: 'दिन में 15 मिनट बाहों और पैरों पर धूप लगने से त्वचा में प्राकृतिक विटामिन डी बनता है, जो हड्डियों और इम्युनिटी के लिए जरूरी है।', source: 'एंडोक्राइन सोसाइटी गाइड'),
      HealthDailyTip(category: 'दांत और दिल का संबंध', quote: 'रोजाना फ्लॉस करने से मसूड़ों के बैक्टीरिया खून में नहीं मिलते, जिससे धमनियों में सूजन और प्लाक बनने का खतरा टलता है।', source: 'दंत और हृदय विज्ञान'),
      HealthDailyTip(category: 'कैफीन और नींद का समय', quote: 'कैफीन 5-7 घंटे तक शरीर में सक्रिय रहता है; दोपहर 2 बजे के बाद कॉफी न पीने से रात को बिना खलल के गहरी नींद आती है।', source: 'न्यूरोफार्माकोलॉजी'),
      HealthDailyTip(category: 'नाक से सांस और नाइट्रिक ऑक्साइड', quote: 'नाक से सांस लेने से हवा छनती है और नाइट्रिक ऑक्साइड बनता है, जो फेफड़ों में ऑक्सीजन के अवशोषण को काफी बढ़ा देता है।', source: 'पल्मोनोलॉजी गाइड'),
      HealthDailyTip(category: 'कोलेजन और विटामिन सी', quote: 'खट्टे फल, कीवी और शिमला मिर्च में मौजूद विटामिन सी कोलेजन बनाने के लिए अनिवार्य है, जो त्वचा और जोड़ों को मजबूत रखता है।', source: 'त्वचा विज्ञान और पोषण'),
      HealthDailyTip(category: 'रक्त प्रवाह और गतिशीलता', quote: 'कुर्सी पर लगातार बैठने के दौरान हर 45 मिनट बाद 2 मिनट खड़े होकर टहलने से पैरों की नसों में रक्त संचार तेज होता है।', source: 'संवहनी स्वास्थ्य गाइड'),
      HealthDailyTip(category: 'मानसिक शांति और दिल की धड़कन', quote: 'दिन में 1 मिनट कृतज्ञता और सकारात्मकता महसूस करने से तनाव हार्मोन कोर्टिसोल घटता है और दिल की धड़कन संतुलित होती है।', source: 'साइकोफिजियोलॉजी'),
    ],
    'es': [
      HealthDailyTip(category: 'Salud Ocular', quote: 'Aplica la regla 20-20-20 para aliviar la fatiga visual: cada 20 minutos, mira a 6 metros de distancia durante 20 segundos.', source: 'Guía de Oftalmología'),
      HealthDailyTip(category: 'Presión Arterial', quote: 'Descansa 5 minutos antes de medir la presión en casa, apoya la espalda, no hables y coloca el manguito a la altura del corazón.', source: 'Consenso de Cardiología'),
      HealthDailyTip(category: 'Metabolismo y Glucosa', quote: 'Una caminata suave de 15 minutos entre 20 y 30 minutos después de comer reduce los picos de glucosa hasta un 30%.', source: 'Salud Metabólica'),
      HealthDailyTip(category: 'Hidratación y Vitalidad', quote: 'Comenzar el día con un vaso de agua templada repone los líquidos perdidos durante la noche y despierta la digestión.', source: 'Nefrología e Hidratación'),
      HealthDailyTip(category: 'Ritmo Circadiano', quote: 'Recibir 10-15 minutos de luz solar en la primera hora tras despertar calibra tu reloj biológico y programa la melatonina nocturna.', source: 'Cronobiología y Sueño'),
      HealthDailyTip(category: 'Higiene del Sueño', quote: 'Atenuar las pantallas 1 hora antes de dormir reduce el tiempo necesario para conciliar el sueño y favorece el descanso profundo.', source: 'Medicina del Sueño'),
      HealthDailyTip(category: 'Circulación Periférica', quote: 'Presiona la uña durante 3 segundos; si el color rosado vuelve en menos de 2 segundos, tu microcirculación periférica es óptima.', source: 'Guía de Exploración Clínica'),
      HealthDailyTip(category: 'Respiración y Calma', quote: 'Prueba el suspiro fisiológico: dos inhalaciones seguidas por la nariz y una exhalación larga por la boca calman el sistema nervioso rápidamente.', source: 'Neurofisiología del Estrés'),
      HealthDailyTip(category: 'Postura y Ergonomía', quote: 'Alinea la parte superior del monitor con tus ojos; inclinar el cuello 15 grados hacia adelante añade 12 kg de tensión cervical.', source: 'Ergonomía y Fisioterapia'),
      HealthDailyTip(category: 'Nutrición Cardiovascular', quote: 'Consumir menos de 5 gramos de sal al día (una cucharadita) protege la flexibilidad vascular y alivia la carga renal.', source: 'OMS / Cardiología'),
      HealthDailyTip(category: 'Hidratación Ocular', quote: 'El uso de pantallas reduce el parpadeo en un 60%; parpadea conscientemente para renovar la película lagrimal protectora.', source: 'Consenso de Ojo Seco'),
      HealthDailyTip(category: 'Lengua y Digestión', quote: 'Examina tu lengua por la mañana; una capa blanca y espesa puede advertir deshidratación o desequilibrio en la digestión.', source: 'Exploración Visual Clínica'),
      HealthDailyTip(category: 'Alimentación Consciente', quote: 'Masticar cada bocado unas 20 veces da tiempo a las hormonas de saciedad como GLP-1 para avisar al cerebro que estás satisfecho.', source: 'Gastroenterología'),
      HealthDailyTip(category: 'Metabolismo Muscular', quote: 'Elevar los talones sentado activa el músculo sóleo, quemando glucosa y triglicéridos sin cansancio general.', source: 'Fisiología del Ejercicio'),
      HealthDailyTip(category: 'Nivel de Hidratación', quote: 'El color amarillo pálido refleja una hidratación óptima; el ámbar oscuro avisa que necesitas agua y el transparente, posible dilución mineral.', source: 'Estándares de Nefrología'),
      HealthDailyTip(category: 'Microbioma Intestinal', quote: 'Consumir entre 25 y 30 fuentes vegetales variadas por semana (frutas, verduras, semillas) diversifica la microbiota y refuerza defensas.', source: 'Estudios de Microbioma'),
      HealthDailyTip(category: 'Magnesio y Músculos', quote: 'Las espinacas y las semillas de calabaza aportan magnesio, clave para evitar calambres nocturnos y relajar el sistema nervioso.', source: 'Nutrición Clínica'),
      HealthDailyTip(category: 'Turgencia de la Piel', quote: 'Pellizca suavemente la piel del dorso de la mano y suelta; un retorno inmediato refleja que tus células están bien hidratadas.', source: 'Manual de Exploración'),
      HealthDailyTip(category: 'Microhábitos Cardiovasculares', quote: 'Subir entre 50 y 60 escalones al día es un microejercicio rápido y muy eficaz para reducir el riesgo cardiovascular.', source: 'Investigación Cardiológica'),
      HealthDailyTip(category: 'Temperatura y Sueño Profundo', quote: 'Dormir en una habitación fresca (18–20 °C) facilita la bajada natural de la temperatura corporal necesaria para el sueño profundo.', source: 'Medicina del Sueño'),
      HealthDailyTip(category: 'Potasio y Vasodilatación', quote: 'El potasio de las espinacas, el aguacate y los plátanos contrarresta el sodio, ayudando a dilatar y relajar las arterias.', source: 'Consenso de Hipertensión'),
      HealthDailyTip(category: 'Enfoque Mental y Pausas', quote: 'Tomar un descanso de 5 minutos sin pantallas cada 50 minutos reinicia la fatiga del córtex prefrontal y agudiza la mente.', source: 'Neurociencia Cognitiva'),
      HealthDailyTip(category: 'Autofagia Celular', quote: 'Cenar al menos 3 horas antes de dormir reduce la insulina nocturna, activando la autofagia celular y la regeneración de tejidos.', source: 'Biología Celular y Longevidad'),
      HealthDailyTip(category: 'Vitamina D e Inmunidad', quote: 'Exponer brazos y piernas al sol durante 15 minutos al mediodía activa la síntesis de vitamina D, esencial para huesos y defensas.', source: 'Sociedad de Endocrinología'),
      HealthDailyTip(category: 'Salud Bucal y Cardíaca', quote: 'Usar hilo dental a diario elimina bacterias gingivales que podrían entrar al torrente sanguíneo e inflamar las arterias.', source: 'Periodoncia y Cardiología'),
      HealthDailyTip(category: 'Límite de Cafeína', quote: 'La cafeína tarda entre 5 y 7 horas en reducirse a la mitad; suspenderla tras las 14:00 h asegura el descanso profundo nocturno.', source: 'Neurofarmacología'),
      HealthDailyTip(category: 'Respiración Nasal y Óxido Nítrico', quote: 'Respirar por la nariz filtra el aire y estimula la liberación de óxido nítrico en los senos paranasales, mejorando la oxigenación.', source: 'Neumología Clínica'),
      HealthDailyTip(category: 'Colágeno y Vitamina C', quote: 'La vitamina C de los cítricos, el kiwi y los pimientos es un cofactor indispensable para la síntesis de colágeno en piel y articulaciones.', source: 'Dermatología y Bioquímica'),
      HealthDailyTip(category: 'Pausa Activa Circulatoria', quote: 'Ponerse de pie y moverse 2 minutos cada 45 minutos previene la estasis venosa en las piernas y reactiva el flujo sanguíneo cerebral.', source: 'Cirugía Vascular y Ergonomía'),
      HealthDailyTip(category: 'Serenidad y Coherencia Cardíaca', quote: 'Dedicar solo un minuto a sentir gratitud sincera reduce el cortisol y mejora la variabilidad de la frecuencia cardíaca (VFC).', source: 'Psicofisiología Clínica'),
    ],
    'de': [
      HealthDailyTip(category: 'Augengesundheit', quote: 'Nutzen Sie die 20-20-20-Regel gegen Augenmüdigkeit: Alle 20 Minuten 20 Sekunden lang mindestens 6 Meter in die Ferne blicken.', source: 'Ophthalmologie-Leitfaden'),
      HealthDailyTip(category: 'Blutdruck & Herz', quote: 'Ruhen Sie vor der Blutdruckmessung 5 Minuten ruhig, sprechen Sie nicht und halten Sie die Manschette auf Herzhöhe.', source: 'Kardiologie-Leitlinie'),
      HealthDailyTip(category: 'Stoffwechsel & Zucker', quote: 'Ein 15-minütiger Spaziergang 20–30 Minuten nach der Mahlzeit glättet Blutzuckerspitzen um bis zu 30 %.', source: 'Diabetologie-Studien'),
      HealthDailyTip(category: 'Hydratation & Vitalität', quote: 'Starten Sie den Tag mit einem Glas lauwarmem Wasser, um nächtliche Flüssigkeitsverluste auszugleichen und die Verdauung zu wecken.', source: 'Hydratations-Leitfaden'),
      HealthDailyTip(category: 'Zirkadianer Rhythmus', quote: '10–15 Minuten natürliches Morgenlicht in der ersten Stunde nach dem Aufstehen stellen Ihre innere Uhr optimal ein.', source: 'Chronobiologie-Forschung'),
      HealthDailyTip(category: 'Schlafhygiene', quote: 'Das Dimmen von Bildschirmen 1 Stunde vor dem Schlafen verkürzt die Einschlafzeit und schützt die Tiefschlafphasen.', source: 'Schlafmedizinische Gesellschaft'),
      HealthDailyTip(category: 'Mikrozirkulation', quote: 'Drücken Sie 3 Sekunden auf das Nagelbett; kehrt die rosa Farbe innerhalb von 2 Sekunden zurück, ist die Mikrozirkulation intakt.', source: 'Klinische Diagnostik'),
      HealthDailyTip(category: 'Atmung & Stressabbau', quote: 'Nutzen Sie den physiologischen Seufzer: Zweimal kurz durch die Nase einatmen, lange durch den Mund ausatmen; das beruhigt den Vagusnerv sofort.', source: 'Neurophysiologie'),
      HealthDailyTip(category: 'Haltung & Ergonomie', quote: 'Positionieren Sie die Bildschirmoberkante auf Augenhöhe; bereits 15 Grad Vorneigung belasten die Halswirbelsäule mit 12 kg Zusatzgewicht.', source: 'Ergonomie & Orthopädie'),
      HealthDailyTip(category: 'Herzgesunde Ernährung', quote: 'Weniger als 5 Gramm Salz täglich (ein Teelöffel) schützen die Gefäßelastizität und senken den Blutdruck nachweislich.', source: 'WHO & Kardiologie'),
      HealthDailyTip(category: 'Augenfeuchtigkeit', quote: 'Bildschirme verringern das Blinzeln um 60 %; blinzeln Sie bewusst mehrfach, um die Hornhaut mit Tränenfilm zu benetzen.', source: 'Trockenes-Auge-Leitlinie'),
      HealthDailyTip(category: 'Zunge & Verdauung', quote: 'Betrachten Sie morgens Ihre Zunge; ein dicker weißer Belag kann auf Dehydratation oder ein unausgeglichenes Mikrobiom hinweisen.', source: 'Klinische Inspektion'),
      HealthDailyTip(category: 'Achtsames Essen', quote: 'Jeden Bissen 20-mal zu kauen gibt Sättigungshormonen wie GLP-1 ausreichend Zeit, dem Gehirn das Sättigungssignal zu senden.', source: 'Ernährungsmedizin'),
      HealthDailyTip(category: 'Muskelstoffwechsel', quote: 'Wadenheben im Sitzen aktiviert den Soleus-Muskel und verbrennt effizient Blutzucker und Blutfette ohne Ermüdung.', source: 'Sport- und Stoffwechselphysiologie'),
      HealthDailyTip(category: 'Hydratationsanzeige', quote: 'Hell strohgelber Urin signalisiert ideale Flüssigkeitszufuhr; dunkles Bernstein fordert zum Trinken auf, farblos warnt vor Mineralverlust.', source: 'Nierenheilkunde'),
      HealthDailyTip(category: 'Darmmikrobiom', quote: 'Essen Sie wöchentlich 25–30 verschiedene pflanzliche Lebensmittel, um eine widerstandsfähige und gesunde Darmflora aufzubauen.', source: 'Mikrobiomforschung'),
      HealthDailyTip(category: 'Magnesium & Muskeln', quote: 'Dunkelgrünes Blattgemüse und Kürbiskerne sind reich an Magnesium; sie beugen nächtlichen Wadenkrämpfen vor und beruhigen die Nerven.', source: 'Klinische Ernährung'),
      HealthDailyTip(category: 'Hautturgor-Prüfung', quote: 'Haut am Handrücken sanft anheben und loslassen; schnellt sie sofort zurück, ist der Flüssigkeitsstatus der Zellen normal.', source: 'Klinische Diagnostik'),
      HealthDailyTip(category: 'Kardio-Mikrogewohnheiten', quote: 'Täglich 50–60 Stufen zu steigen ist eine der zeiteffizientesten Übungen, um das Herz-Kreislauf-Risiko spürbar zu senken.', source: 'Kardiologie-Forschung'),
      HealthDailyTip(category: 'Schlafumgebung & Temperatur', quote: 'Ein kühles Schlafzimmer (18–20 °C) unterstützt den nächtlichen Abfall der Körperkerntemperatur für erholsamen Tiefschlaf.', source: 'Schlafmedizinische Standards'),
      HealthDailyTip(category: 'Kalium & Gefäßgesundheit', quote: 'Kalium aus Spinat, Avocado und Bananen wirkt der gefäßverengenden Natriumwirkung entgegen und entspannt die Arterien.', source: 'Hypertonie-Leitlinie'),
      HealthDailyTip(category: 'Mentale Frische & Fokus', quote: 'Eine 5-minütige bildschirmfreie Pause alle 50 Minuten baut die Ermüdung des präfrontalen Kortex ab und schärft den Fokus.', source: 'Kognitive Neurowissenschaft'),
      HealthDailyTip(category: 'Zelluläre Autophagie', quote: 'Das Abendessen mindestens 3 Stunden vor dem Schlafen zu beenden senkt das Nachtinsulin und fördert die heilsame Autophagie.', source: 'Zellbiologie & Langlebigkeit'),
      HealthDailyTip(category: 'Vitamin D & Immunsystem', quote: '15 Minuten Mittagssonne auf Armen und Beinen regen die körpereigene Vitamin-D-Synthese für starke Knochen und Abwehrkräfte an.', source: 'Endokrinologische Gesellschaft'),
      HealthDailyTip(category: 'Mund- & Herzgesundheit', quote: 'Tägliche Zahnseide verhindert, dass parodontale Bakterien in den Blutkreislauf gelangen und Gefäßentzündungen anfeuern.', source: 'Parodontologie & Kardiologie'),
      HealthDailyTip(category: 'Koffein-Sperrstunde', quote: 'Koffein hat eine Halbwertszeit von 5–7 Stunden; nach 14:00 Uhr darauf zu verzichten sichert die Adenosin-Anreicherung für tiefen Schlaf.', source: 'Neuropharmakologie'),
      HealthDailyTip(category: 'Nasenatmung & Stickstoffmonoxid', quote: 'Nasenatmung filtert die Atemluft und setzt in den Nebenhöhlen gefäßerweiterndes Stickstoffmonoxid frei, das die Sauerstoffaufnahme steigert.', source: 'Pneumologie-Forschung'),
      HealthDailyTip(category: 'Kollagen & Vitamin C', quote: 'Vitamin C aus Zitrusfrüchten, Kiwi und Paprika ist ein unverzichtbarer Cofaktor der Kollagensynthese für elastische Haut und Gelenke.', source: 'Dermatologie & Biochemie'),
      HealthDailyTip(category: 'Aktive Gefäßpause', quote: 'Alle 45 Minuten 2 Minuten aufzustehen und sich zu bewegen verhindert venösen Blutstau in den Beinen und regt die Durchblutung an.', source: 'Gefäßchirurgie & Ergonomie'),
      HealthDailyTip(category: 'Mentale Ruhe & Herzharmonie', quote: 'Täglich eine Minute bewusste Dankbarkeit senkt das Stresshormon Cortisol und steigert die gesunde Herzratenvariabilität (HRV).', source: 'Psychophysiologie'),
    ],
    'sv': [
      HealthDailyTip(category: 'Ögonhälsa', quote: 'Följ 20-20-20-regeln för att minska ögontrötthet: var 20:e minut, titta 6 meter bort i 20 sekunder.', source: 'Ögonvårdsriktlinjer'),
      HealthDailyTip(category: 'Blodtryck & Hjärta', quote: 'Vila i 5 minuter före blodtrycksmätning hemma, sitt med stöd för ryggen, var tyst och håll manschetten i hjärthöjd.', source: 'Kardiologiska Riktlinjer'),
      HealthDailyTip(category: 'Ämnesomsättning & Glukos', quote: 'En lugn 15-minuterspromenad 20–30 minuter efter måltid dämpar blodsockertoppar med upp till 30 %.', source: 'Metabola Forskningsrön'),
      HealthDailyTip(category: 'Vätskestatus & Hälsa', quote: 'Börja dagen med ett glas rumstempererat vatten för att återställa nattens vätskeförlust och aktivera matsmältningen.', source: 'Njur- och Vätskeforskning'),
      HealthDailyTip(category: 'Cirkadisk Rytm', quote: 'Att få 10–15 minuters morgonljus inom en timme efter uppvaknandet ställer in kroppsklockan och främjar god nattsömn.', source: 'Sömnforskning'),
      HealthDailyTip(category: 'Sömnhygien', quote: 'Att dämpa skärmar en timme före läggdags minskar insomningstiden och bevarar den djupa återhämtande sömnen.', source: 'Sömnforskning och Neurologi'),
      HealthDailyTip(category: 'Cirkulationskontroll', quote: 'Tryck på nagelbädden i 3 sekunder; om den rosa färgen återvänder inom 2 sekunder fungerar din perifera cirkulation väl.', source: 'Klinisk Undersökningsguide'),
      HealthDailyTip(category: 'Andning & Stresskontroll', quote: 'Testa en fysiologisk suck: två snabba andetag in genom näsan följt av ett långt utandning genom munnen för att snabbt dämpa stress.', source: 'Neurofysiologiska Studier'),
      HealthDailyTip(category: 'Hållning & Ergonomi', quote: 'Placera bildskärmens överkant i ögonhöjd; att luta huvudet 15 grader framåt belastar nackkotorna med 12 kg extra vikt.', source: 'Ergonomi och Fysioterapi'),
      HealthDailyTip(category: 'Kardiovaskulär Kost', quote: 'Att hålla dagligt saltintag under 5 gram (en tesked) bevarar kärlelastisiteten och minskar belastningen på njurarna.', source: 'WHO & Kardiologi'),
      HealthDailyTip(category: 'Ögonfukt & Tårfilm', quote: 'Skärmanvändning minskar blinkandet med 60 %; blinka medvetet då och då för att smörja hornhinnan med en skyddande tårfilm.', source: 'Ögonläkarföreningen'),
      HealthDailyTip(category: 'Tunga & Matsmältning', quote: 'Inspektera tungan på morgonen; en kraftig vit beläggning kan tyda på vätskebrist eller obalans i mag-tarmkanalen.', source: 'Klinisk Undersökning'),
      HealthDailyTip(category: 'Medveten Måltid', quote: 'Att tugga varje tugga cirka 20 gånger ger mättnadshormoner som GLP-1 tid att signalera mättnad till hjärnan.', source: 'Gastroenterologisk Forskning'),
      HealthDailyTip(category: 'Muskelmetabolism', quote: 'Att göra sittande tåhävningar vid skrivbordet aktiverar soleusmuskeln och förbränner blodsocker utan att trötta ut kroppen.', source: 'Fysiologiska Studier'),
      HealthDailyTip(category: 'Vätskebalansindikator', quote: 'Ljus halmgul urin indikerar optimal vätskebalans; mörk bärnsten signalerar vätskebrist, medan helt klar urin varnar för mineralspädning.', source: 'Njurmedicinska Riktlinjer'),
      HealthDailyTip(category: 'Tarmens Mikrobiom', quote: 'Sikta på 25–30 olika växtbaserade råvaror i veckan (grönsaker, frön, baljväxter) för att stärka immunförsvarets tarmbakterier.', source: 'Mikrobiomstudier'),
      HealthDailyTip(category: 'Magnesium & Återhämtning', quote: 'Mörkgröna bladgrönsaker och pumpakärnor är rika på magnesium som förebygger nattliga kramper och lugnar nervsystemet.', source: 'Näringsfysiologi'),
      HealthDailyTip(category: 'Hudturgor & Elasticitet', quote: 'Nyp försiktigt huden på handryggen och släpp; att den genast återgår visar på god cellulär vätskebalans.', source: 'Klinisk Statuskontroll'),
      HealthDailyTip(category: 'Kardiovaskulär Vardagsmotion', quote: 'Att gå i 50–60 trappsteg dagligen är ett av de mest tidseffektiva sätten att stärka hjärtat och sänka kärlrisker.', source: 'Kardiologisk Forskning'),
      HealthDailyTip(category: 'Sömnmiljö & Temperatur', quote: 'Ett svalt sovrum (18–20 °C) underlättar kroppens naturliga temperatursänkning som krävs för djup återhämtande sömn.', source: 'Sömnforskning'),
      HealthDailyTip(category: 'Kalium & Kärlhälsa', quote: 'Kalium från spenat, avokado och bananer motverkar natriums kärlsammandragande effekt och stödjer jämnt blodtryck.', source: 'Hypertoni Riktlinjer'),
      HealthDailyTip(category: 'Mental Återhämtning', quote: 'Att ta 5 minuters skärmfri paus var 50:e minut rensar hjärntrötthet i pannloben och bibehåller knivskarp koncentration.', source: 'Kognitiv Neurovetenskap'),
      HealthDailyTip(category: 'Cellulär Autofagi', quote: 'Att avsluta middagen minst 3 timmar före läggdags sänker nattligt insulin och aktiverar cellernas egen rengöring.', source: 'Cellbiologi & Livslängd'),
      HealthDailyTip(category: 'D-vitamin & Benhälsa', quote: 'Att exponera armar och ben för 15 minuters solljus mitt på dagen sätter igång hudens D-vitaminsyntes för starka ben och immunförsvar.', source: 'Endokrinologiska Riktlinjer'),
      HealthDailyTip(category: 'Mun- och Hjärtanslutning', quote: 'Daglig tandtråd avlägsnar bakterier under tandköttskanten och hindrar dem från att nå blodomloppet och skada kärlen.', source: 'Tandvård och Kardiologi'),
      HealthDailyTip(category: 'Koffeinstopp', quote: 'Koffein har en halveringstid på 5–7 timmar; att sluta dricka kaffe efter kl. 14 hjälper hjärnan att bygga upp naturlig sömntryck.', source: 'Neurofarmakologi'),
      HealthDailyTip(category: 'Näsandning & Kväveoxid', quote: 'Att andas genom näsan renar och värmer luften samt frigör kväveoxid från bihålorna, vilket optimerar lungornas syreupptag.', source: 'Lungmedicinsk Forskning'),
      HealthDailyTip(category: 'Kollagen & C-vitamin', quote: 'C-vitamin från citrus, kiwi och paprika är ett nödvändigt enzymatiskt stöd för kroppens kollagensyntes i hud och leder.', source: 'Dermatologi & Biokemi'),
      HealthDailyTip(category: 'Kärlhälsa & Rörelsepaus', quote: 'Att resa sig och röra på sig i 2 minuter var 45:e minut bryter venös stas i benen och ökar syresättningen till hjärnan.', source: 'Kärlkirurgi och Ergonomi'),
      HealthDailyTip(category: 'Sinnesro & Hjärtvariabilitet', quote: 'Att ägna en minut om dagen åt tacksamhet sänker stresshormonet kortisol och höjer en hälsosam hjärtfrekvensvariabilitet (HRV).', source: 'Psykofysiologisk Forskning'),
    ],
    'fr': [
      HealthDailyTip(category: 'Santé Oculaire', quote: 'Adoptez la règle des 20-20-20 contre la fatigue visuelle : toutes les 20 minutes, regardez à 6 mètres pendant 20 secondes.', source: 'Guide d\'Ophtalmologie'),
      HealthDailyTip(category: 'Tension Artérielle', quote: 'Reposez-vous 5 minutes avant de mesurer votre tension à domicile, sans parler et en maintenant le brassard à hauteur du cœur.', source: 'Consensus de Cardiologie'),
      HealthDailyTip(category: 'Métabolisme & Glycémie', quote: 'Une marche légère de 15 minutes 20 à 30 minutes après le repas réduit les pics de glycémie jusqu\'à 30 %.', source: 'Recherche Métabolique'),
      HealthDailyTip(category: 'Hydratation & Énergie', quote: 'Boire un verre d\'eau tiède au réveil compense les pertes nocturnes et relance en douceur le système digestif.', source: 'Santé Rénale et Hydratation'),
      HealthDailyTip(category: 'Rythme Circadien', quote: 'S\'exposer 10 à 15 minutes à la lumière naturelle dès le réveil synchronise votre horloge biologique pour la nuit suivante.', source: 'Chronobiologie et Sommeil'),
      HealthDailyTip(category: 'Hygiène du Sommeil', quote: 'Éteindre ou tamiser les écrans 1 heure avant le coucher accélère l\'endormissement et préserve le sommeil réparateur.', source: 'Médecine du Sommeil'),
      HealthDailyTip(category: 'Microcirculation', quote: 'Pressez votre ongle pendant 3 secondes : le retour de la coloration rose en moins de 2 secondes indique une bonne circulation capillaire.', source: 'Examen Clinique Médical'),
      HealthDailyTip(category: 'Respiration & Sérénité', quote: 'Pratiquez le soupir physiologique : deux inspirations nasales suivies d\'une longue expiration buccale apaisent instantanément le nerf vague.', source: 'Neurophysiologie du Stress'),
      HealthDailyTip(category: 'Posture & Ergonomie', quote: 'Alignez le haut de l\'écran avec vos yeux : incliner la tête de 15 degrés vers l\'avant impose 12 kg de charge supplémentaire aux cervicales.', source: 'Ergonomie et Kinésithérapie'),
      HealthDailyTip(category: 'Nutrition Cardiovasculaire', quote: 'Limiter le sel à moins de 5 g par jour (une cuillère à café) préserve la souplesse artérielle et protège les reins.', source: 'OMS & Cardiologie'),
      HealthDailyTip(category: 'Hydratation Oculaire', quote: 'L\'écran réduit le clignement de 60 % ; clignez délibérément des yeux pour renouveler le film lacrymal sur la cornée.', source: 'Société Française d\'Ophtalmologie'),
      HealthDailyTip(category: 'Langue & Digestion', quote: 'Observez votre langue au réveil : un enduit blanc épais peut signaler une déshydratation ou un déséquilibre digestif.', source: 'Examen Visuel Médical'),
      HealthDailyTip(category: 'Alimentation Consciente', quote: 'Mâcher chaque bouchée 20 fois laisse le temps aux hormones de satiété (GLP-1, leptine) de signaler la réplétion au cerveau.', source: 'Gastro-entérologie'),
      HealthDailyTip(category: 'Métabolisme Musculaire', quote: 'Effectuer des flexions plantaires assis stimule le muscle soléaire, brûlant sucres et lipides sans fatigue générale.', source: 'Physiologie de l\'Exercice'),
      HealthDailyTip(category: 'Indicateur d\'Hydratation', quote: 'Une urine jaune paille traduit une hydratation idéale ; une teinte ambrée réclame de l\'eau, tandis qu\'une urine incolore peut diluer vos sels.', source: 'Standards de Néphrologie'),
      HealthDailyTip(category: 'Microbiote Intestinal', quote: 'Consommer 25 à 30 végétaux différents chaque semaine (graines, légumes, légumineuses) diversifie la flore et booste l\'immunité.', source: 'Recherche sur le Microbiote'),
      HealthDailyTip(category: 'Magnésium & Détente', quote: 'Les légumes à feuilles sombres et graines de courge sont riches en magnésium, prévenant les crampes et apaisant les nerfs.', source: 'Nutrition Médicale'),
      HealthDailyTip(category: 'Turgor Cutané', quote: 'Pincez doucement la peau sur le dos de la main et relâchez : un retour élastique instantané confirme une hydratation cellulaire saine.', source: 'Examen Physique Médical'),
      HealthDailyTip(category: 'Micro-Exercices Cardio', quote: 'Monter 50 à 60 marches par jour constitue un micro-exercice ultra-rapide pour stimuler le cœur et préserver les artères.', source: 'Recherche Cardiologique'),
      HealthDailyTip(category: 'Environnement du Sommeil', quote: 'Maintenir la chambre entre 18 et 20 °C favorise la baisse thermique corporelle indispensable au sommeil profond réparateur.', source: 'Standards de Médecine du Sommeil'),
      HealthDailyTip(category: 'Potassium & Vaisseaux', quote: 'Le potassium des épinards, avocats et bananes neutralise l\'effet vasoconstricteur du sodium et détend les parois artérielles.', source: 'Consensus sur l\'Hypertension'),
      HealthDailyTip(category: 'Focus Cérébral & Pause', quote: 'Prendre 5 minutes de pause sans écran toutes les 50 minutes dissipe la fatigue du cortex préfrontal et renforce la clarté mentale.', source: 'Neurosciences Cognitives'),
      HealthDailyTip(category: 'Autophagie Cellulaire', quote: 'Finir de dîner au moins 3 heures avant le coucher abaisse l\'insuline nocturne, déclenchant l\'autophagie et la régénération tissulaire.', source: 'Biologie Cellulaire & Longévité'),
      HealthDailyTip(category: 'Vitamine D & Immunité', quote: 'Exposer bras et jambes au soleil 15 minutes à midi déclenche la synthèse de vitamine D, cruciale pour les os et les défenses.', source: 'Société d\'Endocrinologie'),
      HealthDailyTip(category: 'Lien Bouche-Cœur', quote: 'Passer le fil dentaire chaque jour empêche les bactéries gingivales de passer dans le sang et d\'enflammer la paroi artérielle.', source: 'Parodontologie et Cardiologie'),
      HealthDailyTip(category: 'Couvre-Feu Caféine', quote: 'La caféine persistant 5 à 7 heures dans l\'organisme, cesser sa consommation après 14h préserve la pression de sommeil naturelle.', source: 'Neuropharmacologie'),
      HealthDailyTip(category: 'Respiration Nasale & Oxygène', quote: 'Respirer par le nez filtre l\'air et libère du monoxyde d\'azote dans les sinus, optimisant l\'oxygénation pulmonaire.', source: 'Pneumologie Clinique'),
      HealthDailyTip(category: 'Collagène & Vitamine C', quote: 'La vitamine C des agrumes, kiwis et poivrons est un cofacteur clé de la synthèse du collagène, garantissant la souplesse de la peau.', source: 'Dermatologie et Biochimie'),
      HealthDailyTip(category: 'Pause Active Vasculaire', quote: 'Se lever et bouger 2 minutes toutes les 45 minutes évite la stase veineuse dans les jambes et réactive le flux sanguin cérébral.', source: 'Chirurgie Vasculaire'),
      HealthDailyTip(category: 'Sérénité & Cohérence Cardiaque', quote: 'Consacrer une minute à la gratitude sincère fait baisser le cortisol et optimise la variabilité de la fréquence cardiaque (VFC).', source: 'Psychophysiologie Clinique'),
    ],
    'it': [
      HealthDailyTip(category: 'Salute Oculare', quote: 'Segui la regola 20-20-20 contro l\'affaticamento visivo: ogni 20 minuti, guarda a 6 metri di distanza per 20 secondi.', source: 'Linee Guida Oculistiche'),
      HealthDailyTip(category: 'Pressione & Cuore', quote: 'Riposa 5 minuti prima di misurare la pressione a casa, non parlare e mantieni il bracciale all\'altezza del cuore.', source: 'Linee Guida Cardiologiche'),
      HealthDailyTip(category: 'Metabolismo & Glicemia', quote: 'Una camminata di 15 minuti 20-30 minuti dopo i pasti riduce i picchi glicemici post-prandiali fino al 30%.', source: 'Consorzio Diabetologico'),
      HealthDailyTip(category: 'Idratazione & Vitalità', quote: 'Iniziare la giornata con un bicchiere d\'acqua a temperatura ambiente reidrata il corpo e attiva dolcemente la digestione.', source: 'Fisiologia dell\'Idratazione'),
      HealthDailyTip(category: 'Ritmo Circadiano', quote: 'Esporsi alla luce solare per 10-15 minuti entro un\'ora dal risveglio sincronizza l\'orologio biologico e migliora il sonno notturno.', source: 'Cronobiologia Clinica'),
      HealthDailyTip(category: 'Igiene del Sonno', quote: 'Ridurre l\'uso degli schermi 1 ora prima di coricarsi accorcia i tempi di addormentamento e migliora la qualità del sonno profondo.', source: 'Medicina del Sonno'),
      HealthDailyTip(category: 'Microcircolo & Unghie', quote: 'Premi il letto ungueale per 3 secondi; il ritorno del colore rosa entro 2 secondi indica una microcircolazione periferica sana.', source: 'Guida all\'Esame Obiettivo'),
      HealthDailyTip(category: 'Respiro & Rilassamento', quote: 'Prova il sospiro fisiologico: due inspirazioni dal naso e una lunga espirazione dalla bocca per attivare subito il nervo vago e placare l\'ansia.', source: 'Neurofisiologia Clinica'),
      HealthDailyTip(category: 'Postura & Ergonomia', quote: 'Allinea la parte superiore dello schermo agli occhi; inclinare la testa in avanti di soli 15 gradi carica il collo di ben 12 kg extra.', source: 'Ergonomia & Ortopedia'),
      HealthDailyTip(category: 'Nutrizione & Cuore', quote: 'Mantenere il sale sotto i 5 grammi al giorno protegge l\'elasticità arteriosa e riduce significativamente la pressione alta.', source: 'OMS & Società di Cardiologia'),
      HealthDailyTip(category: 'Film Lacrimale', quote: 'Davanti allo schermo l\'ammiccamento cala del 60%; batti le palpebre consapevolmente per idratare e proteggere la cornea.', source: 'Oftalmologia Clinica'),
      HealthDailyTip(category: 'Lingua & Digestione', quote: 'Osserva la lingua al mattino; una patina bianca densa può indicare disidratazione, respirazione orale o squilibrio digestivo.', source: 'Semeiotica Medica'),
      HealthDailyTip(category: 'Nutrizione Consapevole', quote: 'Masticare ogni boccone circa 20 volte consente agli ormoni della sazietà come il GLP-1 di comunicare la pienezza al cervello.', source: 'Gastroenterologia Clinica'),
      HealthDailyTip(category: 'Metabolismo Muscolare', quote: 'Sollevare i talloni da seduti attiva il muscolo soleo, accelerando il consumo di glucosio ematico senza affaticamento.', source: 'Fisiologia del Movimento'),
      HealthDailyTip(category: 'Indice di Idratazione', quote: 'L\'urina giallo paglierino indica idratazione perfetta; l\'ambra scuro segnala carenza d\'acqua, mentre l\'urina limpida diluizione minerale.', source: 'Nefrologia Clinica'),
      HealthDailyTip(category: 'Microbiota Intestinale', quote: 'Consumare 25-30 alimenti vegetali diversi a settimana (frutta, verdura, semi, legumi) fortifica la flora intestinale e le difese immunitarie.', source: 'Scienze del Microbioma'),
      HealthDailyTip(category: 'Magnesio & Muscoli', quote: 'Spinaci e semi di zucca sono ricchi di magnesio, prezioso per prevenire crampi notturni e favorire il rilassamento neuromuscolare.', source: 'Nutrizione Clinica'),
      HealthDailyTip(category: 'Turgore Cutaneo', quote: 'Solleva delicatamente la pelle sul dorso della mano e rilasciala; il ritorno immediato conferma un\'ottima idratazione cellulare.', source: 'Semeiotica Fisica'),
      HealthDailyTip(category: 'Micro-Abitudini Cardio', quote: 'Salire 50-60 gradini al giorno è uno degli esercizi più veloci ed efficaci per rafforzare il cuore e ridurre il rischio cardiovascolare.', source: 'Ricerca Cardiologica'),
      HealthDailyTip(category: 'Temperatura & Sonno Profondo', quote: 'Una camera fresca a 18-20°C agevola il naturale calo della temperatura corporea necessario per entrare nel sonno profondo.', source: 'Linee Guida sul Sonno'),
      HealthDailyTip(category: 'Potassio & Pressione', quote: 'Il potassio di spinaci, avocado e banane contrasta la vasocostrizione da sodio, favorendo arterie elastiche e rilassate.', source: 'Consenso Ipertensione'),
      HealthDailyTip(category: 'Focus Mentale & Reset', quote: 'Una pausa di 5 minuti lontano dagli schermi ogni 50 minuti azzera l\'affaticamento della corteccia prefrontale e riduce gli errori.', source: 'Neuroscienze Cognitive'),
      HealthDailyTip(category: 'Autofagia Cellulare', quote: 'Cenare almeno 3 ore prima di dormire abbassa l\'insulina notturna, innescando l\'autofagia e il rinnovamento cellulare.', source: 'Biologia Cellulare & Longevità'),
      HealthDailyTip(category: 'Vitamina D & Ossa', quote: 'Esporre braccia e gambe al sole per 15 minuti attiva la sintesi cutanea di vitamina D, fondamentale per le ossa e l\'immunità.', source: 'Società di Endocrinologia'),
      HealthDailyTip(category: 'Connessione Denti-Cuore', quote: 'Usare il filo interdentale ogni giorno impedisce ai batteri gengivali di entrare in circolo e infiammare i vasi sanguigni.', source: 'Parodontologia e Cardiologia'),
      HealthDailyTip(category: 'Stop Caffeina', quote: 'Con un\'emivita di 5-7 ore, evitare la caffeina dopo le 14:00 permette all\'adenosina di accumularsi per un sonno davvero ristoratore.', source: 'Neurofarmacologia'),
      HealthDailyTip(category: 'Respirazione Nasale & Ossigeno', quote: 'Respirare con il naso filtra l\'aria e stimola il rilascio di ossido nitrico dai seni paranasali, migliorando l\'ossigenazione.', source: 'Pneumologia Clinica'),
      HealthDailyTip(category: 'Collagene & Vitamina C', quote: 'La vitamina C di agrumi, kiwi e peperoni è il cofattore essenziale per la sintesi del collagene di pelle e articolazioni.', source: 'Dermatologia & Biochimica'),
      HealthDailyTip(category: 'Pausa Attiva & Circolazione', quote: 'Alzarsi e muoversi per 2 minuti ogni 45 minuti elimina il ristagno venoso nelle gambe e riattiva il flusso cerebrale.', source: 'Chirurgia Vascolare & Ergonomia'),
      HealthDailyTip(category: 'Serenità & Coerenza Cardiaca', quote: 'Praticare un minuto di sincera gratitudine al giorno abbassa il cortisolo e migliora la variabilità della frequenza cardiaca (HRV).', source: 'Psicofisiologia Clinica'),
    ],
    'nl': [
      HealthDailyTip(category: 'Ooggezondheid', quote: 'Pas de 20-20-20-regel toe tegen vermoeide ogen: kijk elke 20 minuten minstens 20 seconden naar 6 meter afstand.', source: 'Oogheelkundige Richtlijnen'),
      HealthDailyTip(category: 'Bloeddruk & Hart', quote: 'Rust 5 minuten vóór het meten van je bloeddruk thuis, praat niet en houd de manchet op harthoogte.', source: 'Cardiologie Richtlijnen'),
      HealthDailyTip(category: 'Metabolisme & Glucose', quote: 'Een lichte wandeling van 15 minuten, 20 tot 30 minuten na de maaltijd, verlaagt bloedsuikerpieken tot 30%.', source: 'Diabetologie Onderzoek'),
      HealthDailyTip(category: 'Hydratatie & Vitaliteit', quote: 'Begin de ochtend met een glas lauw water om het nachtelijke vochtverlies aan te vullen en je darmen te activeren.', source: 'Nier- en Hydratatiewetenschap'),
      HealthDailyTip(category: 'Circadiaans Ritme', quote: 'Stel jezelf in het eerste uur na het opstaan 10 tot 15 minuten bloot aan natuurlijk ochtendlicht om je biologische klok te kalibreren.', source: 'Slaap- en Chronobiologie'),
      HealthDailyTip(category: 'Slaaphygiëne', quote: 'Het dimmen van schermen 1 uur voor het slapengaan verkort de inslaaptijd en bevordert diepe herstellende slaap.', source: 'Slaapgeneeskunde'),
      HealthDailyTip(category: 'Microcirculatie', quote: 'Druk 3 seconden op je nagelbed; keert de roze kleur binnen 2 seconden terug, dan is je perifere doorbloeding gezond.', source: 'Klinische Diagnostiek'),
      HealthDailyTip(category: 'Ademhaling & Stress', quote: 'Probeer een fysiologische zucht: twee keer diep inademen door de neus en langzaam uitademen via de mond kalmeert direct het zenuwstelsel.', source: 'Neurofysiologie'),
      HealthDailyTip(category: 'Houding & Ergonomie', quote: 'Plaats de bovenkant van je scherm op ooghoogte; je hoofd 15 graden buigen belast je nek met maar liefst 12 kg extra gewicht.', source: 'Ergonomie & Fysiotherapie'),
      HealthDailyTip(category: 'Cardiovasculaire Voeding', quote: 'Beperk zoutinname tot minder dan 5 gram per dag (één theelepel) om je bloedvaten soepel te houden en je nieren te sparen.', source: 'WHO & Cardiologie'),
      HealthDailyTip(category: 'Ooghydratatie', quote: 'Schermtijd verlaagt knipperen met 60%; knipper bewust een paar keer om een verse traanfilm over het hoornvlies te leggen.', source: 'Oogheelkundig Forum'),
      HealthDailyTip(category: 'Tong & Spijsvertering', quote: 'Bekijk \'s ochtends je tong; een dikke witte aanslag kan duiden op uitdroging of een verstoorde darmbalans.', source: 'Visuele Diagnostiek'),
      HealthDailyTip(category: 'Aandachtig Eten', quote: 'Kauw elke hap zo\'n 20 keer; dit geeft verzadigingshormonen zoals GLP-1 de tijd om je hersenen te laten weten dat je vol zit.', source: 'Voedingswetenschap'),
      HealthDailyTip(category: 'Spiermetabolisme', quote: 'Zittend kuitheffen activeert de soleusspier, wat helpt bloedsuiker en triglyceriden efficiënt te verbranden achter je bureau.', source: 'Bewegingswetenschappen'),
      HealthDailyTip(category: 'Vochtniveau Indicator', quote: 'Licht strogeel toont optimale hydratatie; donker amber vraagt om water, en kleurloos wijst op mogelijke mineraalverdunning.', source: 'Niergeneeskunde'),
      HealthDailyTip(category: 'Darmmicrobioom', quote: 'Streef naar 25 tot 30 verschillende plantaardige bronnen per week (groenten, zaden, peulvruchten) voor een gezonde en sterke darmflora.', source: 'Microbioomonderzoek'),
      HealthDailyTip(category: 'Magnesium & Herstel', quote: 'Donkergroene bladgroenten en pompoenpitten bevatten veel magnesium; dit voorkomt nachtelijke krampen en kalmeert het zenuwstelsel.', source: 'Klinische Voedingsleer'),
      HealthDailyTip(category: 'Huidelasticiteit (Turgor)', quote: 'Knijp zachtjes in de huid op je handrug en laat los; veert deze direct terug, dan zijn je cellen goed gehydrateerd.', source: 'Klinische Fysiologie'),
      HealthDailyTip(category: 'Cardio Micro-Gewoonten', quote: 'Het beklimmen van 50 tot 60 traptreden per dag is een van de snelste manieren om je hart te versterken en vaatrisico\'s te verlagen.', source: 'Cardiovasculair Onderzoek'),
      HealthDailyTip(category: 'Slaapkamertemperatuur', quote: 'Een koele slaapkamer van 18 tot 20 °C helpt je lichaamstemperatuur te laten dalen, wat cruciaal is voor diepe herstellende slaap.', source: 'Slaapgeneeskunde'),
      HealthDailyTip(category: 'Kalium & Bloedvaten', quote: 'Kalium uit spinazie, avocado en bananen compenseert het vaatvernauwende effect van natrium en helpt je bloeddruk te verlagen.', source: 'Hypertensie Richtlijnen'),
      HealthDailyTip(category: 'Mentale Focus & Reset', quote: 'Neem elke 50 minuten een schermvrije pauze van 5 minuten om mentale vermoeidheid tegen te gaan en je focus scherp te houden.', source: 'Cognitieve Neurowetenschappen'),
      HealthDailyTip(category: 'Cellulaire Autofagie', quote: 'Eet je avondmaaltijd minstens 3 uur voor het slapengaan om \'s nachts de insuline te verlagen en cellulaire autofagie te activeren.', source: 'Celbiologie & Levensduur'),
      HealthDailyTip(category: 'Vitamine D & Weerstand', quote: 'Stel armen en benen rond het middaguur 15 minuten bloot aan de zon voor natuurlijke vitamine D-aanmaak voor sterke botten.', source: 'Endocrinologie Richtlijnen'),
      HealthDailyTip(category: 'Mond-Hart Verbinding', quote: 'Dagelijks flossen voorkomt dat tandvleesbacteriën in de bloedbaan terechtkomen en ontstekingen aan de vaatwanden veroorzaken.', source: 'Parodontologie & Cardiologie'),
      HealthDailyTip(category: 'Cafeïne Limiet', quote: 'Cafeïne heeft een halfwaardetijd van 5 tot 7 uur; stop na 14:00 uur met koffie om voldoende adenosinedruk op te bouwen voor de nacht.', source: 'Neurofarmacologie'),
      HealthDailyTip(category: 'Neusademhaling & Stikstofmonoxide', quote: 'Door de neus ademen filtert lucht en stimuleert stikstofmonoxide in de bijholten, wat de zuurstofopname in de longen verbetert.', source: 'Longgeneeskunde'),
      HealthDailyTip(category: 'Collageen & Vitamine C', quote: 'Vitamine C uit citrusvruchten, kiwi en paprika is een onmisbare cofactor voor collageensynthese voor elastische huid en gewrichten.', source: 'Dermatologie & Biochemie'),
      HealthDailyTip(category: 'Actieve Vaatpauze', quote: 'Elke 45 minuten 2 minuten opstaan en bewegen doorbreekt veneuze stuwing in de benen en stimuleert de bloedtoevoer naar het brein.', source: 'Vaatchirurgie & Ergonomie'),
      HealthDailyTip(category: 'Mentale Rust & Hartcoherentie', quote: 'Slechts één minuut oprechte dankbaarheid per dag verlaagt het stresshormoon cortisol en verhoogt je hartritmevariabiliteit (HRV).', source: 'Psychofysiologisch Onderzoek'),
    ],
    'ar': [
      HealthDailyTip(category: 'صحة العيون', quote: 'طبق قاعدة 20-20-20 لتخفيف إجهاد العين: كل 20 دقيقة، انظر إلى مسافة 6 أمتار لمدة 20 ثانية.', source: 'إرشادات طب العيون'),
      HealthDailyTip(category: 'ضغط الدم والقلب', quote: 'استرح لمدة 5 دقائق قبل قياس ضغط الدم في المنزل، وتجنب التحدث، واجعل السوار في مستوى القلب تماماً.', source: 'توصيات أطباء القلب'),
      HealthDailyTip(category: 'الأيض والسكر', quote: 'المشي الخفيف لمدة 15 دقيقة بعد الوجبات بـ 20-30 دقيقة يخفف من ارتفاع سكر الدم بنسبة تصل إلى 30%.', source: 'دراسات الغدد الصماء'),
      HealthDailyTip(category: 'الترطيب والنشاط', quote: 'بدء اليوم بكوب ماء فاتر يعوض السوائل المفقودة ليلاً وينشط الجهاز الهضمي برفق وحيوية.', source: 'صحة الكلى والترطيب'),
      HealthDailyTip(category: 'الساعة البيولوجية', quote: 'التعرض لأشعة الشمس الطبيعية لمدة 10-15 دقيقة بعد الاستيقاظ يضبط ساعتك البيولوجية ويعزز إفراز الميلاتونين ليلاً.', source: 'أبحاث النوم والبيولوجيا'),
      HealthDailyTip(category: 'جودة النوم والراحة', quote: 'تخفيف إضاءة الشاشات قبل النوم بساعة يسرع الاستغراق في النوم ويحمي مراحل النوم العميق والترميمي.', source: 'طب الأعصاب والنوم'),
      HealthDailyTip(category: 'الدورة الدموية الدقيقة', quote: 'اضغط على ظفرك لثلاث ثوانٍ؛ استعادة اللون الوردي خلال ثانيتين دليل على سلامة الدورة الدموية الطرفية.', source: 'دليل الفحص السريري'),
      HealthDailyTip(category: 'التنفس والسكينة', quote: 'جرب التنهد الفسيولوجي: شهيقان سريعان من الأنف متبوعان بزفير طويل وبطيء من الفم لتهدئة الجهاز العصبي والنبض فوراً.', source: 'علم وظائف الأعصاب'),
      HealthDailyTip(category: 'وضعية الجلوس والظهر', quote: 'اجعل الحافة العلوية لشاشتك في مستوى عينيك؛ انحناء الرقبة للأمام بـ 15 درجة فقط يضيف حملاً مقداره 12 كجم على فقرات العنق.', source: 'طب العظام والوقاية'),
      HealthDailyTip(category: 'صحة القلب والتغذية', quote: 'الحفاظ على استهلاك الملح اليومي أقل من 5 غرامات (ملعقة شاي) يحمي مرونة الشرايين ويخفف العبء عن الكلى.', source: 'منظمة الصحة العالمية'),
      HealthDailyTip(category: 'ترطيب العين والقرنية', quote: 'يقل معدل الرمش أمام الشاشات بنسبة 60%؛ ارمش بوعي عدة مرات لتجديد الطبقة الدمعية وحماية القرنية من الجفاف.', source: 'إرشادات جفاف العين'),
      HealthDailyTip(category: 'فحص اللسان والهضم', quote: 'تفحص لسانك صباحاً في المرآة؛ وجود طبقة بيضاء سميكة قد يشير إلى نقص السوائل أو اضطراب في الجهاز الهضمي.', source: 'دليل الفحص السريري'),
      HealthDailyTip(category: 'التغذية الواعية والامتلاء', quote: 'مضغ اللقمة 20 مرة يمنح هرمونات الشبع مثل GLP-1 وقتاً كافياً لإرسال إشارات الامتلاء إلى الدماغ لتجنب الإفراط.', source: 'صحة الجهاز الهضمي'),
      HealthDailyTip(category: 'الأيض العضلي والنشاط', quote: 'رفع الكعبين أثناء الجلوس في المكتب ينشط عضلة الساق النعلية، مما يسرع حرق سكر الدم دون التسبب في إجهاد عام.', source: 'أبحاث فسيولوجيا الحركة'),
      HealthDailyTip(category: 'مؤشر الترطيب والبول', quote: 'لون البول الأصفر القشي الفاتح دليل على الترطيب المثالي؛ اللون الداكن ينبهك لشرب الماء، والشفاف تماماً قد يعني تمدد المعادن.', source: 'معايير طب الكلى'),
      HealthDailyTip(category: 'ميكروبيوم الأمعاء والمناعة', quote: 'تناول 25-30 صنفاً نباتياً متنوعاً أسبوعياً (خضار، بذور، بقوليات، فواكه) يغذي بكتيريا الأمعاء النافعة ويعزز المناعة.', source: 'أبحاث صحة الميكروبيوم'),
      HealthDailyTip(category: 'المغنيسيوم واسترخاء العضلات', quote: 'الخضروات الورقية الداكنة وبذور اليقطين غنية بالمغنيسيوم الضروري للوقاية من تشنجات الساق وتهدئة الجهاز العصبي.', source: 'التغذية العلاجية'),
      HealthDailyTip(category: 'مرونة الجلد وترطيب الخلايا', quote: 'ارفع جلد ظهر يدك برفق ثم اتركه؛ عودته السريعة لمكانه تؤكد كفاية السوائل داخل الخلايا ومرونة الأنسجة.', source: 'الفحص الطبي السريري'),
      HealthDailyTip(category: 'صعود الدرج وصحة القلب', quote: 'صعود 50-60 درجة يومياً من أفضل التمارين المصغرة الفعالة لتنشيط عضلة القلب والوقاية من النوبات القلبية.', source: 'أبحاث أمراض القلب'),
      HealthDailyTip(category: 'حرارة الغرفة وجودة النوم', quote: 'الحفاظ على غرفة نوم باردة عند 18-20 درجة مئوية يساعد على انخفاض حرارة الجسم الطبيعي للدخول في النوم العميق.', source: 'معايير طب النوم'),
      HealthDailyTip(category: 'البوتاسيوم وتمدد الشرايين', quote: 'البوتاسيوم الموجود في السبانخ والأفوكادو والموز يبطل تأثير الصوديوم المسبب لضيق الأوعية، مما يريح الشرايين.', source: 'إرشادات ضغط الدم'),
      HealthDailyTip(category: 'التركيز الذهني والراحة', quote: 'أخذ استراحة مدتها 5 دقائق بعيداً عن الشاشات كل 50 دقيقة يزيل إرهاق الفص الجبهي للدماغ ويجدد التركيز الذهني.', source: 'علوم الأعصاب الإدراكية'),
      HealthDailyTip(category: 'التنظيف الخلوي (الأوتوفاجي)', quote: 'إنهاء وجبة العشاء قبل النوم بثلاث ساعات على الأقل يخفض الأنسولين ليلاً ويحفز الالتهام الذاتي لتجديد الخلايا.', source: 'بيولوجيا الخلية وطول العمر'),
      HealthDailyTip(category: 'فيتامين د والمناعة', quote: 'تعريض الذراعين والساقين لأشعة الشمس لمدة 15 دقيقة نهاراً يحفز تصنيع فيتامين د الضروري لقوة العظام ومناعة الجسم.', source: 'جمعية الغدد الصماء'),
      HealthDailyTip(category: 'صحة الفم وحماية القلب', quote: 'استخدام خيط الأسنان يومياً يمنع بكتيريا اللثة من التسرب إلى مجرى الدم وإحداث التهابات في بطانة الشرايين.', source: 'طب الأسنان وأمراض القلب'),
      HealthDailyTip(category: 'موعد إيقاف الكافيين', quote: 'نصف عمر الكافيين في الجسم يمتد من 5 إلى 7 ساعات؛ التوقف عن القهوة بعد الثانية ظهراً يضمن تراكم الأدينوسين لنوم مريح.', source: 'علم الأدوية العصبية'),
      HealthDailyTip(category: 'التنفس الأنفي وأكسيد النيتريك', quote: 'التنفس من الأنف ينقي الهواء ويحفز إفراز أكسيد النيتريك في الجيوب الأنفية، مما يرفع كفاءة امتصاص الأكسجين في الرئتين.', source: 'أبحاث طب الرئة'),
      HealthDailyTip(category: 'الكولاجين وفيتامين سي', quote: 'فيتامين سي في الحمضيات والكيوي والفلفل محفز إنزيمي لا غنى عنه لتخليق الكولاجين والحفاظ على نضارة البشرة والمفاصل.', source: 'طب الجلدية والكيمياء الحيوية'),
      HealthDailyTip(category: 'الراحة الحركية وتدفق الدم', quote: 'الوقوف والحركة لمدة دقيقتين كل 45 دقيقة من الجلوس يمنع ركود الدم في أوردة الساقين وينشط التروية الدماغية.', source: 'جراحة الأوعية الدموية'),
      HealthDailyTip(category: 'السكينة النفسية وصحة القلب', quote: 'ممارسة الامتنان الصادق لدقيقة واحدة يومياً تخفض هرمون التوتر (الكورتيزول) وترفع تباين نبضات القلب الإيجابي (HRV).', source: 'أبحاث علم وظائف النفس'),
    ],
    'bn': [
      HealthDailyTip(category: 'চোখের স্বাস্থ্য', quote: 'চোখের ক্লান্তি কমাতে ২০-২০-২০ নিয়ম মেনে চলুন: প্রতি ২০ মিনিট পর ২০ সেকেন্ডের জন্য ২০ ফুট দূরে তাকান।', source: 'চক্ষুবিজ্ঞান নির্দেশিকা'),
      HealthDailyTip(category: 'রক্তচাপ ও হৃৎপিণ্ড', quote: 'বাড়িতে রক্তচাপ মাপার আগে ৫ মিনিট শান্ত হয়ে বসুন, কথা বলবেন না এবং কাফটি হৃদপিণ্ডের সমান উচ্চতায় রাখুন।', source: 'কার্ডিওলজি নির্দেশিকা'),
      HealthDailyTip(category: 'বিপাক ও রক্তের চিনি', quote: 'খাওয়ার ২০-৩০ মিনিট পর ১৫ মিনিটের হালকা হাঁটা খাবারের পরবর্তী রক্তের শর্করার তীব্র বৃদ্ধি ৩০% পর্যন্ত কমায়।', source: 'ডায়াবেটিস স্বাস্থ্য গাইড'),
      HealthDailyTip(category: 'পানিশূন্যতা ও সতেজতা', quote: 'সকালে এক গ্লাস হালকা গরম পানি দিয়ে দিন শুরু করলে রাতের পানিশূন্যতা দূর হয় এবং হজমতন্ত্র সক্রিয় হয়।', source: 'হাইড্রেশন ও পুষ্টিবিজ্ঞান'),
      HealthDailyTip(category: 'সার্কাডিয়ান ছন্দ ও ঘুম', quote: 'ঘুম থেকে ওঠার ১ ঘণ্টার মধ্যে ১০-১৫ মিনিট সকালের রোদে থাকলে দেহের অভ্যন্তরীণ ঘড়ি ঠিক থাকে এবং রাতে ভালো ঘুম হয়।', source: 'ঘুম ও বায়োলজি বিজ্ঞান'),
      HealthDailyTip(category: 'ঘুমের স্বাস্থ্যবিধি', quote: 'ঘুমানোর ১ ঘণ্টা আগে মোবাইল স্ক্রিন বন্ধ বা আবছা করলে দ্রুত ঘুম আসে এবং গভীর ঘুমের স্থায়িত্ব বাড়ে।', source: 'নিউরোলজি ও স্লিপ মেডিসিন'),
      HealthDailyTip(category: 'রক্ত সংবহন ও নখ', quote: 'নখের ওপর ৩ সেকেন্ড চাপ দিয়ে ছেড়ে দিন; ২ সেকেন্ডের মধ্যে স্বাভাবিক গোলাপি রঙ ফিরে এলে রক্ত চলাচল স্বাভাবিক আছে।', source: 'ক্লিনিক্যাল পরীক্ষা গাইড'),
      HealthDailyTip(category: 'শ্বাসপ্রশ্বাস ও মানসিক চাপ', quote: 'শারীরবৃত্তীয় দীর্ঘশ্বাস নিন: নাক দিয়ে পর পর দুটি শ্বাস নিয়ে মুখ দিয়ে ধীরে ধীরে লম্বা শ্বাস ছাড়ুন; এটি স্নায়ুতন্ত্রকে শান্ত করে।', source: 'নিউরোফিজিওলজি গাইড'),
      HealthDailyTip(category: 'শারীরিক ভঙ্গি ও মেরুদণ্ড', quote: 'কম্পিউটার স্ক্রিনের ওপরের অংশ চোখের সমান রাখুন; মাথা ১৫ ডিগ্রি সামনে ঝুঁকলে ঘাড়ের ওপর অতিরিক্ত ১২ কেজি চাপ পড়ে।', source: 'ফিজিওথেরাপি ও অর্থোপেডিকস'),
      HealthDailyTip(category: 'হৃৎপিণ্ডের পুষ্টি', quote: 'দৈনিক লবণের পরিমাণ ৫ গ্রামের (এক চা চামচ) কম রাখলে রক্তনালী নমনীয় থাকে এবং উচ্চ রক্তচাপের ঝুঁকি কমে।', source: 'বিশ্ব স্বাস্থ্য সংস্থা'),
      HealthDailyTip(category: 'চোখের আর্দ্রতা', quote: 'স্ক্রিনের দিকে তাকালে চোখের পলক ফেলার হার ৬০% কমে যায়; চোখের শুষ্কতা রোধে কিছুক্ষণ পর পর চোখের পলক ফেলুন।', source: 'চক্ষুবিজ্ঞান ফোরাম'),
      HealthDailyTip(category: 'জিহ্বা ও হজম স্বাস্থ্য', quote: 'সকালে আয়নায় জিহ্বা পরীক্ষা করুন; পুরু সাদা স্তর পানিশূন্যতা বা হজমের সমস্যার লক্ষণ হতে পারে।', source: 'ভিজ্যুয়াল স্বাস্থ্য নির্দেশিকা'),
      HealthDailyTip(category: 'সচেতন আহার', quote: 'খাবারের প্রতি লোকমা অন্তত ২০ বার চিবিয়ে খেলে তৃপ্তি হরমোন ক্ষরিত হওয়ার সময় পায় এবং অতিরিক্ত খাওয়া রোধ হয়।', source: 'পুষ্টিবিজ্ঞান নির্দেশিকা'),
      HealthDailyTip(category: 'পেশী বিপাক ও স্বাস্থ্য', quote: 'ডেস্কে বসে গোড়ালি ওঠানামা করে পায়ের পেশী সচল রাখলে রক্তে গ্লুকোজ পরিষ্কার হতে সাহায্য করে এবং ক্লান্তি আসে না।', source: 'ফিজিওলজি স্টাডিজ'),
      HealthDailyTip(category: 'হাইড্রেশনের পরিমাপক', quote: 'হালকা খড়-রঙা প্রস্রাব সঠিক পানিশূন্যতা-মুক্ত অবস্থার পরিচায়ক; গাঢ় রঙ পানি পানের সংকেত এবং সম্পূর্ণ স্বচ্ছ হলে খনিজ ঘাটতির ইঙ্গিত দেয়।', source: 'কিডনি স্বাস্থ্য নির্দেশিকা'),
      HealthDailyTip(category: 'অন্ত্রের মাইক্রোবায়োম', quote: 'সপ্তাহে ২৫-৩০ ধরনের বৈচিত্র্যময় উদ্ভিদজাত খাবার (শাকসবজি, ডাল, বীজ, ফল) খেলে পেটের উপকারী ব্যাকটেরিয়ার ভারসাম্য বজায় থাকে।', source: 'মাইক্রোবায়োম রিসার্চ'),
      HealthDailyTip(category: 'ম্যাগনেসিয়াম ও পেশীর আরাম', quote: 'গাঢ় সবুজ শাকসবজি এবং মিষ্টি কুমড়ার বীজে প্রচুর ম্যাগনেসিয়াম থাকে যা রাতের পেশীর টান দূর করে এবং স্নায়ু শান্ত করে।', source: 'ক্লিনিক্যাল পুষ্টি নির্দেশিকা'),
      HealthDailyTip(category: 'ত্বকের স্থিতিস্থাপকতা পরীক্ষা', quote: 'হাতের উল্টো পিঠের চামড়া আলতো করে টেনে ছেড়ে দিন; সাথে সাথে স্বাভাবিক অবস্থায় ফিরে এলে দেহে পর্যাপ্ত পানি আছে।', source: 'শারীরিক পরীক্ষা ম্যানুয়াল'),
      HealthDailyTip(category: 'হৃৎপিণ্ডের ব্যায়াম', quote: 'দিনে ৫০-৬০টি সিঁড়ির ধাপ ওঠা হৃৎপিণ্ডের কার্যক্ষমতা বাড়াতে এবং হার্ট অ্যাটাকের ঝুঁকি কমাতে অত্যন্ত ফলপ্রসূ।', source: 'কার্ডিওলজি রিসার্চ'),
      HealthDailyTip(category: 'ঘুমের পরিবেশ ও তাপমাত্রা', quote: 'শোবার ঘরের তাপমাত্রা ১৮-২০ ডিগ্রি সেলসিয়াস রাখলে শরীরের অভ্যন্তরীণ তাপমাত্রা সহজে কমে এবং গভীর ঘুম হয়।', source: 'ঘুম বিজ্ঞান নির্দেশিকা'),
      HealthDailyTip(category: 'পটাশিয়াম ও রক্তনালী', quote: 'পালং শাক, অ্যাভোকাডো ও কলার পটাশিয়াম লবণের ক্ষতিকর প্রভাব কমিয়ে রক্তনালী শিথিল করে ও রক্তচাপ নিয়ন্ত্রণে রাখে।', source: 'উচ্চ রক্তচাপ নির্দেশিকা'),
      HealthDailyTip(category: 'মানসিক একাগ্রতা ও বিরতি', quote: 'প্রতি ৫০ মিনিট কাজের পর ৫ মিনিট স্ক্রিনমুক্ত বিরতি নিলে মস্তিষ্কের ক্লান্তি দূর হয় এবং সিদ্ধান্ত নেওয়ার ক্ষমতা বাড়ে।', source: 'কগনিটিভ নিউরোসায়েন্স'),
      HealthDailyTip(category: 'কোষীয় পুনরুজ্জীবন (অটোফেজি)', quote: 'ঘুমানোর অন্তত ৩ ঘণ্টা আগে রাতের খাবার শেষ করলে কোষে অটোফেজি প্রক্রিয়া সক্রিয় হয় এবং ক্ষতিগ্রস্ত প্রোটিন পরিষ্কার হয়।', source: 'কোষ জীববিজ্ঞান ও দীর্ঘায়ু'),
      HealthDailyTip(category: 'ভিটামিন ডি ও রোগ প্রতিরোধ', quote: 'দুপুরের দিকে হাত ও পায়ে ১৫ মিনিট রোদ লাগালে ত্বক প্রাকৃতিকভাবে ভিটামিন ডি তৈরি করে, যা হাড় ও রোগ প্রতিরোধে অপরিহার্য।', source: 'এন্ডোক্রাইন সোসাইটি'),
      HealthDailyTip(category: 'মুখ ও হৃদরোগ সংযোগ', quote: 'প্রতিদিন ডেন্টাল ফ্লস ব্যবহার করলে মাড়ির ক্ষতিকর ব্যাকটেরিয়া রক্তে প্রবেশ করতে পারে না এবং রক্তনালী সুরক্ষিত থাকে।', source: 'দন্ত ও হৃদরোগ গবেষণা'),
      HealthDailyTip(category: 'ক্যাফেইন ও ঘুমের নিয়ম', quote: 'ক্যাফেইনের কার্যকাল ৫-৭ ঘণ্টা স্থায়ী হয়; দুপুর ২টার পর কফি না খেলে রাতে স্বাভাবিকভাবে প্রশান্তির গভীর ঘুম হয়।', source: 'নিউরোফার্মাকোলজি'),
      HealthDailyTip(category: 'নাক দিয়ে শ্বাস ও অক্সিজেন', quote: 'নাক দিয়ে শ্বাস নিলে বাতাস পরিশোধিত হয় এবং সাইনাসে নাইট্রিক অক্সাইড তৈরি হয়, যা ফুসফুসে অক্সিজেন শোষণ বাড়ায়।', source: 'পালমোনোলজি গবেষণা'),
      HealthDailyTip(category: 'কোলাজেন ও ভিটামিন সি', quote: 'লেবু, কিউই ও ক্যাপসিকামের ভিটামিন সি ত্বকের স্থিতিস্থাপকতা ও অস্থিসন্ধি রক্ষাকারী কোলাজেন তৈরির প্রধান সহায়ক।', source: 'ডার্মাটোলজি ও বায়োকেমিস্ট্রি'),
      HealthDailyTip(category: 'রক্ত চলাচল ও সচলতা', quote: 'প্রতি ৪৫ মিনিট পর ২ মিনিটের জন্য উঠে দাঁড়ালে পায়ের শিরায় রক্ত জমাট বাঁধা রোধ হয় এবং মস্তিষ্কে রক্ত সঞ্চালন বাড়ে।', source: 'ভাস্কুলার স্বাস্থ্য নির্দেশিকা'),
      HealthDailyTip(category: 'মানসিক প্রশান্তি ও হৃদস্পন্দন', quote: 'দিনে মাত্র ১ মিনিট কৃতজ্ঞতাবোধ চর্চা করলে কর্টিসল স্ট্রেস হরমোন কমে এবং হৃদস্পন্দনের স্বাস্থ্যকর ছন্দ (HRV) বৃদ্ধি পায়।', source: 'সাইকোফিজিওলজি স্টাডিজ'),
    ],
    'pt': [
      HealthDailyTip(category: 'Saúde Ocular', quote: 'Aplique a regra 20-20-20 para aliviar o cansaço visual: a cada 20 minutos, olhe para 6 metros de distância por 20 segundos.', source: 'Diretrizes de Oftalmologia'),
      HealthDailyTip(category: 'Pressão & Coração', quote: 'Descanse 5 minutos antes de aferir a pressão em casa, não fale e mantenha a braçadeira na altura do coração.', source: 'Consenso de Cardiologia'),
      HealthDailyTip(category: 'Metabolismo & Glicose', quote: 'Uma caminhada leve de 15 minutos cerca de 20 a 30 minutos após comer reduz os picos glicêmicos em até 30%.', source: 'Saúde Metabólica'),
      HealthDailyTip(category: 'Hidratação & Vitalidade', quote: 'Começar o dia com um copo de água morna repõe os líquidos perdidos durante a noite e desperta a digestão.', source: 'Nefrologia e Hidratação'),
      HealthDailyTip(category: 'Ritmo Circadiano', quote: 'Receber 10 a 15 minutos de luz solar matinal na primeira hora após acordar ajusta seu relógio biológico e melhora o sono.', source: 'Cronobiologia e Sono'),
      HealthDailyTip(category: 'Higiene do Sono', quote: 'Diminuir o brilho das telas 1 hora antes de dormir acelera o adormecer e preserva as fases de sono profundo.', source: 'Medicina do Sono'),
      HealthDailyTip(category: 'Circulação Periférica', quote: 'Pressione a unha por 3 segundos; o retorno da cor rosada em até 2 segundos indica excelente microcirculação periférica.', source: 'Exame Físico Clínico'),
      HealthDailyTip(category: 'Respiração & Alívio', quote: 'Experimente o suspiro fisiológico: duas inalações rápidas pelo nariz e uma expiração longa pela boca para acalmar o sistema nervoso.', source: 'Neurofisiologia do Estresse'),
      HealthDailyTip(category: 'Postura & Ergonomia', quote: 'Mantenha o topo da tela na altura dos olhos; inclinar a cabeça 15 graus para a frente sobrecarrega o pescoço em cerca de 12 kg.', source: 'Ergonomia e Fisioterapia'),
      HealthDailyTip(category: 'Nutrição Cardiovascular', quote: 'Manter o consumo diário de sal abaixo de 5 gramas protege a elasticidade das artérias e alivia a sobrecarga renal.', source: 'OMS & Cardiologia'),
      HealthDailyTip(category: 'Hidratação Ocular', quote: 'O uso de ecrãs reduz o pestanejar em 60%; pisque conscientemente para espalhar uma película lacrimal protetora.', source: 'Consenso de Olho Seco'),
      HealthDailyTip(category: 'Língua & Digestão', quote: 'Observe a sua língua pela manhã; uma camada branca espessa pode indicar desidratação ou desequilíbrio no trato digestivo.', source: 'Exame Clínico Visual'),
      HealthDailyTip(category: 'Alimentação Consciente', quote: 'Mastigar cada garfada cerca de 20 vezes dá tempo aos hormônios da saciedade como o GLP-1 de avisar o cérebro.', source: 'Gastroenterologia'),
      HealthDailyTip(category: 'Metabolismo Muscular', quote: 'Elevar os calcanhares enquanto trabalha sentado ativa o músculo sóleo, ajudando a queimar glicose sem esforço excessivo.', source: 'Fisiologia do Exercício'),
      HealthDailyTip(category: 'Nível de Hidratação', quote: 'Urina amarelo-palha claro indica hidratação perfeita; cor âmbar exige água, enquanto transparência total pode diluir minerais.', source: 'Nefrologia Clínica'),
      HealthDailyTip(category: 'Microbiota Intestinal', quote: 'Ingerir 25 a 30 alimentos vegetais variados por semana (frutas, sementes, leguminosas) enriquece a flora e turbina a imunidade.', source: 'Estudos de Microbiota'),
      HealthDailyTip(category: 'Magnésio & Músculos', quote: 'Folhas verdes escuras e sementes de abóbora são ricas em magnésio, mineral que evita cãibras noturnas e relaxa o sistema nervoso.', source: 'Nutrição Clínica'),
      HealthDailyTip(category: 'Turgor Cutâneo', quote: 'Puxe suavemente a pele no dorso da mão e solte; o retorno imediato comprova excelente hidratação celular e elasticidade.', source: 'Avaliação Física Médica'),
      HealthDailyTip(category: 'Micro-Hábitos Cardiovasculares', quote: 'Subir de 50 a 60 degraus por dia é um dos micro-exercícios mais eficientes para reduzir o risco cardiovascular.', source: 'Pesquisa Cardiológica'),
      HealthDailyTip(category: 'Ambiente de Sono', quote: 'Manter o quarto fresco entre 18 e 20 °C favorece a queda da temperatura corporal necessária para o sono profundo reparador.', source: 'Medicina do Sono'),
      HealthDailyTip(category: 'Potássio & Vasos Sanguíneos', quote: 'O potássio do espinafre, abacate e banana neutraliza a vasoconstrição causada pelo sódio, relaxando as artérias.', source: 'Consenso de Hipertensão'),
      HealthDailyTip(category: 'Foco Mental & Descanso', quote: 'Fazer uma pausa de 5 minutos sem telas a cada 50 minutos zera o cansaço do córtex pré-frontal e mantém a mente alerta.', source: 'Neurociência Cognitiva'),
      HealthDailyTip(category: 'Autofagia Celular', quote: 'Jantar pelo menos 3 horas antes de deitar reduz a insulina noturna, ativando a autofagia e a limpeza de células danificadas.', source: 'Biologia Celular e Longevidade'),
      HealthDailyTip(category: 'Vitamina D & Imunidade', quote: 'Expor braços e pernas ao sol por 15 minutos ao meio-dia ativa a síntese de vitamina D, essencial para ossos e imunidade.', source: 'Sociedade de Endocrinologia'),
      HealthDailyTip(category: 'Conexão Boca-Coração', quote: 'Usar fio dental diariamente remove bactérias gengivais antes que caiam na corrente sanguínea e inflamem as artérias.', source: 'Periodontia e Cardiologia'),
      HealthDailyTip(category: 'Limite de Cafeína', quote: 'A cafeína tem meia-vida de 5 a 7 horas; interromper o café após as 14h permite que o cérebro acumule adenosina para o sono.', source: 'Neurofarmacologia'),
      HealthDailyTip(category: 'Respiração Nasal & Óxido Nítrico', quote: 'Respirar pelo nariz filtra o ar e estimula a produção de óxido nítrico nos seios da face, melhorando a oxigenação.', source: 'Pneumologia Clínica'),
      HealthDailyTip(category: 'Colágeno & Vitamina C', quote: 'A vitamina C das frutas cítricas, kiwi e pimentão é cofator essencial para a síntese de colágeno na pele e articulações.', source: 'Dermatologia e Bioquímica'),
      HealthDailyTip(category: 'Pausa Ativa Circulatória', quote: 'Ficar de pé e caminhar 2 minutos a cada 45 minutos evita a estase venosa nas pernas e reativa a circulação cerebral.', source: 'Cirurgia Vascular e Ergonomia'),
      HealthDailyTip(category: 'Serenidade & Coerência Cardíaca', quote: 'Dedicar 1 minuto por dia à gratidão genuína reduz o cortisol e eleva a variabilidade da frequência cardíaca (VFC).', source: 'Psicofisiologia Clínica'),
    ],
    'ru': [
      HealthDailyTip(category: 'Здоровье глаз', quote: 'Соблюдайте правило 20-20-20 для снятия усталости глаз: каждые 20 минут смотрите на 6 метров вдаль в течение 20 секунд.', source: 'Офтальмологические рекомендации'),
      HealthDailyTip(category: 'Давление и сердце', quote: 'Посидите спокойно 5 минут перед измерением давления, не разговаривайте и держите манжету на уровне сердца.', source: 'Рекомендации кардиологов'),
      HealthDailyTip(category: 'Метаболизм и сахар', quote: '15-минутная спокойная прогулка через 20–30 минут после еды снижает скачки сахара в крови на 30%.', source: 'Эндокринологические исследования'),
      HealthDailyTip(category: 'Гидратация и бодрость', quote: 'Стакан воды комнатной температуры утром восполняет ночную потерю влаги и мягко запускает пищеварение.', source: 'Нефрология и физиология'),
      HealthDailyTip(category: 'Циркадные ритмы', quote: '10–15 минут утреннего солнечного света в первый час после пробуждения настраивают биологические часы на глубокий ночной сон.', source: 'Хронобиология и сомнология'),
      HealthDailyTip(category: 'Гигиена сна', quote: 'Отказ от ярких экранов за час до сна сокращает время засыпания и обеспечивает полноценную глубокую фазу сна.', source: 'Сомнология и неврология'),
      HealthDailyTip(category: 'Микроциркуляция', quote: 'Надавите на ноготь на 3 секунды; возвращение розового цвета в течение 2 секунд указывает на здоровый кровоток.', source: 'Клинический осмотр'),
      HealthDailyTip(category: 'Дыхание и стресс', quote: 'Сделайте физиологический вздох: два быстрых вдоха носом и длинный выдох ртом быстро активируют блуждающий нерв и снимают тревогу.', source: 'Нейрофизиология стресса'),
      HealthDailyTip(category: 'Осанка и эргономика', quote: 'Установите верх монитора на уровне глаз; наклон головы вперед всего на 15 градусов увеличивает нагрузку на шею на 12 кг.', source: 'Эргономика и ортопедия'),
      HealthDailyTip(category: 'Здоровье сердца и диета', quote: 'Ограничение соли до 5 граммов в день (одна чайная ложка) защищает эластичность сосудов и снижает риск гипертонии.', source: 'ВОЗ и кардиология'),
      HealthDailyTip(category: 'Увлажнение глаз', quote: 'При работе за экраном частота моргания падает на 60%; моргайте осознанно, чтобы слезная пленка защищала роговицу.', source: 'Офтальмологический консилиум'),
      HealthDailyTip(category: 'Язык и пищеварение', quote: 'Осмотрите язык утром в зеркале; плотный белый налет часто указывает на нехватку воды или проблемы с пищеварением.', source: 'Клиническая визуальная диагностика'),
      HealthDailyTip(category: 'Осознанное питание', quote: 'Пережевывание каждого кусочка около 20 раз дает время гормонам сытости (GLP-1 и лептину) послать сигнал в мозг.', source: 'Гастроэнтерология и диетология'),
      HealthDailyTip(category: 'Мышечный метаболизм', quote: 'Подъемы на носки сидя активируют камбаловидную мышцу голени, эффективно утилизируя сахар в крови без усталости.', source: 'Физиология мышечной активности'),
      HealthDailyTip(category: 'Индикатор гидратации', quote: 'Светло-соломенный цвет мочи свидетельствует об идеальном водном балансе; темно-янтарный требует немедленно выпить воды.', source: 'Нефрологические стандарты'),
      HealthDailyTip(category: 'Микробиом кишечника', quote: 'Употребление 25–30 разных растительных продуктов в неделю (овощи, зелень, семена, бобовые) формирует стойкий иммунитет.', source: 'Исследования микробиома'),
      HealthDailyTip(category: 'Магний и расслабление', quote: 'Зеленые листовые овощи и семена тыквы богаты магнием; он снимает ночные мышечные спазмы и успокаивает нервную систему.', source: 'Клиническая нутрициология'),
      HealthDailyTip(category: 'Тургор и эластичность кожи', quote: 'Слегка оттяните кожу на тыльной стороне ладони и отпустите; мгновенное расправление подтверждает отличную гидратацию.', source: 'Клинический осмотр'),
      HealthDailyTip(category: 'Кардиотренировка на ходу', quote: 'Подъем на 50–60 ступенек в день — одна из лучших микротренировок для снижения риска инфаркта и укрепления сердца.', source: 'Кардиологические исследования'),
      HealthDailyTip(category: 'Температура и глубокий сон', quote: 'Прохлада в спальне (18–20 °C) способствует естественному снижению температуры тела для долгого глубокого сна.', source: 'Стандарты сомнологии'),
      HealthDailyTip(category: 'Калий и тонус сосудов', quote: 'Калий из шпината, авокадо и бананов нейтрализует действие натрия, расширяя артерии и нормализуя давление.', source: 'Консенсус по гипертонии'),
      HealthDailyTip(category: 'Умственная концентрация', quote: '5-минутный перерыв без экрана каждые 50 минут снимает усталость префронтальной коры и повышает точность решений.', source: 'Когнитивная нейробиология'),
      HealthDailyTip(category: 'Клеточное очищение (аутофагия)', quote: 'Ужин за 3 часа до сна снижает ночной уровень инсулина и запускает аутофагию — естественное обновление клеток.', source: 'Клеточная биология и долголетие'),
      HealthDailyTip(category: 'Витамин D и иммунитет', quote: '15 минут дневного солнца на руках и ногах запускают синтез витамина D, необходимого для костей и крепкого иммунитета.', source: 'Рекомендации эндокринологов'),
      HealthDailyTip(category: 'Связь зубов и сердца', quote: 'Ежедневная зубная нить не дает бактериям десен попадать в кровоток и вызывать микровоспаления стенок артерий.', source: 'Пародонтология и кардиология'),
      HealthDailyTip(category: 'Кофеин и сон', quote: 'Период полувыведения кофеина составляет 5–7 часов; отказ от кофе после 14:00 обеспечивает выработку аденозина для крепкого сна.', source: 'Нейрофармакология'),
      HealthDailyTip(category: 'Носовое дыхание и оксид азота', quote: 'Дыхание через нос очищает воздух и стимулирует выработку оксида азота, значительно улучшая усвоение кислорода легкими.', source: 'Пульмонология и физиология'),
      HealthDailyTip(category: 'Коллаген и витамин C', quote: 'Витамин C из цитрусовых, киви и перца — незаменимый кофактор выработки коллагена для упругости кожи и суставов.', source: 'Дерматология и биохимия'),
      HealthDailyTip(category: 'Двигательная пауза', quote: '2 минуты разминки каждые 45 минут сидения устраняют венозный застой в ногах и мгновенно освежают кровообращение мозга.', source: 'Сосудистая хирургия и эргономика'),
      HealthDailyTip(category: 'Душевный покой и сердце', quote: 'Всего одна минута искренней благодарности в день снижает гормон стресса кортизол и повышает вариабельность сердечного ритма.', source: 'Психофизиологические исследования'),
    ],
    'ur': [
      HealthDailyTip(category: 'آنکھوں کی صحت', quote: 'آنکھوں کی تھکن دور کرنے کے لیے 20-20-20 کا اصول اپنائیں: ہر 20 منٹ بعد 20 سیکنڈ تک 20 فٹ دور دیکھیں۔', source: 'امراض چشم کی گائیڈ'),
      HealthDailyTip(category: 'بلڈ پریشر اور دل', quote: 'گھر پر بلڈ پریشر چیک کرنے سے پہلے 5 منٹ پرسکون بیٹھیں، بات نہ کریں اور کف کو دل کی سطح پر رکھیں۔', source: 'ماہرین امراض قلب کی گائیڈ'),
      HealthDailyTip(category: 'میٹابولزم اور شوگر', quote: 'کھانے کے 20 سے 30 منٹ بعد 15 منٹ کی ہلکی چہل قدمی کھانے کے بعد شوگر کے اضافے کو 30 فیصد تک کنٹرول کرتی ہے۔', source: 'تحقیق برائے ذیابیطس'),
      HealthDailyTip(category: 'ہائیڈریشن اور توانائی', quote: 'صبح کا آغاز ایک گلاس نیم گرم پانی سے کرنا رات بھر کی پانی کی کمی پوری کرتا ہے اور نظام ہضم کو بیدار کرتا ہے۔', source: 'طبی رہنما اصول برائے صحت'),
      HealthDailyTip(category: 'حیاتیاتی گھڑی اور نیند', quote: 'جاگنے کے پہلے 1 گھنٹے کے اندر 10 سے 15 منٹ قدرتی دھوپ لینا آپ کی نیند کے سائیکل کو منظم کرتا ہے۔', source: 'طبی تحقیق برائے نیند'),
      HealthDailyTip(category: 'نیند اور ذہنی سکون', quote: 'سونے سے 1 گھنٹہ پہلے موبائل اور اسکرینوں کو بند کرنا گہری نیند اور ذہنی سکون میں بے پناہ اضافہ کرتا ہے۔', source: 'نیورولوجی اور نیند کی میڈیسن'),
      HealthDailyTip(category: 'خون کی گردش اور ناخن', quote: 'اپنے ناخن کو 3 سیکنڈ دبائیں؛ اگر 2 سیکنڈ کے اندر گلابی رنگ واپس آ جائے تو یہ خون کی بہترین گردش کی علامت ہے۔', source: 'طبی معائنے کی گائیڈ'),
      HealthDailyTip(category: 'سانس اور اعصابی سکون', quote: 'جسمانی گہرا سانس لیں: ناک سے دو بار تیزی سے سانس اندر کھینچیں اور منہ سے آہستہ لمبی سانس باہر نکالیں، اعصاب فوراً پرسکون ہوں گے۔', source: 'نیورولوجی ریسرچ'),
      HealthDailyTip(category: 'بیٹھنے کا انداز اور گردن', quote: 'کمپیوٹر اسکرین کے اوپری حصے کو آنکھوں کے برابر رکھیں؛ سر کو صرف 15 ڈگری آگے جھکانا گردن پر 12 کلو کا اضافی دباؤ ڈالتا ہے۔', source: 'آرتھوپیڈکس اور فزیوتھراپی'),
      HealthDailyTip(category: 'دل کی صحت اور نمک', quote: 'روزانہ نمک کی مقدار 5 گرام (ایک چائے کا چمچ) سے کم رکھنا شریانوں کی لچک برقرار رکھتا ہے اور گردوں کو بچاتا ہے۔', source: 'عالمی ادارہ صحت'),
      HealthDailyTip(category: 'آنکھوں کی نمی', quote: 'اسکرین کے سامنے پلکیں جھپکنے کی رفتار 60 فیصد کم ہو جاتی ہے؛ آنکھوں کی خشکی سے بچنے کے لیے وقتاً فوقتاً پلکیں جھپکائیں۔', source: 'خشک آنکھوں کی رہنمائی'),
      HealthDailyTip(category: 'زبان اور ہاضمہ', quote: 'صبح آئینے میں اپنی زبان کا معائنہ کریں؛ اس پر سفید موٹی تہہ پانی کی کمی یا نظام ہضم کی خرابی کی علامت ہو سکتی ہے۔', source: 'طبی علامات کی گائیڈ'),
      HealthDailyTip(category: 'آہستہ چبا کر کھانا', quote: 'ہر لقمے کو تقریباً 20 بار چبائیں؛ اس سے پیٹ بھرنے کے ہارمونز کو دماغ تک سگنل پہنچانے کا مناسب وقت ملتا ہے۔', source: 'طبی رہنما برائے ہاضمہ'),
      HealthDailyTip(category: 'پٹھوں کی چستی اور میٹابولزم', quote: 'کرسی پر بیٹھے ہوئے ایڑیوں کو بار بار اوپر اٹھانا بلڈ شوگر کو بغیر تھکاوٹ جلانے میں بہترین کردار ادا کرتا ہے۔', source: 'ورزش کی فزیالوجی'),
      HealthDailyTip(category: 'پانی کی مقدار کا پیمانہ', quote: 'ہلکا زرد پیشاب مناسب پانی کی علامت ہے؛ گہرا رنگ پانی پینے کا تقاضا کرتا ہے اور بالکل بے رنگ ہونا منرلز کی کمی ظاہر کر سکتا ہے۔', source: 'امراض گردہ و مثانہ'),
      HealthDailyTip(category: 'معدے کے بیکٹیریا اور صحت', quote: 'ہفتے میں 25 سے 30 مختلف پودوں پر مبنی غذائیں (سبزیاں، بیج، دالیں) کھانا معدے کی قوت مدافعت کو غیر معمولی تقویت دیتا ہے۔', source: 'مائیکرو بائیوم ریسرچ'),
      HealthDailyTip(category: 'میگنیشیم اور پٹھوں کا آرام', quote: 'سبز پتوں والی سبزیاں اور کدو کے بیج میگنیشیم سے مالا مال ہیں جو رات کے وقت پٹھوں کے کھچاؤ کو روک کر سکون دیتے ہیں۔', source: 'کلینیکل نیوٹریشن گائیڈ'),
      HealthDailyTip(category: 'جلد کی لچک کا ٹیسٹ', quote: 'ہاتھ کے پچھلے حصے کی جلد کو ہلکا سا اوپر کھینچ کر چھوڑیں؛ اگر وہ فوراً اپنی جگہ لوٹ آئے تو جسم میں پانی کی مقدار بالکل ٹھیک ہے۔', source: 'طبی جانچ گائیڈ'),
      HealthDailyTip(category: 'سیڑھیاں چڑھنا اور دل کی صحت', quote: 'روزانہ 50 سے 60 سیڑھیاں چڑھنا دل کے دورے کے خطرے کو کم کرنے کی سب سے تیز اور کارآمد ورزش ہے۔', source: 'تحقیق برائے امراض قلب'),
      HealthDailyTip(category: 'کمرے کا درجہ حرارت اور گہری نیند', quote: 'سونے کے کمرے کا درجہ حرارت 18 سے 20 ڈگری سینٹی گریڈ رکھنا جسم کو ٹھنڈا کر کے گہری پرسکون نیند لانے میں مدد دیتا ہے۔', source: 'طبی معیارات برائے نیند'),
      HealthDailyTip(category: 'پوٹاشیم اور شریانوں کی لچک', quote: 'پالک، ایواکاڈو اور کیلے میں پایا جانے والا پوٹاشیم نمک کے برے اثر کو ختم کر کے شریانوں کو کھلا اور پرسکون رکھتا ہے۔', source: 'ہائی بلڈ پریشر گائیڈ'),
      HealthDailyTip(category: 'ذہنی یکسوئی اور وقفہ', quote: 'ہر 50 منٹ کام کے بعد اسکرین سے دور 5 منٹ کا وقفہ دماغ کی تھکاوٹ دور کر کے توجہ کو تیز تر بناتا ہے۔', source: 'ذہنی اور اعصابی علوم'),
      HealthDailyTip(category: 'خلیات کی صفائی (آٹوفیجی)', quote: 'سونے سے کم از کم 3 گھنٹے پہلے رات کا کھانا کھانا جسم میں نقصان دہ پروٹینز کی صفائی اور خلیوں کی تجدید کرتا ہے۔', source: 'سیلولر بائیولوجی اور لمبی عمر'),
      HealthDailyTip(category: 'وٹامن ڈی اور ہڈیوں کی مضبوطی', quote: 'دن کے وقت 15 منٹ بازوؤں اور ٹانگوں پر دھوپ لگنے سے قدرتی وٹامن ڈی بنتا ہے جو ہڈیوں اور مدافعت کے لیے لازم ہے۔', source: 'اینڈوکرائن سوسائٹی گائیڈ'),
      HealthDailyTip(category: 'دانت اور دل کی حفاظت', quote: 'روزانہ ڈینٹل فلاس کا استعمال مسوڑھوں کے جراثیم کو خون میں داخل ہونے سے روکتا ہے اور دل کی شریانوں کو بچاتا ہے۔', source: 'دندان سازی اور امراض قلب'),
      HealthDailyTip(category: 'کیفین اور نیند کے اوقات', quote: 'کیفین کے اثرات 5 سے 7 گھنٹے برقرار رہتے ہیں؛ دوپہر 2 بجے کے بعد چائے یا کافی بند کرنا رات کو پرسکون نیند لاتا ہے۔', source: 'نیورو فارماکولوجی'),
      HealthDailyTip(category: 'ناک سے سانس اور آکسیجن', quote: 'ناک کے ذریعے سانس لینا ہوا کو صاف کرتا ہے اور نائٹرک آکسائیڈ بنا کر پھیپھڑوں میں آکسیجن کے جذب ہونے کو تیز کرتا ہے۔', source: 'پلمونولوجی ریسرچ'),
      HealthDailyTip(category: 'کولیجن اور وٹامن سی', quote: 'مالٹا، کیوی اور شملہ مرچ میں وٹامن سی کولیجن بنانے میں لازمی کردار ادا کرتا ہے جس سے جلد اور جوڑ مضبوط رہتے ہیں۔', source: 'ڈرمیٹالوجی اور بائیو کیمسٹری'),
      HealthDailyTip(category: 'خون کی روانی اور مختصر حرکت', quote: 'مسلسل بیٹھنے کے دوران ہر 45 منٹ بعد 2 منٹ کھڑے ہو کر چہل قدمی کرنا ٹانگوں کی رگوں میں خون کی گردش کو بحال رکھتا ہے۔', source: 'عروقی صحت اور ارگونومکس'),
      HealthDailyTip(category: 'ذہنی سکون اور دل کا توازن', quote: 'روزانہ صرف 1 منٹ شکر گزاری کا احساس پیدا کرنا تناؤ کے ہارمون کورٹیسول کو گھٹا کر دل کی دھڑکن کے توازن کو بہتر کرتا ہے۔', source: 'نفسیاتی و طبی تحقیق'),
    ],
  };
}

/// Compact quote-styled daily scientific health tip card.
class DailyHealthTipCard extends StatelessWidget {
  const DailyHealthTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final tipItem = DailyWellnessExtras.dailyTipItemForLocale(langCode);

    return Container(
      key: const Key('home_daily_health_tip_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF122826)
            : AppTheme.primaryTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              size: 20,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.dailyHealthTipTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tipItem.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '“${tipItem.quote}”',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BirthdayCelebrationCard extends StatefulWidget {
  const BirthdayCelebrationCard({
    super.key,
    required this.displayName,
    this.nowOverride,
  });

  final String displayName;
  final DateTime? nowOverride;

  @override
  State<BirthdayCelebrationCard> createState() =>
      _BirthdayCelebrationCardState();
}

class _BirthdayCelebrationCardState extends State<BirthdayCelebrationCard> {
  bool _isBirthday = false;
  bool _hasTriggeredInitialBurst = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final hit = await DailyWellnessExtras.isTodayBirthday(
      now: widget.nowOverride,
    );
    if (!mounted) return;
    setState(() => _isBirthday = hit);

    if (hit && !_hasTriggeredInitialBurst) {
      _hasTriggeredInitialBurst = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _triggerCelebration();
      });
    }
  }

  void _triggerCelebration() {
    HapticFeedback.heavyImpact();
    VisualAnnouncementEffectService.showEffect(
      context,
      type: 'birthday',
      shape: 'doğum günü',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBirthday) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Container(
      key: const Key('home_birthday_celebration_card'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _triggerCelebration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🎂', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.birthdayCardTitle(widget.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.birthdayCardSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.94),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _triggerCelebration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFE11D48),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.celebration_rounded, size: 16),
                  label: const Text(
                    'Kutla 🎉',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Social Formul Bank-inspired showcase card listing community members
/// whose birthday is today, with cake badges and interactive "Kutla 🎉" wishes.
class CommunityBirthdayShowcaseCard extends StatefulWidget {
  const CommunityBirthdayShowcaseCard({
    super.key,
    this.profiles,
    this.onOpenProfile,
  });

  final List<HealthCommunityProfile>? profiles;
  final ValueChanged<HealthCommunityProfile>? onOpenProfile;

  @override
  State<CommunityBirthdayShowcaseCard> createState() =>
      _CommunityBirthdayShowcaseCardState();
}

class _CommunityBirthdayShowcaseCardState
    extends State<CommunityBirthdayShowcaseCard> {
  final Set<String> _celebratedUids = {};

  void _celebrateMember(HealthCommunityProfile member) {
    HapticFeedback.heavyImpact();
    setState(() => _celebratedUids.add(member.uid));
    VisualAnnouncementEffectService.showEffect(
      context,
      type: 'birthday',
      shape: 'doğum günü',
    );

    _showWishSheet(member);
  }

  void _showWishSheet(HealthCommunityProfile member) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController(
      text: '🎂 Sağlıklı, mutlu ve neşeyle dolu nice güzel yaşlara! 🎉',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132223) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2A8D).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🎂', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.visibleName} için Doğum Günü Notu',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Tebrik dileğin topluluk panosuna iletilecek',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _wishChip(
                    '🎂 Nice Sağlıklı Yaşlara!',
                    controller,
                    '🎂 Sağlıklı, mutlu ve neşeyle dolu nice güzel yaşlara! 🎉',
                  ),
                  _wishChip(
                    '✨ Şifa & Huzur',
                    controller,
                    '✨ Yeni yaşın sana bol şifa, enerji ve huzur getirsin! 🌟',
                  ),
                  _wishChip(
                    '💪 Sağlık Yolculuğunda Başarılar',
                    controller,
                    '💪 Sağlıklı yaşam yolculuğunda nice başarılı yıllara! 🌿',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tebrik mesajını yaz...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Text('💌', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${member.visibleName} için kutlama notun iletildi! 🎉',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2A8D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'Kutlamayı İlet 💌',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wishChip(
    String label,
    TextEditingController controller,
    String fullText,
  ) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () => controller.text = fullText,
      backgroundColor: const Color(0xFFFF2A8D).withValues(alpha: 0.08),
      side: BorderSide(
        color: const Color(0xFFFF2A8D).withValues(alpha: 0.22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = HealthCommunityRepository.getTodayBirthdayProfiles(
      source: widget.profiles,
    );

    if (members.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: const Key('home_community_birthdays_section'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF142426)
            : const Color(0xFFFFF1F2).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF2A8D).withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2A8D).withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2A8D).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cake_rounded,
                    color: Color(0xFFFF2A8D),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Bugün Doğum Günü Olan Üyelerimiz',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2A8D).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${members.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF2A8D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.pink.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 116,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isCelebrated = _celebratedUids.contains(member.uid);

                return Container(
                  width: 96,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: widget.onOpenProfile != null
                            ? () => widget.onOpenProfile!(member)
                            : null,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFFF2A8D)
                                  .withValues(alpha: 0.18),
                              child: Text(
                                member.initials,
                                style: const TextStyle(
                                  color: Color(0xFFFF2A8D),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '🎂',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        member.visibleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 24,
                        child: ElevatedButton(
                          onPressed: isCelebrated
                              ? null
                              : () => _celebrateMember(member),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCelebrated
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFF2A8D),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF10B981)
                                .withValues(alpha: 0.8),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isCelebrated ? '✓ Kutlandı' : 'Kutla 🎉',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

