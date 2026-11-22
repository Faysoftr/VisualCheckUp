// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort => '本应用不提供医疗诊断，仅用于健康信息参考与视觉自我观察。';

  @override
  String get disclaimerTitle => '重要医疗声明';

  @override
  String get disclaimerFull =>
      'VisualCheckUp 基于颜色和视觉特征提供健康预评估，不是医疗器械，不能替代医生面诊、化验检查或医疗诊断。\n\n• 环境光线、摄像头传感器和屏幕显示会影响颜色判断。\n• 如出现剧烈疼痛、出血、高烧、黄疸、黑便/陶土便、视力骤变或呼吸困难，请立即就医。\n• 隐私保护：拍摄的图像默认仅在您的设备本地处理。';

  @override
  String get disclaimerAccept => '我已了解';

  @override
  String get loginTagline => '皮肤、黑痣及日常视觉健康变化的个人追踪与就诊准备助手。';

  @override
  String get featureColorCalibration => '色彩校准';

  @override
  String get featurePrivacyFirst => '隐私优先';

  @override
  String get featureOptionalAi => '可选 AI';

  @override
  String get loginCardTitle => '使用账户继续';

  @override
  String get loginCardSubtitle => '同步管理您的个人色彩基准与检查记录。';

  @override
  String get continueWithApple => '通过 Apple 继续';

  @override
  String get continueWithGoogle => '通过 Google 继续';

  @override
  String get orDivider => '或';

  @override
  String get continueAsGuest => '以访客身份继续';

  @override
  String get guestGreeting => '皮肤与视觉健康追踪';

  @override
  String userGreeting(String name) {
    return '你好，$name';
  }

  @override
  String accountTypeLabel(String provider) {
    return '$provider 账户';
  }

  @override
  String get localOnlyLabel => '仅保存在此设备';

  @override
  String get menuHome => '主页';

  @override
  String get menuSectionVisualChecks => '视觉检查';

  @override
  String get menuSkinGroup => '皮肤（痣、疣、淤青、色斑）';

  @override
  String get menuSkinGeneral => '常规皮肤与皮疹';

  @override
  String get menuSectionTracking => '追踪、化验与体征';

  @override
  String get menuFollowUpPlan => '个人随访计划';

  @override
  String get menuVitalsTracker => '血压与血糖追踪';

  @override
  String get menuLabReports => '化验与医院报告';

  @override
  String get menuQuickColorCard => '无相机比色卡';

  @override
  String get menuHistory => '检查历史';

  @override
  String get menuReferenceGuide => '视觉参考指南';

  @override
  String get menuSectionSettings => '设置与隐私';

  @override
  String get menuAiSettings => 'AI 与隐私';

  @override
  String get menuDisclaimer => '医疗声明';

  @override
  String get menuTheme => '外观主题';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get menuLanguage => '应用语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get signInGoogleOrApple => '使用 Google 或 Apple 登录';

  @override
  String get signOut => '退出登录';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountTitle => '删除账户和本地数据';

  @override
  String get deleteAccountBody => '您将退出登录，且此设备上的检查历史和个人色彩基准将被永久删除。是否继续？';

  @override
  String get cancel => '取消';

  @override
  String get followUpCardTitle => '个人随访计划';

  @override
  String get followUpSelectEdit => '选择 / 编辑';

  @override
  String get followUpStart => '开始';

  @override
  String get followUpEmptyHint => '点击选择眼睛、尿液、血压、血糖等随访项目。';

  @override
  String get followUpSheetSubtitle => '在一个计划中统一追踪眼睛、舌头、指甲、皮肤、尿液、大便、血压、血糖和化验报告。';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active 项启用 • $completed 项已更新 • $due 项待检查';
  }

  @override
  String get homeCategoriesTitle => '检查分类';

  @override
  String get homeCategoriesSubtitle => '使用相机校准或无相机比色卡追踪视觉变化。';

  @override
  String get homeLabsVitalsTitle => '化验、血压与血糖';

  @override
  String get homeLabsVitalsSubtitle => '读取医院化验单并按日期追踪血压和血糖趋势。';

  @override
  String get homeLabsCardTitle => '化验与报告';

  @override
  String get homeLabsCardEmpty => '读取并分析血液化验';

  @override
  String homeLabsCardCount(int count) {
    return '已保存 $count 份报告';
  }

  @override
  String get homeVitalsCardTitle => '血压与血糖';

  @override
  String get homeVitalsCardEmpty => '记录数值并查看趋势';

  @override
  String homeVitalsCardCount(int count) {
    return '已保存 $count 条记录';
  }

  @override
  String get homeRecentChecks => '最近检查';

  @override
  String get seeAll => '查看全部';

  @override
  String get catEyeTitle => '眼睛（巩膜）';

  @override
  String get catEyeSubtitle => '红血丝、发黄与巩膜色调';

  @override
  String get catNailTitle => '指甲';

  @override
  String get catNailSubtitle => '苍白、发紫、发黄与形态检查';

  @override
  String get catTongueTitle => '舌头';

  @override
  String get catTongueSubtitle => '颜色、白/黄苔与表面纹理';

  @override
  String get catFaceTitle => '面部与肤色';

  @override
  String get catFaceSubtitle => '肤色、苍白与泛红观察';

  @override
  String get catSkinTitle => '皮肤状况';

  @override
  String get catSkinSubtitle => '痣、疣、淤青、面部色斑与皮疹';

  @override
  String get catUrineTitle => '尿液颜色';

  @override
  String get catUrineSubtitle => '水分状态与比色检查';

  @override
  String get catStoolTitle => '大便颜色';

  @override
  String get catStoolSubtitle => '消化与颜色警示检查';

  @override
  String get tooltipHistory => '历史';

  @override
  String get tooltipAccountMenu => '账户与菜单';
}
