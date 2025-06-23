import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.lastUpdated('2024年1月'),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(l10n.privacyContent1),
            const SizedBox(height: 24),
            _buildSection(l10n.privacyContent2, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent3),
            _buildSection(l10n.privacyContent4),
            _buildSection(l10n.privacyContent5),
            _buildSection(l10n.privacyContent6),
            const SizedBox(height: 16),
            _buildSection(l10n.privacyContent7, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent8),
            _buildSection(l10n.privacyContent9),
            _buildSection(l10n.privacyContent10),
            _buildSection(l10n.privacyContent11),
            const SizedBox(height: 16),
            _buildSection(l10n.privacyContent12, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent13),
            const SizedBox(height: 16),
            _buildSection(l10n.privacyContent14, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent15),
            const SizedBox(height: 16),
            _buildSection(l10n.privacyContent16, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent17),
            const SizedBox(height: 16),
            _buildSection(l10n.privacyContent18, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent19),
            const SizedBox(height: 16),
            _buildSection(l10n.privacyContent20, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent21),
            const SizedBox(height: 16),
            _buildSection(l10n.privacyContent22, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.privacyContent23),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String text, {bool isTitle = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTitle ? 0 : 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTitle ? 18 : 16,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          height: 1.6,
          color: isTitle ? Colors.blue : Colors.black87,
        ),
      ),
    );
  }
}
