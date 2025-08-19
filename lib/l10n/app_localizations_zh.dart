// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '🏃‍♂️ 跑步追踪器';

  @override
  String get homeTitle => '首页';

  @override
  String get profileTitle => '个人资料';

  @override
  String get settingsTitle => '设置';

  @override
  String get languageTitle => '语言';

  @override
  String get startRunning => '开始跑步';

  @override
  String get locationPermissionRequired => '需要位置权限';

  @override
  String get locationPermissionMessage => '此应用需要位置权限来追踪您的跑步路线。';

  @override
  String get grantPermission => '授予权限';

  @override
  String get deny => '拒绝';

  @override
  String get gettingLocation => '正在获取位置...';

  @override
  String get locationReady => 'GPS定位成功，位置已锁定';

  @override
  String get locationFailed => '位置获取失败，使用默认位置';

  @override
  String get gpsNotEnabled => 'GPS服务未开启';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get logout => '退出登录';

  @override
  String get welcome => '欢迎';

  @override
  String welcomeBack(String username) {
    return '欢迎回来，$username！';
  }

  @override
  String get username => '用户名';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get bio => '个人简介';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get selectAvatar => '选择头像';

  @override
  String get gallery => '相册';

  @override
  String get camera => '拍照';

  @override
  String get remove => '移除';

  @override
  String get avatarSelected => '头像已选择，记得保存更改';

  @override
  String get avatarSet => '头像已设置，记得保存更改';

  @override
  String get imageTooLarge => '图片文件过大，请选择小于2MB的图片';

  @override
  String selectAvatarFailed(String error) {
    return '选择头像失败: $error';
  }

  @override
  String cameraFailed(String error) {
    return '拍照失败: $error';
  }

  @override
  String get language => '语言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String languageChanged(String language) {
    return '语言已切换为$language';
  }

  @override
  String get countdown => '倒计时';

  @override
  String get ready => '准备';

  @override
  String get go => '开始！';

  @override
  String seconds(int count) {
    return '$count 秒';
  }

  @override
  String get running => '跑步中';

  @override
  String get distance => '距离';

  @override
  String get time => '时间';

  @override
  String get speed => '速度';

  @override
  String get pace => '配速';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get stop => '停止';

  @override
  String get finish => '完成';

  @override
  String get profileUpdated => '个人资料已更新';

  @override
  String get loggedOut => '已退出登录';

  @override
  String get pleaseLoginFirst => '请先登录后再开始跑步';

  @override
  String get permissionSettings => '权限设置';

  @override
  String get initializingApp => '正在初始化应用...';

  @override
  String get termsOfService => '用户协议';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get aboutApp => '关于应用';

  @override
  String get version => '版本';

  @override
  String get developer => '开发者';

  @override
  String get runningTrackerTeam => '跑步追踪器团队';

  @override
  String get legalInfo => '法律信息';

  @override
  String get termsTitle => '用户协议';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String lastUpdated(String date) {
    return '最后更新：$date';
  }

  @override
  String get termsContent1 => '欢迎使用跑步追踪器！这些条款和条件概述了使用跑步追踪器移动应用程序的规则和规定。';

  @override
  String get termsContent2 => '通过访问此应用程序，我们假设您接受这些条款和条件。如果您不同意接受本页面上所述的所有条款和条件，请不要继续使用跑步追踪器。';

  @override
  String get termsContent3 => '1. 用户账户';

  @override
  String get termsContent4 => '当您在我们这里创建账户时，您必须提供准确、完整和最新的信息。您有责任保护密码并对您账户下发生的所有活动负责。';

  @override
  String get termsContent5 => '2. 使用许可';

  @override
  String get termsContent6 => '仅允许您临时使用跑步追踪器进行个人、非商业性的短暂浏览。如果您违反任何这些限制，此许可将自动终止。';

  @override
  String get termsContent7 => '3. 隐私';

  @override
  String get termsContent8 => '您的隐私对我们很重要。请查看我们的隐私政策，它也管理您对服务的使用，以了解我们的做法。';

  @override
  String get termsContent9 => '4. 禁止使用';

  @override
  String get termsContent10 => '您不得将我们的服务用于任何非法目的或诱使他人进行非法行为，违反任何国际、联邦、省或州法规、规则、法律或地方法令。';

  @override
  String get termsContent11 => '5. 服务可用性';

  @override
  String get termsContent12 => '我们保留在不事先通知的情况下，自行决定撤回或修改我们的服务以及我们通过应用程序提供的任何服务或材料的权利。';

  @override
  String get termsContent13 => '6. 联系信息';

  @override
  String get termsContent14 => '如果您对这些条款和条件有任何疑问，请通过 support@runningtracker.app 联系我们';

  @override
  String get privacyContent1 => '本隐私政策描述了跑步追踪器在您使用我们的移动应用程序时如何收集、使用和保护您的信息。';

  @override
  String get privacyContent2 => '1. 我们收集的信息';

  @override
  String get privacyContent3 => '• 账户信息：当您创建账户时，我们收集您的用户名、电子邮件地址和可选的个人资料信息。';

  @override
  String get privacyContent4 => '• 位置数据：在您的许可下，我们收集GPS位置数据以追踪您的跑步路线并提供地图服务。';

  @override
  String get privacyContent5 => '• 跑步数据：我们存储您的跑步统计信息，包括距离、时间、速度和路线信息。';

  @override
  String get privacyContent6 => '• 设备信息：我们可能收集有关您设备的信息，包括设备型号、操作系统和应用程序版本。';

  @override
  String get privacyContent7 => '2. 我们如何使用您的信息';

  @override
  String get privacyContent8 => '• 提供和维护我们的跑步追踪服务';

  @override
  String get privacyContent9 => '• 显示您的跑步统计和进度';

  @override
  String get privacyContent10 => '• 改进我们的应用功能和用户体验';

  @override
  String get privacyContent11 => '• 向您发送有关应用的重要更新（在您同意的情况下）';

  @override
  String get privacyContent12 => '3. 信息共享';

  @override
  String get privacyContent13 => '除本政策中描述的情况外，我们不会在未经您同意的情况下向第三方出售、交易或以其他方式转移您的个人信息。';

  @override
  String get privacyContent14 => '4. 数据安全';

  @override
  String get privacyContent15 => '我们实施适当的安全措施来保护您的个人信息免受未经授权的访问、更改、披露或破坏。';

  @override
  String get privacyContent16 => '5. 您的权利';

  @override
  String get privacyContent17 => '您有权访问、更新或删除您的个人信息。您可以通过应用设置或联系我们来完成此操作。';

  @override
  String get privacyContent18 => '6. 位置数据';

  @override
  String get privacyContent19 => '位置数据仅在您主动使用跑步追踪功能并获得您的明确许可时才会被收集。您可以随时通过设备设置禁用位置访问。';

  @override
  String get privacyContent20 => '7. 数据保留';

  @override
  String get privacyContent21 => '只要您的账户处于活动状态或需要提供服务，我们就会保留您的数据。您可以随时请求删除您的账户和数据。';

  @override
  String get privacyContent22 => '8. 联系我们';

  @override
  String get privacyContent23 => '如果您对本隐私政策有疑问，请通过 privacy@runningtracker.app 联系我们';

  @override
  String get appDescription => '专业的跑步追踪应用，记录您的每一步运动轨迹';

  @override
  String get contactUs => '联系我们';

  @override
  String get technicalSupport => '技术支持';

  @override
  String get privacyConsultation => '隐私咨询';

  @override
  String get allRightsReserved => '保留所有权利 • All Rights Reserved';

  @override
  String get legalCompliance => '本应用遵循相关法律法规，保护用户隐私权益';

  @override
  String get aboutSubtitle => '应用信息、版本、法律信息、联系方式';

  @override
  String languageSwitchFailed(String error) {
    return '语言切换失败: $error';
  }

  @override
  String get gpsSettings => 'GPS设置';

  @override
  String get realGps => '真实GPS';

  @override
  String get realGpsDescription => '使用设备真实GPS进行位置追踪';

  @override
  String get readyToRun => '🏃‍♂️ 准备开始跑步！';

  @override
  String get startYourJourney => '🎉 开始你的跑步之旅！';

  @override
  String get almostReady => '⚡ 马上就要开始了...';

  @override
  String get gpsReady => 'GPS就绪，当前位置已锁定！';

  @override
  String get gettingGpsLocation => '正在获取GPS位置...';

  @override
  String get gpsServiceNotEnabled => 'GPS服务未开启，使用默认位置';

  @override
  String runningMode(Object fps, Object mode) {
    return '跑步中... (${fps}FPS $mode模式)';
  }

  @override
  String gpsReadyMode(Object fps, Object mode) {
    return 'GPS就绪！ 🎮 ${fps}FPS $mode模式';
  }

  @override
  String get currentLocation => '🏃‍♂️ 当前位置';

  @override
  String get runningStarted => '跑步开始！';

  @override
  String get runningCompleted => '跑步完成！';

  @override
  String pausedMode(Object fps, Object mode) {
    return '已暂停 (${fps}FPS $mode模式)';
  }

  @override
  String get runningEnded => '跑步结束 - 太棒了！ 🎉';

  @override
  String get runningComplete => '🎉 跑步完成！';

  @override
  String get totalDistance => '总距离';

  @override
  String get averageSpeed => '平均速度';

  @override
  String get caloriesBurned => '消耗卡路里';

  @override
  String get realDataNote => '📱 使用真实GPS追踪您的跑步路线';

  @override
  String get startRealRun => '开始跑步';

  @override
  String get continueText => '继续';

  @override
  String get calories => '卡路里';

  @override
  String get threeDMode => '3D';

  @override
  String get twoDMode => '2D';

  @override
  String get kilometers => '公里';

  @override
  String get kilometersPerHour => '公里/小时';

  @override
  String get kcal => '千卡';

  @override
  String get close => '关闭';

  @override
  String get mode => '模式';

  @override
  String get highFrameRate3DMode => '高帧率3D模式';

  @override
  String switchToFpsMode(String fps) {
    return '🎮 切换到 ${fps}FPS 模式';
  }

  @override
  String switchToViewMode(String mode) {
    return '🌐 切换到 $mode 视角';
  }

  @override
  String get saveRouteImage => '保存路径图片';

  @override
  String get savingRouteImage => '正在生成并保存路径图片...';

  @override
  String get saveSuccess => '✅ 保存成功';

  @override
  String get saveFailed => '❌ 保存失败';

  @override
  String routeImageSaved(String path) {
    return '跑步路径图片已保存到:\n$path';
  }

  @override
  String get saveImageFailed => '无法保存路径图片，请检查存储权限。';

  @override
  String get permissionManagement => '权限管理';

  @override
  String get permissionsRequired => '需要权限';

  @override
  String get somePermissionsMissing => '部分权限未授权，可能影响应用功能';

  @override
  String get locationPermissionMissing => '位置权限未授权';

  @override
  String get storagePermissionMissing => '存储权限未授权';

  @override
  String get notificationPermissionMissing => '通知权限未授权';

  @override
  String get grantAllPermissions => '授予所有权限';

  @override
  String get checkPermissions => '检查权限';

  @override
  String get permissionLocation => '位置权限';

  @override
  String get permissionStorage => '存储权限';

  @override
  String get permissionNotification => '通知权限';

  @override
  String get permissionRequired => '必需';

  @override
  String get permissionOptional => '可选';

  @override
  String get permissionGranted => '已授权';

  @override
  String get permissionDenied => '已拒绝';

  @override
  String get openSettings => '打开设置';

  @override
  String get permissionLocationDesc => '用于追踪跑步路线和实时定位';

  @override
  String get permissionStorageDesc => '用于保存跑步数据和路径图片';

  @override
  String get permissionNotificationDesc => '用于接收跑步提醒和应用通知';

  @override
  String get allPermissionsGranted => '所有权限已授权';

  @override
  String get permissionsUpdated => '权限状态已更新';

  @override
  String get skipForNow => '暂时跳过';
}
