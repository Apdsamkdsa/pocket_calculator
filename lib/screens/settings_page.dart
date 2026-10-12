import 'package:flutter/material.dart';
import 'package:pocket_calculator/screens/legal_page.dart';
import 'package:pocket_calculator/screens/onboarding_page.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:pocket_calculator/widgets/feature_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const FeatureBanner(
            asset: 'assets/images/illust_settings.jpg',
            title: 'Private by design',
            subtitle:
                'Calculations stay on your device. No account required.',
          ),
          const SizedBox(height: 16),
          _tile(
            context,
            Icons.description_outlined,
            'Terms of Use',
            () => LegalPage.open(
              context,
              title: 'Terms of Use',
              asset: 'assets/legal/terms.html',
            ),
          ),
          _tile(
            context,
            Icons.policy_outlined,
            'Privacy Policy',
            () => LegalPage.open(
              context,
              title: 'Privacy Policy',
              asset: 'assets/legal/privacy.html',
            ),
          ),
          _tile(
            context,
            Icons.replay,
            'Replay onboarding',
            () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('onboarding_done', false);
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingPage()),
                (_) => false,
              );
            },
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/illust_splash.jpg',
              height: 96,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Pocket Calculator 1.0.0',
            style: TextStyle(color: Pocket.muted),
          ),
          const SizedBox(height: 6),
          const Text(
            'Estimates only. Not a credit offer.',
            style: TextStyle(color: Pocket.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Pocket.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Pocket.stroke),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: Pocket.sky),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.chevron_right, color: Pocket.muted),
        ),
      ),
    );
  }
}
