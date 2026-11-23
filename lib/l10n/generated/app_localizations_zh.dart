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

  @override
  String get menuSettings => '设置（权限与语言）';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguageDesc => '默认自动使用手机系统语言，您也可以在下方手动切换。';

  @override
  String get settingsPermissionsTitle => '应用权限';

  @override
  String get settingsPermissionsDesc => '在此查看和管理相机与相册权限。';

  @override
  String get settingsCameraPermission => '相机权限';

  @override
  String get settingsCameraPermissionDesc => '用于眼睛、舌头、指甲和皮肤拍摄';

  @override
  String get settingsPhotosPermission => '相册与照片权限';

  @override
  String get settingsPhotosPermissionDesc => '用于从相册上传照片和化验单';

  @override
  String get settingsOpenSystemPermissions => '打开手机应用权限';

  @override
  String get permChecking => '检查中...';

  @override
  String get permGranted => '已授权';

  @override
  String get permDenied => '需要权限';

  @override
  String get permPermanent => '请在系统设置中开启';

  @override
  String get permUnavailable => '由设备管理';

  @override
  String get permGrantBtn => '授权';

  @override
  String get permOpenSettingsBtn => '打开设置';

  @override
  String get skinCancerRisk => '黑痣与皮肤癌风险';

  @override
  String get skinWart => '疣体预检';

  @override
  String get skinBruise => '淤青追踪';

  @override
  String get skinFacialSpot => '面部色斑';

  @override
  String get trackEyeTitle => '每周眼睛（巩膜）检查';

  @override
  String get trackEyeSubtitle => '追踪巩膜红血丝或发黄变化';

  @override
  String get trackTongueTitle => '每周舌苔观察';

  @override
  String get trackTongueSubtitle => '追踪舌色、舌苔及表面变化';

  @override
  String get trackNailTitle => '每周指甲观察';

  @override
  String get trackNailSubtitle => '关注甲床苍白、发紫或发黄';

  @override
  String get trackFaceTitle => '每两周面部肤色';

  @override
  String get trackFaceSubtitle => '对比面部苍白、泛红与肤色变化';

  @override
  String get trackSkinTitle => '每月皮肤、痣与疣检查';

  @override
  String get trackSkinSubtitle => '对比30天内痣、疣、淤青和色斑变化';

  @override
  String get trackHydrationTitle => '每日水分（尿液）追踪';

  @override
  String get trackHydrationSubtitle => '使用无相机比色卡2秒记录水分状态';

  @override
  String get trackStoolTitle => '每周大便颜色追踪';

  @override
  String get trackStoolSubtitle => '定期记录消化与颜色警示';

  @override
  String get trackBpTitle => '每日血压记录';

  @override
  String get trackBpSubtitle => '记录收缩压/舒张压与脉搏趋势';

  @override
  String get trackSugarTitle => '每日血糖追踪';

  @override
  String get trackSugarSubtitle => '记录空腹或餐后血糖数值';

  @override
  String get trackLabTitle => '每季度血液化验报告';

  @override
  String get trackLabSubtitle => '上传医院化验单并按期对比';

  @override
  String get statusFirstPending => '等待首次记录';

  @override
  String get statusDueNow => '该检查了';

  @override
  String get statusDoneToday => '今日已完成';

  @override
  String statusNextDays(int days) {
    return '下次检查：$days 天后';
  }

  @override
  String get actionCheckNow => '立即检查';

  @override
  String get actionLogReading => '记录数值';

  @override
  String get actionAddReport => '添加报告';

  @override
  String checkMethodTitle(String category) {
    return '$category • 检查方式';
  }

  @override
  String get checkMethodSubtitle => '无需拍照2秒通过比色卡选择，或使用相机色彩测量。';

  @override
  String get colorCardRecommendedTitle => '无相机比色卡（推荐）';

  @override
  String get colorCardRecommendedSubtitle => '无需拍照，私密快速记录（2秒）';

  @override
  String get cameraMeasureTitle => '相机色彩测量';

  @override
  String get cameraMeasureSubtitle => '带白平衡校准的自动测量';

  @override
  String get referenceGuideSubtitle => '选择模块查看健康与异常视觉参考。';

  @override
  String get historyEmpty => '暂无保存的检查记录。';

  @override
  String get filterAll => '全部';

  @override
  String get aiSettingsTitle => 'AI 与隐私设置';

  @override
  String get vitalsBpTab => '血压';

  @override
  String get vitalsSugarTab => '血糖';

  @override
  String get skinScreenTitle => '皮肤状况预检';

  @override
  String get providerGuest => '访客';

  @override
  String signInFailed(String error) {
    return '登录失败：$error';
  }

  @override
  String get riskNormal => '外观正常';

  @override
  String get riskAttention => '建议随访观察';

  @override
  String get riskUrgent => '建议尽快就医评估';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return '最近：$value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return '最近：$count 项指标（$abnormal 项超出参考范围）';
  }

  @override
  String latestLabAllNormal(int count) {
    return '最近：$count 项指标（均正常）';
  }

  @override
  String get labStatusCriticalLow => '危急偏低';

  @override
  String get labStatusLow => '偏低';

  @override
  String get labStatusNormal => '正常';

  @override
  String get labStatusHigh => '偏高';

  @override
  String get labStatusCriticalHigh => '危急偏高';

  @override
  String get labSourceManual => '手动录入';

  @override
  String get labSourcePasted => '从文本解析';

  @override
  String get labSourcePhoto => 'JPG / 照片报告';

  @override
  String get labSourcePdf => 'PDF 报告';

  @override
  String get bpLow => '低血压';

  @override
  String get bpNormal => '正常范围';

  @override
  String get bpElevated => '正常偏高';

  @override
  String get bpStage1 => '1级高血压';

  @override
  String get bpStage2 => '2级高血压';

  @override
  String get bpCrisis => '高血压危象';

  @override
  String get sugarLow => '低血糖';

  @override
  String get sugarNormal => '正常范围';

  @override
  String get sugarBorderline => '临界偏高';

  @override
  String get sugarHigh => '高血糖';

  @override
  String get sugarVeryHigh => '极高血糖';

  @override
  String get sugarTypeFasting => '空腹';

  @override
  String get sugarTypePostMeal => '餐后2小时';

  @override
  String get sugarTypeRandom => '随机';

  @override
  String get specialtyEye => '眼科或内科';

  @override
  String get specialtyNail => '皮肤科或内科';

  @override
  String get specialtyTongue => '耳鼻喉科、口腔科或内科';

  @override
  String get specialtySkin => '皮肤科';

  @override
  String get specialtyUrine => '泌尿外科或内科';

  @override
  String get specialtyStool => '消化内科或内科';

  @override
  String get cloudBackupTitle => '云备份（可选 • Firebase）';

  @override
  String get cloudBackupDesc =>
      '默认情况下，您的所有检验报告和测量记录仅保存在本设备。如需在更换手机时保留数据，可开启仅限本人 Google/Apple 账号访问的私密云备份。';

  @override
  String get cloudBackupToggleTitle => '启用云备份';

  @override
  String cloudBackupLastSync(String date) {
    return '上次备份：$date';
  }

  @override
  String get cloudBackupEnabledReady => '已启用 • 准备同步';

  @override
  String get cloudBackupDisabledLocal => '已关闭 • 仅本机存储';

  @override
  String get cloudBackupSignInRequired => '请先使用 Google 或 Apple 账号登录以启用云备份。';

  @override
  String get cloudBackupNowBtn => '立即备份';

  @override
  String get cloudRestoreBtn => '从云端恢复';

  @override
  String get cloudConsentTitle => '云备份隐私同意';

  @override
  String get cloudConsentBody =>
      '默认情况下，您的检验报告、测量和检查记录仅保存在本设备。\n\n开启云备份后，数据将私密存储在您的 Google/Apple 专属云端空间，注销账号时将永久清除。\n\n您是否同意？';

  @override
  String get cloudConsentConfirm => '同意并启用';

  @override
  String cloudBackupSuccess(int count) {
    return '云备份完成：已同步 $count 条记录。';
  }

  @override
  String cloudBackupFailed(String error) {
    return '备份失败：$error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return '已从云端恢复：导入 $count 条记录。';
  }

  @override
  String cloudRestoreFailed(String error) {
    return '恢复失败：$error';
  }

  @override
  String get cloudBackupDisabledNotice => '已关闭云备份，新记录仅保存在本机。';

  @override
  String get aiCloudToggleTitle => '云端视觉 AI（Gemini）分析';

  @override
  String get aiCloudOnDesc => '已开启：清晰照片将压缩后通过安全连接进行视觉分析，离线时自动回退本机分析。';

  @override
  String get aiCloudOffDesc => '已关闭（0 Token）：所有分析均在本地完成，不上传任何照片。';

  @override
  String get aiBackendOfflineNote =>
      '配置 Gemini / Firebase AI 密钥后将按此开关自动启用云端分析；当前正使用本机引擎。';

  @override
  String get aiOptimizationsTitle => '已启用的 Token 与流量节省机制';

  @override
  String get aiOptQualityGate => '0-Token 模糊、过暗与反光质量拦截';

  @override
  String get aiOptCompression => '自动裁剪 + 512px/768px JPEG（80%）压缩';

  @override
  String get aiOptTieredModel => '智能分层模型路由（Flash-Lite / Flash）';

  @override
  String get aiOptHashCache => '重复图片本地哈希缓存（0 Token）';

  @override
  String get aiClearCacheBtn => '清除 AI 缓存';

  @override
  String get aiCacheCleared => 'AI 缓存已清除。';

  @override
  String resultScreenTitle(String category) {
    return '$category结果';
  }

  @override
  String get tooltipDoctorSummary => '就医摘要';

  @override
  String get tooltipReferenceGuide => '参考指南';

  @override
  String get calibratedColorTone => '已校准色调';

  @override
  String get sampledColorTone => '采样主色调';

  @override
  String confidenceLabel(int percent) {
    return '初筛置信度：$percent%';
  }

  @override
  String get whiteBalanceDefaultNote => '已通过白色参考完成色彩校准。';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return '建议咨询科室：$specialty';
  }

  @override
  String get timelineComparisonTitle => '随时间变化对比';

  @override
  String get todayLabel => '今天';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return '上次记录：“$title”（$status），共追踪 $count 条记录。';
  }

  @override
  String get personalBaselineComparisonTitle => '个人基准对比';

  @override
  String get yourBaselineLabel => '个人基准';

  @override
  String get warningFlagsTitle => '需警惕的警示信号';

  @override
  String get observationsTitle => '观察结果';

  @override
  String get recommendationsTitle => '建议';

  @override
  String get personalBaselineCardTitle => '个人基准校准';

  @override
  String get personalBaselineCardDesc => '在状态良好时保存为个人基准，可减少不同手机镜头造成的色差。';

  @override
  String get saveBaselineBtn => '设为我的个人基准';

  @override
  String get updateBaselineBtn => '更新个人基准';

  @override
  String get clearBaselineBtn => '移除';

  @override
  String baselineSavedMsg(String category) {
    return '已保存 $category 的个人基准色调。';
  }

  @override
  String baselineClearedMsg(String category) {
    return '已移除 $category 的个人基准。';
  }

  @override
  String get doctorSummaryBtn => '给医生看 • 生成就医摘要';

  @override
  String get returnHomeBtn => '返回首页';

  @override
  String get doctorSheetTitle => '就医准备摘要';

  @override
  String colorLabel(String hex, String status) {
    return '色彩：$hex • $status';
  }

  @override
  String get timelineHistoryTitle => '历史变化时间线';

  @override
  String get questionsForDoctorTitle => '可向医生咨询的问题';

  @override
  String get copyShareSummaryBtn => '复制并分享摘要';

  @override
  String get doctorSummaryCopied => '就医摘要已复制到剪贴板。';

  @override
  String referenceSheetTitle(String category) {
    return '$category — 视觉参考';
  }

  @override
  String get healthyReferenceLabel => '健康参考';

  @override
  String get captureChecklistTitle => '拍摄要点';

  @override
  String get abnormalFindingsTitle => '需注意的异常视觉表现';

  @override
  String get cameraPermPermanentMsg => '系统设置中已禁用相机权限，请在设置中开启或从相册选择照片。';

  @override
  String get cameraPermRequiredMsg => '视觉初筛需要相机权限，照片默认仅在本地处理。';

  @override
  String get cameraGrantPermTitle => '需要相机权限';

  @override
  String get cameraRequestPermBtn => '授予相机权限';

  @override
  String get cameraPickGalleryBtn => '从相册选择';

  @override
  String get cameraWhiteRefOn => '白平衡参考：开';

  @override
  String get cameraWhiteRefOff => '白平衡参考：关';

  @override
  String get cameraBaselineActive => '已设个人基准';

  @override
  String get cameraAnalyzing => '正在分析...';

  @override
  String get cameraCaptureBtn => '拍摄并评估';

  @override
  String cameraAnalysisFailed(String error) {
    return '分析出错：$error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • 色卡';
  }

  @override
  String get quickCardPrivacyBanner => '无需拍照：选择最接近的色块，2秒完成私密记录。';

  @override
  String get quickCardChooseShade => '选择最接近的色调';

  @override
  String get quickCardExtraContext => '补充信息（可选）';

  @override
  String get quickCardSaveViewBtn => '保存并查看评估';

  @override
  String get quickCardUseCameraBtn => '改用相机拍摄';

  @override
  String get skinIntroTitle => '皮肤视觉初筛';

  @override
  String get skinIntroDesc => '将痣、疣、淤青及面部斑点与周围皮肤进行对比。非医疗诊断，仅用于辅助皮肤科就诊准备。';

  @override
  String get skinStep1Title => '1. 选择皮肤初筛模块';

  @override
  String get skinOtherConcernsLabel => '其他皮肤表现';

  @override
  String get skinStep2Title => '2. 伴随症状（可选）';

  @override
  String get skinStep3Title => '3. 身体部位（可选）';

  @override
  String get skinStartCameraBtn => '启动相机皮肤检查';

  @override
  String get skinConcernRash => '发红 / 皮疹';

  @override
  String get skinConcernMole => '痣 / 深色斑点';

  @override
  String get skinConcernScaly => '鳞屑 / 干燥斑块';

  @override
  String get skinConcernBlister => '水疱 / 痤疮';

  @override
  String get skinConcernGeneral => '常规皮肤检查';

  @override
  String get bodyAreaFaceNeck => '面部 / 颈部';

  @override
  String get bodyAreaArmHand => '手臂 / 手部';

  @override
  String get bodyAreaTorso => '躯干';

  @override
  String get bodyAreaLegFoot => '腿部 / 足部';

  @override
  String get bodyAreaScalp => '头皮';

  @override
  String get bodyAreaOther => '其他';

  @override
  String get symptomItching => '瘙痒';

  @override
  String get symptomPainWarmth => '疼痛 / 发热';

  @override
  String get symptomRapidChange => '快速增大 / 形态变化';

  @override
  String get symptomBleeding => '出血 / 渗液';

  @override
  String get symptomSpreading => '迅速扩散';

  @override
  String get symptomFever => '伴有发热';

  @override
  String get symptomNonHealing => '超过4周未愈合溃疡/结痂';

  @override
  String get symptomOver6mm => '直径超过6毫米或边缘不规则';

  @override
  String get symptomNoTrauma => '无外伤自发出现';

  @override
  String get symptomRoughDots => '粗糙表面 / 细小黑点';

  @override
  String get symptomSunHormone => '日晒、激素或痘印色斑';

  @override
  String get bruiseGuideTitle => '淤青颜色阶段指南';

  @override
  String get wartGuideTitle => '疣类初筛与安全提示';

  @override
  String get abcdeGuideTitle => '色素痣 ABCDE 自查指南';

  @override
  String get abcdeGuideSubtitle => '皮肤科医生用于痣与皮肤癌初筛的5项关键信号';

  @override
  String get labScreenTitle => '化验与医院报告';

  @override
  String get labTabReports => '我的报告';

  @override
  String get labTabTrends => '趋势追踪';

  @override
  String get labAddBtn => '添加报告 / 血检';

  @override
  String get labEmptyTitle => '暂无已保存的血检报告';

  @override
  String get labEmptyDesc => '上传 PDF 或 JPG 化验单；可选填医院诊断或症状，获取通俗易懂的解读摘要。';

  @override
  String get labAddFirstBtn => '添加首份报告';

  @override
  String get labTrendsEmptyDesc =>
      '保存不同日期的血检后，这里将展示血红蛋白、铁蛋白、血糖、TSH、维生素D等长期趋势图。';

  @override
  String labParamsCount(int count) {
    return '$count 项指标';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count 项异常';
  }

  @override
  String labDetailParamsTitle(int count) {
    return '指标评估（$count）';
  }

  @override
  String get labEnteredDiagnosisTitle => '医院 / 医生诊断';

  @override
  String get labEnteredComplaintTitle => '您的症状 / 备注';

  @override
  String get labInterpretationTitle => '通俗解读';

  @override
  String get labCopyDoctorSummaryBtn => '给医生看 • 复制摘要';

  @override
  String get labSummaryCopied => '化验摘要已复制。';

  @override
  String get labExportPdfBtn => '导出就医 PDF 报告';

  @override
  String get labAddSheetTitle => '添加医院 / 血检报告';

  @override
  String get labReportTitleField => '报告标题';

  @override
  String get labDefaultReportTitle => '血检结果';

  @override
  String get labStep1Upload => '1. 上传 PDF 或 JPG 化验单';

  @override
  String get labUploadPdfJpgBtn => '上传 PDF 或 JPG';

  @override
  String get labCameraCaptureBtn => '拍照上传';

  @override
  String get labStep2Context => '2. 医院诊断与备注（可选）';

  @override
  String get labStep2ContextHint => '可填写想了解的医生诊断或自身症状，两项均可留空。';

  @override
  String get labDiagnosisField => '医院 / 医生诊断（可留空）';

  @override
  String get labComplaintField => '您的症状 / 问题（可留空）';

  @override
  String get labStep3PasteManual => '3. 粘贴报告文本或手动录入指标';

  @override
  String get labParseTextBtn => '读取并解析文本';

  @override
  String get labParamDropdown => '检验项目';

  @override
  String labValueField(String unit) {
    return '数值（$unit）';
  }

  @override
  String get labAddValueBtn => '+ 添加';

  @override
  String labParsedValuesTitle(int count) {
    return '已识别数值（$count）';
  }

  @override
  String get labSaveEvaluateBtn => '评估并按日期保存';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count 条记录 • 变化：$delta • 最新：$status';
  }

  @override
  String get vitalsScreenTitle => '血压与血糖追踪';

  @override
  String get vitalsCopySummaryTooltip => '复制就医摘要';

  @override
  String get vitalsCopyEmptyMsg => '请先添加血压或血糖记录再生成摘要。';

  @override
  String get vitalsSummaryCopied => '血压与血糖摘要已复制。';

  @override
  String get vitalsAddBpBtn => '记录血压';

  @override
  String get vitalsAddSugarBtn => '记录血糖';

  @override
  String get vitalsBpEmptyTitle => '暂无血压记录';

  @override
  String get vitalsBpEmptyDesc => '按日期记录收缩压、舒张压和脉搏以查看趋势图。';

  @override
  String get vitalsBpAddFirstBtn => '添加首次血压记录';

  @override
  String get vitalsSugarEmptyTitle => '暂无血糖记录';

  @override
  String get vitalsSugarEmptyDesc => '记录空腹、餐后2小时或随机血糖以追踪变化趋势。';

  @override
  String get vitalsSugarAddFirstBtn => '添加首次血糖记录';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return '平均（$count次）：$sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • 脉搏 $pulse 次/分';
  }

  @override
  String get vitalsBpHistoryTitle => '血压历史记录';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return '平均（$count次）：$avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => '血糖历史记录';

  @override
  String get vitalsNewBpTitle => '新增血压记录';

  @override
  String get vitalsSystolicField => '收缩压（高压）';

  @override
  String get vitalsDiastolicField => '舒张压（低压）';

  @override
  String get vitalsPulseField => '脉搏（可选）';

  @override
  String get vitalsNoteField => '备注（可选）';

  @override
  String get vitalsSaveBpBtn => '保存血压';

  @override
  String get vitalsNewSugarTitle => '新增血糖记录';

  @override
  String get vitalsSugarValueField => '血糖（mg/dL）';

  @override
  String get vitalsSaveSugarBtn => '保存血糖';

  @override
  String get chartAddReadingHint => '添加记录以查看趋势图';
}
