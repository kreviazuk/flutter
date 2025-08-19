import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../core/services/language_service.dart';

import '../../l10n/app_localizations.dart';
import 'about_screen.dart';

/// ⚙️ 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 语言设置
          _buildLanguageSection(context, l10n),

          const SizedBox(height: 20),

          // 关于应用
          _buildAboutSection(context, l10n),
        ],
      ),
    );
  }

  /// 构建语言设置部分
  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.languageTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 语言选项列表
          ...LanguageService.supportedLocales.map((locale) {
            final isSelected = _languageService.currentLocale.languageCode == locale.languageCode;
            String displayName;

            // 根据当前语言环境显示语言名称
            if (locale.languageCode == 'zh') {
              displayName = l10n.chinese;
            } else if (locale.languageCode == 'en') {
              displayName = l10n.english;
            } else {
              displayName = _languageService.getLanguageDisplayName(locale);
            }

            return ListTile(
              title: Text(displayName),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: isSelected ? null : () => _changeLanguage(locale, l10n),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建关于部分
  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.aboutApp,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(l10n.aboutApp),
            subtitle: Text(l10n.aboutSubtitle),
            leading: const Icon(Icons.info),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 更改语言
  Future<void> _changeLanguage(Locale locale, AppLocalizations l10n) async {
    try {
      await _languageService.changeLanguage(locale);

      if (mounted) {
        String languageName;
        if (locale.languageCode == 'zh') {
          languageName = l10n.chinese;
        } else if (locale.languageCode == 'en') {
          languageName = l10n.english;
        } else {
          languageName = _languageService.getLanguageDisplayName(locale);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.languageChanged(languageName)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.languageSwitchFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
