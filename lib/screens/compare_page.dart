import 'package:flutter/material.dart';
import 'package:pocket_calculator/loan_math.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:pocket_calculator/widgets/feature_banner.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  double aAmount = 25000;
  double aRate = 9.5;
  double aMonths = 60;
  double bAmount = 25000;
  double bRate = 6.9;
  double bMonths = 60;

  @override
  Widget build(BuildContext context) {
    final a = calculateAnnuity(amount: aAmount, yearlyRatePct: aRate, months: aMonths.round());
    final b = calculateAnnuity(amount: bAmount, yearlyRatePct: bRate, months: bMonths.round());
    final cheaper = a.overpay <= b.overpay ? 'A' : 'B';
    final gap = (a.overpay - b.overpay).abs();
    final payGap = (a.monthly - b.monthly).abs();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Compare',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Lower interest: offer $cheaper · saves ${money(gap)} interest · '
            '${money(payGap)} / mo difference',
            style: const TextStyle(color: Pocket.sky, fontWeight: FontWeight.w700, height: 1.35),
          ),
          const SizedBox(height: 14),
          const FeatureBanner(
            asset: 'assets/images/illust_compare.jpg',
            title: 'Stack two offers',
            subtitle: 'Pick the lower interest cost before you talk to a lender.',
          ),
          const SizedBox(height: 16),
          _offer(
            'Offer A',
            Pocket.royal,
            a,
            aAmount,
            aRate,
            aMonths,
            (amt, rate, m) => setState(() {
              aAmount = amt;
              aRate = rate;
              aMonths = m;
            }),
          ),
          const SizedBox(height: 14),
          _offer(
            'Offer B',
            Pocket.sky,
            b,
            bAmount,
            bRate,
            bMonths,
            (amt, rate, m) => setState(() {
              bAmount = amt;
              bRate = rate;
              bMonths = m;
            }),
          ),
        ],
      ),
    );
  }

  Widget _offer(
    String title,
    Color accent,
    LoanResult r,
    double amount,
    double rate,
    double months,
    void Function(double, double, double) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pocket.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Monthly ${money(r.monthly)}'),
          Text('Interest ${money(r.overpay)}'),
          Slider(
            value: amount,
            min: 1000,
            max: 250000,
            activeColor: accent,
            onChanged: (v) => onChange(v, rate, months),
          ),
          Text('Amount ${money(amount)}', style: const TextStyle(color: Pocket.muted, fontSize: 12)),
          Slider(
            value: rate,
            min: 1,
            max: 40,
            activeColor: accent,
            onChanged: (v) => onChange(amount, v, months),
          ),
          Text('APR ${rate.toStringAsFixed(1)}%', style: const TextStyle(color: Pocket.muted, fontSize: 12)),
          Slider(
            value: months,
            min: 3,
            max: 84,
            activeColor: accent,
            onChanged: (v) => onChange(amount, rate, v),
          ),
          Text('Term ${months.round()} mo', style: const TextStyle(color: Pocket.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
