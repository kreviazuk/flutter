class User {
  final String id;
  final String email;
  final String username;
  final String? avatar;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // 详细的null检查和类型验证
      print('🔍 User.fromJson - 输入数据: $json');

      final id = json['id'];
      if (id == null) {
        throw ArgumentError('User id不能为null');
      }
      if (id is! String) {
        throw ArgumentError('User id必须是String类型，当前是: ${id.runtimeType}');
      }

      final email = json['email'];
      if (email == null) {
        throw ArgumentError('User email不能为null');
      }
      if (email is! String) {
        throw ArgumentError('User email必须是String类型，当前是: ${email.runtimeType}');
      }

      final username = json['username'];
      if (username == null) {
        throw ArgumentError('User username不能为null');
      }
      if (username is! String) {
        throw ArgumentError('User username必须是String类型，当前是: ${username.runtimeType}');
      }

      final avatar = json['avatar']; // 可以为null
      if (avatar != null && avatar is! String) {
        throw ArgumentError('User avatar必须是String类型或null，当前是: ${avatar.runtimeType}');
      }

      final isEmailVerified = json['isEmailVerified'] ?? false;
      if (isEmailVerified is! bool) {
        throw ArgumentError('User isEmailVerified必须是bool类型，当前是: ${isEmailVerified.runtimeType}');
      }

      final createdAtStr = json['createdAt'];
      if (createdAtStr == null) {
        throw ArgumentError('User createdAt不能为null');
      }
      if (createdAtStr is! String) {
        throw ArgumentError('User createdAt必须是String类型，当前是: ${createdAtStr.runtimeType}');
      }

      final updatedAtStr = json['updatedAt'];
      if (updatedAtStr == null) {
        throw ArgumentError('User updatedAt不能为null');
      }
      if (updatedAtStr is! String) {
        throw ArgumentError('User updatedAt必须是String类型，当前是: ${updatedAtStr.runtimeType}');
      }

      DateTime createdAt;
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (e) {
        throw ArgumentError('User createdAt日期格式错误: $createdAtStr, 错误: $e');
      }

      DateTime updatedAt;
      try {
        updatedAt = DateTime.parse(updatedAtStr);
      } catch (e) {
        throw ArgumentError('User updatedAt日期格式错误: $updatedAtStr, 错误: $e');
      }

      print('✅ User.fromJson - 所有字段验证通过');

      return User(
        id: id,
        email: email,
        username: username,
        avatar: avatar,
        isEmailVerified: isEmailVerified,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e, stackTrace) {
      print('❌ User.fromJson 失败');
      print('错误: $e');
      print('输入数据: $json');
      print('堆栈追踪: $stackTrace');
      rethrow; // 重新抛出异常，保持堆栈信息
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar': avatar,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? avatar,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
