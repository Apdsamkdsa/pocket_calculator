import 'package:flutter/material.dart';
import 'package:pocket_calculator/screens/legal_page.dart';
import 'package:pocket_calculator/screens/shell.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  int index = 0;

  static const steps = [
    (
      image: 'assets/images/illust_hero.jpg',
      title: 'See the payment instantly',
      text: 'Amount, rate, term, charts, and a loan health score — the full cost on one screen.',
    ),
    (
      image: 'assets/images/illust_charts.jpg',
      title: 'Pay extra, finish sooner',
      text: 'Add extra principal or switch to biweekly and see months saved and payoff date.',
    ),
    (
      image: 'assets/images/illust_compare.jpg',
      title: 'Compare, afford, decide',
      text: 'Stack offers, check DTI, rent vs buy, and refinance break-even — all on device.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = index == steps.length - 1;
    return Scaffold(
      backgroundColor: Pocket.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip', style: TextStyle(color: Pocket.muted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: steps.length,
                onPageChanged: (i) => setState(() => index = i),
                itemBuilder: (context, i) {
                  final s = steps[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              s.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: Pocket.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Pocket.muted,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length, (i) {
                final on = i == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: on ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: on ? Pocket.sky : Pocket.stroke,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: FilledButton(
                onPressed: () {
                  if (last) {
                    _finish();
                  } else {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(last ? 'Get started' : 'Continue'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => LegalPage.open(
                      context,
                      title: 'Terms of Use',
                      asset: 'assets/legal/terms.html',
                    ),
                    child: const Text(
                      'Terms of Use',
                      style: TextStyle(color: Pocket.muted, fontSize: 13),
                    ),
                  ),
                  const Text('·', style: TextStyle(color: Pocket.muted)),
                  TextButton(
                    onPressed: () => LegalPage.open(
                      context,
                      title: 'Privacy Policy',
                      asset: 'assets/legal/privacy.html',
                    ),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: Pocket.muted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
