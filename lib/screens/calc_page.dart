import 'package:flutter/material.dart';
import 'package:pocket_calculator/loan_math.dart';
import 'package:pocket_calculator/screens/schedule_page.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:pocket_calculator/widgets/feature_banner.dart';
import 'package:pocket_calculator/widgets/loan_charts.dart';
// HeroStrip lives in feature_banner.dart

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  double price = 25000;
  double down = 0;
  double tradeIn = 0;
  double rate = 7.9;
  double months = 60;
  double extra = 0;
  String preset = 'Auto';
  PayFrequency frequency = PayFrequency.monthly;

  double get amount => financedAmount(
        price: price,
        downPayment: down,
        tradeIn: tradeIn,
      );

  void _applyPreset(String name) {
    setState(() {
      preset = name;
      extra = 0;
      tradeIn = 0;
      frequency = PayFrequency.monthly;
      switch (name) {
        case 'Auto':
          price = 25000;
          down = 2500;
          rate = 7.9;
          months = 60;
        case 'Personal':
          price = 8000;
          down = 0;
          rate = 12.5;
          months = 36;
        case 'Home':
          price = 320000;
          down = 64000;
          rate = 6.5;
          months = 360;
      }
    });
  }

  Color _healthColor(LoanHealth level) {
    return switch (level) {
      LoanHealth.excellent => const Color(0xFF3DDC97),
      LoanHealth.good => Pocket.sky,
      LoanHealth.fair => const Color(0xFFFFC857),
      LoanHealth.poor => const Color(0xFFFF6B6B),
    };
  }

  @override
  Widget build(BuildContext context) {
    final principal = amount;
    final base = calculateAnnuity(
      amount: principal,
      yearlyRatePct: rate,
      months: months.round(),
      frequency: frequency,
    );
    final r = calculateAnnuity(
      amount: principal,
      yearlyRatePct: rate,
      months: months.round(),
      extra: extra,
      frequency: frequency,
    );
    final monthsSaved = base.monthsTaken - r.monthsTaken;
    final interestSaved = base.overpay - r.overpay;
    final start = DateTime.now();
    final health = loanHealthScore(
      amount: principal,
      yearlyRatePct: rate,
      months: months.round(),
      overpay: r.overpay,
    );
    final payLabel =
        frequency == PayFrequency.biweekly ? 'Biweekly' : 'Monthly';
    final showAutoExtras = preset == 'Auto';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroStrip(asset: 'assets/images/illust_hero.jpg'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/illust_splash.jpg',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pocket Calculator',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Loan payment & payoff',
                            style: TextStyle(color: Pocket.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: FeatureBanner(
              asset: 'assets/images/illust_charts.jpg',
              title: 'See the full picture',
              subtitle:
                  'Charts, health score, down payment & biweekly payoff — like pro loan apps.',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Wrap(
              spacing: 8,
              children: [
                for (final name in ['Auto', 'Personal', 'Home'])
                  ChoiceChip(
                    label: Text(name),
                    selected: preset == name,
                    selectedColor: Pocket.royal,
                    labelStyle: TextStyle(
                      color: preset == name ? Colors.white : Pocket.text,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Pocket.card,
                    side: const BorderSide(color: Pocket.stroke),
                    onSelected: (_) => _applyPreset(name),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Pocket.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Pocket.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _stat(
                          extra > 0 ? 'Base $payLabel' : payLabel,
                          money(r.monthly),
                          Pocket.sky,
                        ),
                      ),
                      Expanded(
                        child: _stat('Interest', money(r.overpay), Pocket.mid),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _stat('Total paid', money(r.total), Pocket.text),
                  if (down > 0 || tradeIn > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Financed ${money(principal)}'
                      '${down > 0 ? ' · down ${money(down)}' : ''}'
                      '${tradeIn > 0 ? ' · trade-in ${money(tradeIn)}' : ''}',
                      style: const TextStyle(color: Pocket.muted, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Payoff ${payoffLabel(start, r.monthsTaken)} · ${r.monthsTaken} mo · ${r.schedule.length} ${r.periodLabel.toLowerCase()}s',
                    style: const TextStyle(color: Pocket.muted, fontSize: 13),
                  ),
                  if (extra > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Extra ${money(extra)} / mo saves ${money(interestSaved)} and $monthsSaved months',
                      style: const TextStyle(
                        color: Pocket.sky,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Pocket.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _healthColor(health.level).withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/illust_health_score.jpg',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loan health · ${health.score}',
                          style: TextStyle(
                            color: _healthColor(health.level),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          health.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          health.hint,
                          style: const TextStyle(
                            color: Pocket.muted,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Pocket.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Pocket.stroke),
              ),
              child: Column(
                children: [
                  PrincipalInterestPie(
                    principal: principal,
                    interest: r.overpay,
                  ),
                  const SizedBox(height: 18),
                  BalanceCurveChart(schedule: r.schedule),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Pocket.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Pocket.stroke),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Payment frequency',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SegmentedButton<PayFrequency>(
                    segments: const [
                      ButtonSegment(
                        value: PayFrequency.monthly,
                        label: Text('Monthly'),
                      ),
                      ButtonSegment(
                        value: PayFrequency.biweekly,
                        label: Text('Biweekly'),
                      ),
                    ],
                    selected: {frequency},
                    onSelectionChanged: (s) =>
                        setState(() => frequency = s.first),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return Pocket.muted;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Pocket.royal;
                        }
                        return Pocket.surface;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _sliderCard(
              preset == 'Home' ? 'Home price' : 'Loan / price',
              money(price),
              price,
              1000,
              800000,
              (v) => setState(() => price = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _sliderCard(
              'Down payment',
              money(down),
              down,
              0,
              price * 0.6,
              (v) => setState(() => down = v),
            ),
          ),
        ),
        if (showAutoExtras)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _sliderCard(
                'Trade-in value',
                money(tradeIn),
                tradeIn,
                0,
                price * 0.5,
                (v) => setState(() => tradeIn = v),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _sliderCard(
              'APR',
              '${rate.toStringAsFixed(1)}%',
              rate,
              1,
              40,
              (v) => setState(() => rate = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _sliderCard(
              'Term',
              '${months.round()} mo',
              months,
              3,
              360,
              (v) => setState(() => months = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _sliderCard(
              'Extra principal / month',
              money(extra),
              extra,
              0,
              1500,
              (v) => setState(() => extra = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SchedulePage(result: r)),
              ),
              child: const Text('Open payment schedule'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Pocket.muted, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _sliderCard(
    String label,
    String value,
    double v,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final safeMax = max <= min ? min + 1 : max;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: Pocket.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Pocket.stroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(color: Pocket.muted)),
              const Spacer(),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          Slider(
            value: v.clamp(min, safeMax),
            min: min,
            max: safeMax,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
