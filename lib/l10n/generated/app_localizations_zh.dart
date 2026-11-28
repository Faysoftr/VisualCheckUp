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

  @override
  String get loginTermsTitle => '使用条款与医疗声明';

  @override
  String get loginTermsCheckbox =>
      '我理解 VisualCheckUp 不提供确切医疗诊断，仅用于初步健康参考，并同意使用条款。';

  @override
  String get loginTermsRequiredMsg => '登录前请先勾选并同意使用条款与医疗声明。';

  @override
  String get loginTermsReadMore => '查看条款';

  @override
  String get loginTermsModalBody =>
      '• 非医疗诊断：VisualCheckUp 不是医疗器械，不能替代专业医生的诊断或治疗。\n\n• 仅供参考：视觉检查、化验单摘要与身高体重/BMI评估仅用于日常健康记录与就医准备。\n\n• 紧急提示：如出现胸痛、呼吸困难、剧烈疼痛或突发症状，请立即前往医院急诊。\n\n• 隐私保护：您的健康数据默认仅保存在本地设备，不会向第三方出售或共享。';

  @override
  String get loginTermsAcceptBtn => '我已阅读并同意';

  @override
  String atlasFilterAll(int count) {
    return '临床图谱 ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return '紧急警示 ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return '居家临床自测 ($count)';
  }

  @override
  String get atlasUrgentSectionTitle => '需尽快就医评估的警示征象';

  @override
  String get atlasTapToCompareHint => '点击任意卡片即可与健康参考图并排放大对比。';

  @override
  String get atlasVisualCueLabel => '视觉特征';

  @override
  String get atlasClinicalContextLabel => '可能临床背景';

  @override
  String get atlasPossibleContextShort => '可能背景';

  @override
  String get atlasWarningPrefix => '警示';

  @override
  String get atlasCloseBtn => '关闭';

  @override
  String get atlasCaptureProtocolTitle => '最佳拍摄规范';

  @override
  String get atlasHomeSelfTestsSectionTitle => '可居家完成的临床初筛自测';

  @override
  String get atlasSelfTestNormalPrefix => '正常';

  @override
  String get atlasSelfTestWarningPrefix => '注意';

  @override
  String get fitzpatrickScaleTitle => 'Fitzpatrick 皮肤光型与 ITA° 校准量表';

  @override
  String get fitzpatrickScaleSubtitle =>
      '应用通过测量周围健康皮肤的 ITA° 角度，按您的肤色光型自适应校准分析阈值。';

  @override
  String get resultVisualCompareTitle => '临床参考图谱并排对比';

  @override
  String get resultHealthyShort => '健康参考';

  @override
  String get resultMatchedShort => '匹配特征';

  @override
  String get resultViewFullAtlasBtn => '查看完整临床图谱';

  @override
  String get resultHomeSelfTestsBtn => '居家临床自测';

  @override
  String get resultClinicalBiomarkersTitle => '定量临床测量指标';

  @override
  String get cameraEyeModeSclera => '模式：巩膜（黄疸）';

  @override
  String get cameraEyeModeConjunctiva => '下眼睑结膜（贫血）';

  @override
  String get cameraClinicalAtlasChip => '自测与图谱';

  @override
  String get bristolScaleTitle => '布里斯托大便性状量表（可选 • 1–7型）';

  @override
  String get bristolType1Title => '1型 • 硬块颗粒';

  @override
  String get bristolType2Title => '2型 • 块状条形';

  @override
  String get bristolType3Title => '3型 • 表面裂纹';

  @override
  String get bristolType4Title => '4型 • 光滑柔软（理想）';

  @override
  String get bristolType5Title => '5型 • 软团块';

  @override
  String get bristolType6Title => '6型 • 糊状松散';

  @override
  String get bristolType7Title => '7型 • 完全水样';

  @override
  String get metricFitzpatrickPhototype => 'Fitzpatrick 光型';

  @override
  String get metricAbcdeAsymmetry => 'A — 不对称性';

  @override
  String get metricAbcdeBorder => 'B — 边缘不规则度';

  @override
  String get metricAbcdeColors => 'C — 皮肤镜颜色数';

  @override
  String get metricErythemaDelta => '红斑指数 Δ';

  @override
  String get metricAnnularClearing => '环状中心消退';

  @override
  String get metricErythemaIndex => '红斑指数 (EI)';

  @override
  String get metricScleraBilirubin => '巩膜胆红素指数';

  @override
  String get metricHemorrhagePatch => '致密出血区面积';

  @override
  String get metricNailErythema => '甲床红斑指数';

  @override
  String get metricBeauGroove => '博氏横向凹槽';

  @override
  String get metricTerryLindsaySplit => '近端/远端色差分割';

  @override
  String get metricSplinterStreak => '裂片状出血比例';

  @override
  String get metricGeographicTongue => '地图舌评分';

  @override
  String get metricYellowCoating => '黄苔比例';

  @override
  String get metricBristolScale => '布里斯托量表';

  @override
  String get hubStartNewScan => '开始新扫描';

  @override
  String get hubPickFromGallery => '相册';

  @override
  String hubPastScansTitle(int count) {
    return '历史记录 ($count)';
  }

  @override
  String get hubTotalScansLabel => '总检查次数';

  @override
  String get hubLastScanLabel => '最近检查';

  @override
  String get hubLatestStatusLabel => '最新状态';

  @override
  String get hubFilterAll => '全部';

  @override
  String get hubFilterAttention => '关注 / 紧急';

  @override
  String get hubFilterWithPhoto => '含照片';

  @override
  String get hubColPhoto => '照片';

  @override
  String get hubColDate => '日期';

  @override
  String get hubColFinding => '结果与摘要';

  @override
  String get hubColStatus => '状态';

  @override
  String get hubCompareModeBtn => '对比两次记录';

  @override
  String hubCompareSelectHint(int count) {
    return '从表格中选择 2 条记录进行并排对比 ($count/2)';
  }

  @override
  String get hubCompareActionBtn => '并排对比';

  @override
  String get hubCompareCancelBtn => '取消';

  @override
  String get hubCompareSheetTitle => '历史记录并排对比';

  @override
  String get hubCompareOlderLabel => '较早';

  @override
  String get hubCompareNewerLabel => '较新';

  @override
  String get hubCompareMetricsTitle => '临床指标对比';

  @override
  String hubEmptyTitle(String category) {
    return '暂无 $category 扫描记录';
  }

  @override
  String get hubEmptySubtitle => '点击上方开始首次扫描。每次检查都会连同缩略图与完整分析报告按日期保存在此处。';

  @override
  String get hubDoctorSummaryBtn => '医生摘要';

  @override
  String get photoTapToZoomHint => '点击照片全屏缩放查看';

  @override
  String get photoZoomTitle => '拍摄照片';

  @override
  String get resultDeleteRecordTooltip => '删除记录';

  @override
  String get resultDeleteConfirmTitle => '删除此条检查记录？';

  @override
  String get resultDeleteConfirmBody => '此检查记录将从本地历史记录中永久删除。';

  @override
  String get resultDeleteBtn => '删除';

  @override
  String get labLargeTextBtn => '大字模式';

  @override
  String get labLargeTextOnBtn => '大字模式：已开启';

  @override
  String get labSeniorOverviewTitle => '您的报告简明总结';

  @override
  String labSeniorNormalBullet(int count) {
    return '有 $count 项指标在正常参考范围内。';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '有 $count 项指标超出参考范围——下方有通俗易懂的逐条说明。';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '有 $count 项指标明显偏离正常值——请尽快带报告咨询医生。';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '有 $count 项常见基础检查未包含在本次报告中。';
  }

  @override
  String get labAttentionSectionTitle => '需要重点关注的指标';

  @override
  String get labNormalSectionTitle => '正常的指标（请放心）';

  @override
  String get labMissingSectionTitle => '本次报告未包含的基础项目';

  @override
  String get labMissingSectionExplain =>
      '并非每次抽血都会检查所有项目。以下常见基础指标不在本次报告内，因此未作评估。';

  @override
  String get labNotInReportBadge => '报告中未包含';

  @override
  String get labWhatItMeansLabel => '这是什么意思？';

  @override
  String get labWhatToDoLabel => '建议怎么做？';

  @override
  String get labAddAnotherPageBtn => '拍摄下一页';

  @override
  String labPagesReadBadge(int count) {
    return '已读取 $count 页';
  }

  @override
  String get labPhotoOfflineHint =>
      '已添加报告照片。如需自动识别纸质报告照片，请在设置中开启云端 AI，或在下方手动输入数值。';

  @override
  String get labAllValuesNormalMsg => '本次报告记录的所有指标均在正常参考范围内。';

  @override
  String get medTitle => '用药与健康闹钟提醒';

  @override
  String get medSubtitle => '带药品照片的吃药、胰岛素及测量闹钟';

  @override
  String get medMenuTitle => '用药闹钟';

  @override
  String get medHomeCardEmpty => '暂无闹钟 — 添加第一个用药提醒';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return '今日已服 $taken/$total';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$count 个启用闹钟';
  }

  @override
  String get medTabToday => '今日';

  @override
  String get medTabAll => '全部闹钟';

  @override
  String get medAddAlarm => '添加新闹钟';

  @override
  String get medEditAlarm => '编辑闹钟';

  @override
  String get medCatPill => '药物 / 药片';

  @override
  String get medCatDiabetes => '降糖药 / 胰岛素';

  @override
  String get medCatBloodPressure => '降压药';

  @override
  String get medCatVitamin => '维生素 / 保健品';

  @override
  String get medCatDropsCream => '眼药水 / 药膏';

  @override
  String get medCatCheckup => '测量 / 复查';

  @override
  String get medCatOther => '其他';

  @override
  String get medMealAnytime => '不限时间';

  @override
  String get medMealBefore => '饭前';

  @override
  String get medMealAfter => '饭后';

  @override
  String get medMealWith => '随餐';

  @override
  String get medMealBedtime => '睡前';

  @override
  String get medDayMon => '周一';

  @override
  String get medDayTue => '周二';

  @override
  String get medDayWed => '周三';

  @override
  String get medDayThu => '周四';

  @override
  String get medDayFri => '周五';

  @override
  String get medDaySat => '周六';

  @override
  String get medDaySun => '周日';

  @override
  String get medEveryDay => '每天';

  @override
  String get medWeekdays => '工作日';

  @override
  String get medWeekends => '周末';

  @override
  String get medFieldCategory => '分类';

  @override
  String get medFieldName => '药品 / 提醒名称';

  @override
  String get medFieldNameHint => '例如：二甲双胍 1000mg、晚间胰岛素...';

  @override
  String get medFieldNameRequired => '请输入药品或提醒名称。';

  @override
  String get medFieldDosage => '剂量 / 用量（可选）';

  @override
  String get medFieldDosageHint => '例如：1片、12单位、2滴';

  @override
  String get medFieldDescription => '提醒说明（闹钟响时显示）';

  @override
  String get medFieldDescriptionHint => '例如：早餐前30分钟温水送服';

  @override
  String get medFieldMealTiming => '服用时机';

  @override
  String get medFieldTime => '闹钟时间';

  @override
  String get medFieldDays => '重复日期';

  @override
  String get medFieldPhoto => '药品照片（闹钟响时大图显示）';

  @override
  String get medTakePhoto => '拍照';

  @override
  String get medPickGallery => '从相册选';

  @override
  String get medRemovePhoto => '移除照片';

  @override
  String get medPhotoHint => '拍下药盒或胰岛素笔，到点响铃时会在屏幕上清晰显示。';

  @override
  String get medSoundToggle => '闹钟铃声';

  @override
  String get medVibrateToggle => '震动提醒';

  @override
  String get medSaveAlarm => '保存闹钟';

  @override
  String get medAlarmSaved => '闹钟已保存并设置。';

  @override
  String get medAlarmDeleted => '闹钟已删除。';

  @override
  String get medDeleteConfirmTitle => '删除闹钟';

  @override
  String medDeleteConfirmBody(String title) {
    return '确定要永久删除“$title”闹钟吗？';
  }

  @override
  String get medStatusTaken => '已服用';

  @override
  String get medStatusSnoozed => '已推迟';

  @override
  String get medStatusSkipped => '已跳过';

  @override
  String get medStatusPending => '待服用';

  @override
  String get medActionTaken => '已服用';

  @override
  String get medActionSnooze => '10分钟后再响';

  @override
  String get medActionSkip => '今日跳过';

  @override
  String get medActionUndo => '撤销';

  @override
  String get medActionPreviewAlarm => '测试闹钟';

  @override
  String get medRingHeader => '用药时间到了';

  @override
  String get medRingNoteTitle => '提醒说明';

  @override
  String get medRingNoPhoto => '未添加药品照片';

  @override
  String get medRingTapZoom => '点击照片查看大图';

  @override
  String get medRingSnoozedToast => '已推迟10分钟。';

  @override
  String get medRingTakenToast => '太棒了！今日剂量已标记为已服用。';

  @override
  String get medTodayProgressTitle => '今日用药计划';

  @override
  String medNextAlarmLabel(String time, String title) {
    return '下一个闹钟：$time • $title';
  }

  @override
  String get medNoTodayAlarms => '今天没有安排用药闹钟。';

  @override
  String get medEmptyTitle => '还没有用药闹钟';

  @override
  String get medEmptyBody => '为降糖药、胰岛素或降压药添加带照片的闹钟。到点后药品照片和说明会清晰显示在屏幕上。';

  @override
  String get medQuickPresetDiabetes => '降糖 / 胰岛素';

  @override
  String get medQuickPresetBp => '降压药';

  @override
  String get medQuickPresetVitamin => '维生素';

  @override
  String get dietMenuTitle => '饮食计划与AI热量追踪';

  @override
  String get dietHomeCardTitle => '饮食与减脂方案';

  @override
  String get dietHomeCardEmpty => '现成食谱、打卡与体重追踪';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return '第$day/$total天 • 达标率$percent%';
  }

  @override
  String get dietCalorieQuickTitle => 'AI 拍照算热量';

  @override
  String get dietCalorieQuickSubtitle => '拍下餐盘照片，智能估算热量与三大营养素';

  @override
  String get dietTabActive => '我的饮食';

  @override
  String get dietTabTemplates => '现成方案';

  @override
  String get dietTabWeight => '体重追踪';

  @override
  String get dietTabCalories => 'AI 算热量';

  @override
  String get dietStartDiet => '开始饮食计划';

  @override
  String get dietRestartOrChange => '更换方案';

  @override
  String get dietEndDiet => '结束计划';

  @override
  String get dietEndDietConfirm => '确定结束当前饮食计划吗？您的打卡与体重记录将保留。';

  @override
  String get dietNoActiveTitle => '暂无进行中的饮食计划';

  @override
  String get dietNoActiveBody =>
      '从地中海、控糖、DASH降压、均衡减脂、16:8轻断食或高蛋白模板中选择，追踪每日达标与体重变化。';

  @override
  String get dietBrowseTemplates => '浏览现成方案';

  @override
  String get dietStartDate => '开始日期';

  @override
  String get dietEndDate => '结束日期';

  @override
  String get dietStartWeight => '起始体重 (kg)';

  @override
  String get dietTargetWeight => '目标体重 (kg)';

  @override
  String get dietDailyCalorieTarget => '每日热量目标 (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days 天';
  }

  @override
  String dietDayProgress(int day, int total) {
    return '第 $day / $total 天';
  }

  @override
  String dietDaysLeft(int days) {
    return '剩余 $days 天';
  }

  @override
  String dietComplianceRate(int percent) {
    return '达标率：$percent%';
  }

  @override
  String get dietFollowed => '已遵守';

  @override
  String get dietNotFollowed => '未遵守';

  @override
  String get dietPending => '待记录';

  @override
  String get dietSlotBreakfast => '早餐';

  @override
  String get dietSlotMorningSnack => '上午加餐';

  @override
  String get dietSlotLunch => '午餐';

  @override
  String get dietSlotAfternoonSnack => '下午加餐';

  @override
  String get dietSlotDinner => '晚餐';

  @override
  String get dietAlternativesLabel => '可替换';

  @override
  String dietWaterTarget(String liters) {
    return '饮水目标：$liters 升';
  }

  @override
  String get dietRulesTitle => '方案要点';

  @override
  String get dietSampleMenuTitle => '示例一日食谱';

  @override
  String get dietStartedToast => '饮食计划已开启！加油！';

  @override
  String get dietEndedToast => '当前饮食计划已结束。';

  @override
  String get dietWeightLogTitle => '饮食期体重追踪';

  @override
  String get dietWeightAdd => '记录体重';

  @override
  String get dietWeightField => '当前体重 (kg)';

  @override
  String get dietWeightNote => '备注（可选）';

  @override
  String get dietWeightNoteHint => '例如：早晨空腹称重';

  @override
  String get dietWeightEmpty => '暂无体重记录，添加第一条体重数据开始追踪。';

  @override
  String get dietWeightCurrent => '当前';

  @override
  String get dietWeightTarget => '目标';

  @override
  String get dietWeightChange => '变化';

  @override
  String get dietWeightSaved => '体重已保存。';

  @override
  String get dietCalorieTitle => 'AI 餐盘热量计算器';

  @override
  String get dietCalorieSubtitle => '无需开启饮食计划也能单独使用 — 拍下餐盘或输入菜名。';

  @override
  String get dietSnapPlateCamera => '拍摄餐盘';

  @override
  String get dietPickPlateGallery => '从相册选择';

  @override
  String get dietFoodDescLabel => '食物说明 / 分量（可选）';

  @override
  String get dietFoodDescHint => '例如：烤鸡胸肉、杂粮饭、蔬菜沙拉、酸奶';

  @override
  String get dietCalculateFromText => '按文字估算';

  @override
  String get dietAnalyzingPlate => '正在分析餐盘热量与营养成分...';

  @override
  String get dietResultTitle => '热量与营养分析';

  @override
  String get dietAiPoweredBadge => 'Gemini AI 视觉识别';

  @override
  String get dietOnDeviceBadge => '本地智能估算';

  @override
  String get dietProtein => '蛋白质';

  @override
  String get dietCarbs => '碳水';

  @override
  String get dietFat => '脂肪';

  @override
  String get dietFiber => '膳食纤维';

  @override
  String get dietPortionScale => '分量比例';

  @override
  String get dietSaveMealLog => '保存到今日记录';

  @override
  String get dietMealLoggedToast => '已将本餐热量加入今日记录。';

  @override
  String get dietTodayTotalCalories => '今日累计';

  @override
  String get dietRecentScans => '已识别餐食';

  @override
  String get dietNoScansYet => '还没有餐盘记录，拍一张餐盘照片即可算热量。';

  @override
  String dietHealthScore(int score) {
    return '均衡评分：$score/10';
  }

  @override
  String get dietTodayLabel => '今天';

  @override
  String get medCatHerbalTea => '花草茶 / 养生茶';

  @override
  String get medCatCustom => '其他（手动输入）';

  @override
  String get medFieldCustomCategory => '自定义分类名称';

  @override
  String get medFieldCustomCategoryHint => '例如：益生菌、喝水、理疗锻炼...';

  @override
  String get medQuickPresetHerbalTea => '花草茶';

  @override
  String get dietCreateCustom => '创建我的专属饮食';

  @override
  String get dietCreateCustomSubtitle => '手动录入营养师食谱或自定义每日餐单';

  @override
  String get dietCustomNameLabel => '饮食计划名称';

  @override
  String get dietCustomNameHint => '例如：营养师食谱、我的减脂餐...';

  @override
  String get dietCustomNameRequired => '请输入饮食计划名称。';

  @override
  String get dietCustomMealHint => '这顿计划吃什么？';

  @override
  String get dietCustomMealCaloriesHint => 'kcal（可选）';

  @override
  String get dietCustomAtLeastOneMeal => '请至少填写一顿餐食。';

  @override
  String get dietCustomTemplatesTitle => '我的自定义方案';

  @override
  String get dietReadyTemplatesTitle => '现成饮食模板';

  @override
  String get donateTooltip => '赞助与支持';

  @override
  String get donateMenuLabel => '支持 VisualCheckUp';

  @override
  String get donateMenuSubtitle => '请喝咖啡、吃饭或送份心意，支持免费健康工具';

  @override
  String get donatePopupTitle => '支持 VisualCheckUp';

  @override
  String get donatePopupSubtitle => '您的自愿支持帮助我们持续免费改进视觉健康筛查、化验单解读、用药闹钟和饮食计划功能。';

  @override
  String get donateTierCoffeeTitle => '请喝咖啡';

  @override
  String get donateTierCoffeeDesc => '为开发团队送上一杯热咖啡';

  @override
  String get donateTierMealTitle => '请吃一顿饭';

  @override
  String get donateTierMealDesc => '大力支持更多健康新功能';

  @override
  String get donateTierGiftTitle => '送出一份礼物';

  @override
  String get donateTierGiftDesc => '帮助承担 AI 与服务器维护费用';

  @override
  String get donateTierGoldTitle => '重磅支持';

  @override
  String get donateTierGoldDesc => '加速推出更多医学模块与语言支持';

  @override
  String get donateTierHeroTitle => '健康守护者';

  @override
  String get donateTierHeroDesc => '助力更多家庭免费使用健康追踪工具';

  @override
  String get donatePopularBadge => '最受欢迎';

  @override
  String donateConfirmButton(String price) {
    return '支持 $price';
  }

  @override
  String get donateLaterButton => '以后再说';

  @override
  String get donateThanksTitle => '衷心感谢您的支持！';

  @override
  String donateThanksBody(String tier, String price) {
    return '您的「$tier」（$price）支持意义非凡，感谢您与我们一起让 VisualCheckUp 变得更好！';
  }

  @override
  String get donateSupporterBadge => '支持者 • 感谢您！';

  @override
  String get donateStoreNotice => '一次性自愿支持 • 非自动续费订阅';

  @override
  String get medFieldAlarmSound => '闹钟铃声';

  @override
  String get medAlarmSoundClassic => '经典闹钟';

  @override
  String get medAlarmSoundClassicDesc => '清脆的经典闹钟提示音';

  @override
  String get medAlarmSoundGentle => '轻柔旋律';

  @override
  String get medAlarmSoundGentleDesc => '柔和舒缓的钟声旋律';

  @override
  String get medAlarmSoundRadar => '现代雷达';

  @override
  String get medAlarmSoundRadarDesc => '清晰有节奏的现代闹钟音';

  @override
  String get medAlarmSoundBell => '健康铃声';

  @override
  String get medAlarmSoundBellDesc => '清亮的双铃闹钟声';

  @override
  String get medAlarmSoundUrgent => '强力紧急警报';

  @override
  String get medAlarmSoundUrgentDesc => '重要剂量专用的响亮提示音';

  @override
  String get medAlarmSoundSystem => '手机闹钟铃声';

  @override
  String get medAlarmSoundSystemDesc => '使用设备默认的闹钟铃声';

  @override
  String get medSoundPreviewPlay => '试听';

  @override
  String get medSoundPreviewStop => '停止';

  @override
  String get medSoundSilent => '静音';

  @override
  String get medPreviewModeBadge => '预览';

  @override
  String get commMenuTitle => '健康社区';

  @override
  String get commHomeSubtitle => '全球健康伙伴、主页点赞与安全私信';

  @override
  String get commTabDiscover => '发现';

  @override
  String get commTabMessages => '消息';

  @override
  String get commTabMyProfile => '我的主页';

  @override
  String get commSafetyBanner => '仅供健康经验交流与鼓励，不构成医疗诊断。您的私密化验单和照片绝不会被公开。';

  @override
  String get commSearchHint => '按姓名、城市或健康目标搜索...';

  @override
  String get commFilterAllGoals => '全部目标';

  @override
  String get commFilterAllCountries => '全球';

  @override
  String get commEmptyDiscover => '暂无符合筛选条件的健康主页。';

  @override
  String get commGoalDiabetes => '血糖与控糖';

  @override
  String get commGoalBloodPressure => '血压与心脏';

  @override
  String get commGoalWeightDiet => '体重与健康饮食';

  @override
  String get commGoalHealthyLiving => '健康生活';

  @override
  String get commGoalHerbalWellness => '花草茶与自然调理';

  @override
  String get commGoalParentingGrowth => '亲子与儿童成长';

  @override
  String get commGoalSkinCare => '皮肤与日常护理';

  @override
  String get commGoalFitnessWalk => '步行与运动';

  @override
  String get commGoalSleepStress => '睡眠与减压';

  @override
  String commLikesCount(int count) {
    return '$count 个赞';
  }

  @override
  String get commLikeAction => '点赞主页';

  @override
  String get commUnlikeAction => '已赞';

  @override
  String get commSendMessage => '发送消息';

  @override
  String get commMessagesDisabled => '该成员已关闭私信功能。';

  @override
  String get commOptInTitle => '加入全球健康社区';

  @override
  String get commOptInBody =>
      '结识世界各地与您拥有相同健康目标的伙伴。加入完全自愿，您的化验单和扫描记录始终保持 100% 私密。';

  @override
  String get commOptInButton => '创建我的健康主页';

  @override
  String get commFieldDisplayName => '显示名称';

  @override
  String get commFieldNickname => '用户名 (@handle)';

  @override
  String get commFieldCountry => '国家/地区';

  @override
  String get commFieldCity => '城市（选填）';

  @override
  String get commFieldLanguage => '常用语言';

  @override
  String get commFieldGoals => '健康与养生目标';

  @override
  String get commFieldBio => '个人简介与健康历程';

  @override
  String get commFieldDailyFocus => '每日健康关注';

  @override
  String get commPrivacySection => '隐私与消息设置';

  @override
  String get commToggleDiscoverable => '在全球发现中展示我的主页';

  @override
  String get commToggleHideRealName => '隐藏真实姓名（仅显示 @用户名）';

  @override
  String get commToggleHidePhoto => '隐藏头像照片';

  @override
  String get commToggleAllowMessages => '允许接收私信';

  @override
  String get commToggleRequireApproval => '新私信请求需经我同意';

  @override
  String get commUploadPhoto => '上传照片';

  @override
  String get commRemovePhoto => '移除照片';

  @override
  String get commSaveProfile => '保存健康主页';

  @override
  String get commProfileSaved => '健康社区主页已更新。';

  @override
  String get commLeaveCommunity => '退出社区并删除公开主页';

  @override
  String get commLeftCommunity => '您的公开社区主页已移除。';

  @override
  String get commInboxEmpty => '暂无对话。去发现页结识健康伙伴打个招呼吧！';

  @override
  String get commMessageRequestBadge => '消息请求';

  @override
  String get commRequestBannerTitle => '新的消息请求';

  @override
  String get commRequestBannerBody => '同意后即可继续聊天，也可拒绝或拉黑该成员。';

  @override
  String get commRequestAccept => '同意';

  @override
  String get commRequestDecline => '拒绝';

  @override
  String get commChatPlaceholder => '写一句温暖鼓励的话...';

  @override
  String get commAttachPhoto => '添加图片';

  @override
  String get commPhotoLabel => '图片';

  @override
  String get commRateLimited => '请稍等几秒后再发送下一条消息。';

  @override
  String get commBlockedNotice => '因拉黑设置无法发送消息。';

  @override
  String get commMuteChat => '静音';

  @override
  String get commUnmuteChat => '取消静音';

  @override
  String get commHideChat => '隐藏对话';

  @override
  String get commBlockUser => '拉黑用户';

  @override
  String get commUnblockUser => '取消拉黑';

  @override
  String get commBlockedToast => '已拉黑该用户。';

  @override
  String get commReportUser => '举报';

  @override
  String get commReportTitle => '举报成员或消息';

  @override
  String get commReportReasonInappropriate => '不当内容';

  @override
  String get commReportReasonSpam => '垃圾广告';

  @override
  String get commReportReasonHarassment => '骚扰或仇恨言论';

  @override
  String get commReportReasonMisinfo => '不安全的医疗建议/虚假信息';

  @override
  String get commReportReasonOther => '其他';

  @override
  String get commReportNoteHint => '补充说明（选填）...';

  @override
  String get commReportSubmit => '提交举报';

  @override
  String get commReportSent => '感谢反馈，安全举报已提交。';

  @override
  String get commDeleteForMe => '仅对我删除';

  @override
  String get commDeleteForEveryone => '对所有人删除';

  @override
  String get commOnlineNow => '在线';

  @override
  String get commFilterOnlineOnly => '当前在线';

  @override
  String get commFilterSameCondition => '同病相怜';

  @override
  String get commFilterAllConditions => '全部慢病';

  @override
  String get commSameConditionPrompt => '请在“我的主页”添加您的慢性病标签，以便匹配相同经历的伙伴。';

  @override
  String get commFieldChronicConditions => '慢性病标签（选填）';

  @override
  String get commFieldCustomCondition => '其他慢性病（选填）';

  @override
  String get commFieldCustomConditionHint => '例如：纤维肌痛、多囊卵巢...';

  @override
  String get commToggleShowConditions => '在主页展示我的慢性病标签';

  @override
  String get commToggleShowOnline => '显示我的在线状态';

  @override
  String get condType1Diabetes => '1型糖尿病';

  @override
  String get condType2Diabetes => '2型糖尿病';

  @override
  String get condHypertension => '高血压';

  @override
  String get condAsthmaCopd => '哮喘 / 慢阻肺';

  @override
  String get condThyroidHashimoto => '甲状腺 / 桥本';

  @override
  String get condMigraine => '偏头痛';

  @override
  String get condHeartCondition => '心血管健康';

  @override
  String get condCeliacIbs => '乳糜泻 / 肠易激';

  @override
  String get condArthritis => '关节炎 / 风湿';

  @override
  String get condAnemia => '贫血';

  @override
  String get condKidneyHealth => '肾脏健康';

  @override
  String get condEczemaPsoriasis => '湿疹 / 银屑病';

  @override
  String get adminPanelTitle => '管理员控制面板';

  @override
  String get adminTabStats => '数据统计';

  @override
  String get adminTabAnnouncements => '全局公告';

  @override
  String get adminTabPromotions => '广告横幅';

  @override
  String get adminTabUsers => '用户管理';

  @override
  String get adminTabReports => '举报审核';

  @override
  String get adminStatOnline => '当前在线';

  @override
  String get adminStatMembers => '社区成员';

  @override
  String get adminStatLikes => '主页点赞';

  @override
  String get adminStatChats => '活跃对话';

  @override
  String get adminStatPendingReports => '待处理举报';

  @override
  String get adminStatActiveBanners => '生效公告/广告';

  @override
  String get adminConditionBreakdown => '慢性病分布统计';

  @override
  String get adminNewAnnouncement => '新建公告';

  @override
  String get adminNewPromotion => '新建广告/横幅';

  @override
  String get adminFieldTitle => '标题';

  @override
  String get adminFieldMessage => '内容 / 说明';

  @override
  String get adminFieldLink => '跳转链接 URL（选填）';

  @override
  String get adminFieldPlacement => '展示位置';

  @override
  String get adminPlacementHome => '首页顶部';

  @override
  String get adminPlacementCommunity => '社区顶部';

  @override
  String get adminPlacementProfile => '主页顶部';

  @override
  String get adminTypeInfo => '系统公告';

  @override
  String get adminTypeHealthTip => '健康提示';

  @override
  String get adminTypeWarning => '重要提醒';

  @override
  String get adminTypeCampaign => '活动推广';

  @override
  String get adminSearchUsersHint => '按姓名、国家或慢病搜索用户...';

  @override
  String get adminActionVerify => '认证';

  @override
  String get adminActionUnverify => '取消认证';

  @override
  String get adminActionSuspend => '停用';

  @override
  String get adminActionUnsuspend => '恢复';

  @override
  String get adminStatusSuspended => '已停用';

  @override
  String get adminStatusVerified => '已认证';

  @override
  String get adminReportResolve => '已处理';

  @override
  String get adminReportDismiss => '忽略';

  @override
  String get adminNoReports => '暂无举报记录。';

  @override
  String get adminNoAnnouncements => '暂无全局公告。';

  @override
  String get adminNoPromotions => '暂无广告横幅。';

  @override
  String get commMusicSectionTitle => '专注与舒缓音乐';

  @override
  String get commMusicTitleField => '曲目 / 歌单名称（可选）';

  @override
  String get commMusicUrlField => '音乐链接（YouTube、Spotify、SoundCloud）';

  @override
  String get commMusicInvalidUrl =>
      '请输入有效的 YouTube、Spotify、Apple Music 或 SoundCloud 链接。';

  @override
  String get commMusicEmpty => '暂未添加专注音乐。';

  @override
  String get commMusicListenAction => '收听';

  @override
  String get commMusicLikeAction => '喜欢音乐';

  @override
  String get commMusicListenersTitle => '听过的人';

  @override
  String get commMusicListenersEmpty => '还没有人收听这首音乐。';

  @override
  String commMusicUniqueListeners(int count) {
    return '$count 位听众';
  }

  @override
  String commMusicTotalPlays(int count) {
    return '播放 $count 次';
  }

  @override
  String commMusicPlayCountBadge(int count) {
    return '$count次';
  }

  @override
  String get commProfileLikersTitle => '主页点赞';

  @override
  String get commProfileLikersEmpty => '暂无主页点赞。';

  @override
  String get commSocialsSectionTitle => '社交媒体账号';

  @override
  String get commToggleShowSocials => '显示我的社交媒体账号';

  @override
  String get commSocialsHiddenHint => '对其他成员隐藏';

  @override
  String get commSocialsEmpty => '暂未添加社交媒体账号。';

  @override
  String get commPreviewMyProfile => '预览我的主页';

  @override
  String get safetyContentBlocked =>
      'This text contains inappropriate language, insults, or restricted content and cannot be posted.';

  @override
  String get safetyImageBlocked =>
      'This image did not pass safety verification and could not be uploaded.';

  @override
  String get safetyAccountSuspended =>
      'Your community access is temporarily suspended due to safety policy violations.';

  @override
  String get proMenuTitle => 'VisualCheckUp Pro';

  @override
  String get proMenuSubtitle =>
      'Unlimited lab analyses & ad-free health tracking';

  @override
  String get proPaywallTitle => 'Upgrade to VisualCheckUp Pro';

  @override
  String get proPaywallSubtitle =>
      'Unlock unlimited lab report analyses, full health trends, and an ad-free experience.';

  @override
  String get proPlanMonthly => 'Monthly';

  @override
  String get proPlanYearly => 'Yearly';

  @override
  String get proSaveBadge => 'Best Value • Save 42%';

  @override
  String get proPerMonth => '/ month';

  @override
  String get proPerYear => '/ year';

  @override
  String get proBenefitUnlimitedLabs => 'Unlimited blood & lab report analyses';

  @override
  String get proBenefitAiInsights => 'Unlimited AI PDF & photo lab extraction';

  @override
  String get proBenefitAdFree => 'Completely ad-free experience';

  @override
  String get proBenefitDoctorPriority =>
      'Priority verified doctor search & follow-up requests';

  @override
  String get proSubscribeButton => 'Activate VisualCheckUp Pro';

  @override
  String get proRestoreButton => 'Restore Purchases';

  @override
  String get proActiveBadge => 'VisualCheckUp Pro Active';

  @override
  String get proActivatedToast =>
      'VisualCheckUp Pro activated! Unlimited lab analyses unlocked.';

  @override
  String labFreeQuotaBanner(int remaining, int limit) {
    return 'Free Lab Analyses This Month: $remaining / $limit';
  }

  @override
  String get labProUnlimitedBanner =>
      'VisualCheckUp Pro • Unlimited Lab Analyses';

  @override
  String get labLimitReachedTitle => 'Monthly Free Lab Limit Reached';

  @override
  String get labLimitReachedBody =>
      'Free accounts can analyze up to 3 lab reports per month. Upgrade to VisualCheckUp Pro for unlimited analyses.';

  @override
  String get labUpgradeToProBtn => 'Go Pro (Unlimited)';

  @override
  String get doctorSearchTitle => '按国家搜索认证医生';

  @override
  String get doctorSearchSubtitle =>
      'Search licensed doctors by country & specialty for guidance and patient follow-up';

  @override
  String get doctorSearchHomeCta => 'Search Doctors';

  @override
  String get doctorApplyCta => '医生入驻申请';

  @override
  String get doctorSearchHint =>
      'Search by doctor name, city, clinic, or specialty...';

  @override
  String get doctorFilterAllSpecialties => 'All Specialties';

  @override
  String get doctorFilterFollowUpOnly => 'Patient Follow-Up Open';

  @override
  String get doctorEmptyResults =>
      'No verified doctors match your selected country or specialty yet.';

  @override
  String get doctorVerifiedBadge => 'Verified Doctor';

  @override
  String get doctorFollowUpBadge => 'Patient Follow-Up';

  @override
  String doctorExperienceYears(int years) {
    return '$years yrs exp.';
  }

  @override
  String get doctorRequestFollowUpBtn => 'Request Follow-Up';

  @override
  String get doctorFollowUpDialogTitle => 'Request Patient Follow-Up';

  @override
  String get doctorFollowUpNoteHint =>
      'Briefly describe your chronic condition or follow-up goal...';

  @override
  String get doctorFollowUpSent =>
      'Your patient follow-up request has been sent to the doctor!';

  @override
  String get doctorApplicationTitle => 'Verified Doctor Application';

  @override
  String get doctorApplicationSubtitle =>
      'Join VisualCheckUp\'s global doctor directory to guide patients and offer structured follow-ups.';

  @override
  String get doctorFieldTitle => 'Medical Title';

  @override
  String get doctorFieldFullName => 'Full Name';

  @override
  String get doctorFieldSpecialty => 'Medical Specialty';

  @override
  String get doctorFieldClinic => 'Hospital / Clinic Name';

  @override
  String get doctorFieldLicense => 'Medical License / Diploma No';

  @override
  String get doctorFieldExperience => 'Years of Experience';

  @override
  String get doctorFieldBio => 'Professional Bio & Clinical Focus';

  @override
  String get doctorToggleFollowUp => 'Accept Patient Follow-Up Requests';

  @override
  String get doctorUploadDocBtn => 'Upload Diploma / License Photo (Optional)';

  @override
  String get doctorPlanSectionTitle => 'Doctor Directory Membership Plan';

  @override
  String get doctorPlanMonthlyTitle => 'Doctor Standard (Monthly)';

  @override
  String get doctorPlanMonthlyDesc =>
      'Verified badge, country & specialty listing, direct patient chat';

  @override
  String get doctorPlanYearlyTitle => 'Doctor Pro + Follow-Up (Yearly)';

  @override
  String get doctorPlanYearlyDesc =>
      'Priority country ranking, structured patient follow-ups, unlimited connections';

  @override
  String get doctorSubmitApplicationBtn => 'Submit Doctor Application';

  @override
  String get doctorApplicationSubmitted =>
      'Your doctor application has been submitted for admin verification!';

  @override
  String get doctorApplicationPendingBadge =>
      'Application Pending Verification';

  @override
  String get adminTabDoctors => '医生';

  @override
  String get adminApproveDoctor => 'Approve';

  @override
  String get adminRejectDoctor => 'Reject';

  @override
  String get adminNoDoctorApps => 'No doctor applications yet.';

  @override
  String get specInternalMedicine => 'Internal Medicine';

  @override
  String get specCardiology => 'Cardiology';

  @override
  String get specDermatology => 'Dermatology';

  @override
  String get specEndocrinology => 'Endocrinology';

  @override
  String get specNeurology => 'Neurology';

  @override
  String get specOphthalmology => 'Ophthalmology';

  @override
  String get specPediatrics => 'Pediatrics';

  @override
  String get specFamilyMedicine => 'Family Medicine';

  @override
  String get specNutritionDietetics => 'Nutrition & Dietetics';

  @override
  String get specPsychiatry => 'Psychiatry';

  @override
  String get specPulmonology => 'Pulmonology';

  @override
  String get specNephrology => 'Nephrology';

  @override
  String get dailyHealthTipTitle => '每日健康小贴士';

  @override
  String birthdayCardTitle(String name) {
    return '生日快乐，$name！🎉';
  }

  @override
  String get birthdayCardSubtitle => '祝你新的一岁健康快乐。';

  @override
  String get commDrawerProfileSubtitle => '您的社交名片、心情与统计';

  @override
  String get commDrawerCommunitySubtitle => '发现 • 动态墙 • 小组 • 聊天';

  @override
  String get commTabWall => '动态墙';

  @override
  String get commTabGroups => '小组';

  @override
  String get commEditProfile => '编辑资料';

  @override
  String get commDoneEditing => '取消';

  @override
  String get commFriendsStat => '好友';

  @override
  String get commAddFriend => '加好友';

  @override
  String get commFriendPending => '已请求';

  @override
  String get commFriendsConnected => '好友';

  @override
  String get commFriendsSheetTitle => '健康好友';

  @override
  String get commFriendsEmpty => '还没有健康好友，去发现页认识新伙伴吧！';

  @override
  String get commMoodSectionTitle => '今日心情';

  @override
  String get commMoodEnergetic => '充满活力';

  @override
  String get commMoodCalm => '平静';

  @override
  String get commMoodGrateful => '感恩';

  @override
  String get commMoodFocused => '专注';

  @override
  String get commMoodTired => '疲惫';

  @override
  String get commMoodRecovering => '恢复中';

  @override
  String get commWallTitle => '经验与问答墙';

  @override
  String get commWallNewPost => '发布动态';

  @override
  String get commWallPostTitleHint => '标题（例如：晨走与血糖平衡）';

  @override
  String get commWallPostBodyHint => '分享您的经验或向社区提问...';

  @override
  String get commWallPublishBtn => '发布';

  @override
  String get commWallDoctorReplyBadge => '医生回复';

  @override
  String get commWallCommentsTitle => '评论';

  @override
  String get commWallCommentHint => '写下暖心评论...';

  @override
  String get commWallEmpty => '暂无动态，成为第一个分享的人吧！';

  @override
  String get commGroupsTitle => '互助小组';

  @override
  String get commGroupsCreate => '创建小组';

  @override
  String get commGroupsJoin => '加入';

  @override
  String get commGroupsJoined => '已加入';

  @override
  String get commGroupsOpenChat => '小组聊天';

  @override
  String commGroupsMembersCount(int count) {
    return '$count 位成员';
  }

  @override
  String get commGroupsNameHint => '小组名称';

  @override
  String get commGroupsDescHint => '小组简介与关注主题';

  @override
  String get commGroupsEmpty => '未找到符合条件的小组。';

  @override
  String get commToggleOnlyFriendsMsg => '仅允许好友给我发消息';

  @override
  String get commOpenCommunityCta => '社区';

  @override
  String get sfbGoToProfile => '前往个人主页';

  @override
  String get sfbMyMessages => '我的消息';

  @override
  String get sfbMyFriends => '我的好友';

  @override
  String get sfbSeeAll => '查看全部';

  @override
  String get sfbNewMembersTitle => '最新成员';

  @override
  String get sfbActiveMembersTitle => '最活跃成员';

  @override
  String get sfbLatestPostsTitle => '最新动态';

  @override
  String get sfbViewDetails => '查看详情';

  @override
  String get sfbAdminBadge => '管理员';

  @override
  String get sfbAdminConsoleTitle => '快速管理控制台';

  @override
  String get sfbAdminFounderBanner => '平台创始人与系统管理员';

  @override
  String get splashTagline => 'AI 智能驱动\n全方位健康追踪';
}
