import 'package:flutter/material.dart';
import '../../core/services/permission_service.dart';
import '../theme/app_colors.dart';

/// 🔐 权限申请弹窗
class PermissionDialog extends StatefulWidget {
  const PermissionDialog({super.key});

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  bool _isRequesting = false;
  Map<String, bool> _permissionStatus = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await PermissionService.checkAllPermissions();
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final results = await PermissionService.requestAllPermissions();
      setState(() {
        _permissionStatus = results;
        _isRequesting = false;
      });

      // 如果位置权限被授权，关闭弹窗
      if (results['location'] == true) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      setState(() {
        _isRequesting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('权限申请失败，请稍后重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.security,
            color: AppColors.primary,
            size: 28,
          )
          SizedBox(width: 12),
          Text(
            '应用权限申请',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '为了提供完整的跑步追踪功能，我们需要获取以下权限：',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 位置权限
          _buildPermissionItem(
            icon: Icons.location_on,
            title: '位置权限',
            description: '记录跑步路线和距离',
            isRequired: true,
            isGranted: _permissionStatus['location'] ?? false,
          ),

          const SizedBox(height: 16),

          // 存储权限
          _buildPermissionItem(
            icon: Icons.storage,
            title: '存储权限',
            description: '保存跑步数据和照片',
            isRequired: false,
            isGranted: _permissionStatus['storage'] ?? false,
          ),

          const SizedBox(height: 16),

          // 通知权限
          _buildPermissionItem(
            icon: Icons.notifications,
            title: '通知权限',
            description: '发送跑步提醒和统计',
            isRequired: false,
            isGranted: _permissionStatus['notification'] ?? false,
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '我们承诺不会收集或分享您的个人数据',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isRequesting
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text(
            '暂不授权',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isRequesting ? null : _requestPermissions,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isRequesting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('授权权限'),
        ),
      ],
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isRequired,
    required bool isGranted,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isGranted ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isGranted ? AppColors.success : AppColors.warning,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '必需',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // 权限状态图标
        Icon(
          isGranted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isGranted ? AppColors.success : AppColors.textSecondary,
          size: 20,
        ),
      ],
    );
  }
}
