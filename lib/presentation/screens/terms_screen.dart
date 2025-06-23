import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsTitle),
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
            _buildSection(l10n.termsContent1),
            const SizedBox(height: 16),
            _buildSection(l10n.termsContent2),
            const SizedBox(height: 24),
            _buildSection(l10n.termsContent3, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.termsContent4),
            const SizedBox(height: 16),
            _buildSection(l10n.termsContent5, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.termsContent6),
            const SizedBox(height: 16),
            _buildSection(l10n.termsContent7, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.termsContent8),
            const SizedBox(height: 16),
            _buildSection(l10n.termsContent9, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.termsContent10),
            const SizedBox(height: 16),
            _buildSection(l10n.termsContent11, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.termsContent12),
            const SizedBox(height: 16),
            _buildSection(l10n.termsContent13, isTitle: true),
            const SizedBox(height: 8),
            _buildSection(l10n.termsContent14),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String text, {bool isTitle = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isTitle ? 18 : 16,
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        height: 1.6,
        color: isTitle ? Colors.blue : Colors.black87,
      ),
    );
  }
}
