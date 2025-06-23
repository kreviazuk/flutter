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
  String get locationReady => '位置已就绪';

  @override
  String get locationFailed => '获取位置失败';

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
}
