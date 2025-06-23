import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user.dart';
import '../../l10n/app_localizations.dart';

/// 👤 个人资料编辑页面
class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _avatarBase64;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _bioController.text = widget.user.bio ?? '';

    // 如果用户已有头像，尝试解析base64
    if (widget.user.avatar != null && widget.user.avatar!.isNotEmpty) {
      try {
        _avatarBytes = base64Decode(widget.user.avatar!);
        _avatarBase64 = widget.user.avatar;
      } catch (e) {
        print('头像解析失败: $e');
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 选择头像
  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        // 图片大小检查 (限制为2MB)
        if (bytes.length > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.imageTooLarge),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final base64String = base64Encode(bytes);

        setState(() {
          _avatarBytes = bytes;
          _avatarBase64 = base64String;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.avatarSelected),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectAvatarFailed(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 从相机拍照
  Future<void> _takePhoto() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        // 图片大小检查 (限制为2MB)
        if (bytes.length > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.imageTooLarge),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final base64String = base64Encode(bytes);

        setState(() {
          _avatarBytes = bytes;
          _avatarBase64 = base64String;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.avatarSet),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cameraFailed(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 显示头像选择选项
  void _showAvatarOptions() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectAvatar,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: Icons.photo_library,
                  label: l10n.gallery,
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar();
                  },
                ),
                _buildOptionButton(
                  icon: Icons.camera_alt,
                  label: l10n.camera,
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                if (_avatarBytes != null)
                  _buildOptionButton(
                    icon: Icons.delete,
                    label: l10n.remove,
                    onTap: () {
                      Navigator.pop(context);
                      _removeAvatar();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建选项按钮
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 删除头像
  void _removeAvatar() {
    setState(() {
      _avatarBytes = null;
      _avatarBase64 = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('头像已移除，记得保存更改'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  /// 构建头像选择器
  Widget _buildAvatarPicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showAvatarOptions,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
              ),
              child: _avatarBytes != null
                  ? ClipOval(
                      child: Image.memory(
                        _avatarBytes!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAvatarOptions,
            icon: const Icon(Icons.photo_library),
            label: const Text('选择头像'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 保存个人资料
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.updateProfile(
        username: _usernameController.text.trim(),
        avatar: _avatarBase64,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );

        // 返回更新后的用户信息
        Navigator.of(context).pop(result['user']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.editProfile),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 头像选择区域
                  Center(
                    child: GestureDetector(
                      onTap: _showAvatarOptions,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // 头像显示
                            if (_avatarBytes != null)
                              ClipOval(
                                child: Image.memory(
                                  _avatarBytes!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            // 编辑图标
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 用户名输入
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      hintText: l10n.username,
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入用户名'; // 这里暂时保持中文，因为没有在arb文件中定义
                      }
                      if (value.trim().length < 2) {
                        return '用户名至少需要2个字符'; // 这里暂时保持中文，因为没有在arb文件中定义
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 个人简介输入
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      labelText: l10n.bio,
                      hintText: '介绍一下自己吧...', // 这里暂时保持中文，因为没有在arb文件中定义
                      prefixIcon: const Icon(Icons.edit_note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 底部按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
