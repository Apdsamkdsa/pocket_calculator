import 'package:flutter/material.dart';
import 'package:pocket_calculator/loan_math.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:pocket_calculator/widgets/feature_banner.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  double budget = 450;
  double rate = 7.9;
  double months = 60;
  double income = 4500;
  double debts = 600;

  // Rent vs buy
  double rent = 1800;
  double homePrice = 360000;
  double downPct = 20;
  double buyRate = 6.5;
  double buyTerm = 360;
  double extras = 450;
  double compareYears = 7;

  // Refinance
  double refiBalance = 280000;
  double currentRate = 7.2;
  double remaining = 300;
  double newRate = 5.9;
  double newTerm = 360;
  double closing = 4500;

  @override
  Widget build(BuildContext context) {
    final maxLoan = maxAffordableLoan(
      monthlyBudget: budget,
      yearlyRatePct: rate,
      months: months.round(),
    );
    final dti = income <= 0 ? 0.0 : (debts / income) * 100;
    final room = (income * 0.36 - debts).clamp(0, double.infinity).toDouble();
    final rvb = rentVsBuy(
      monthlyRent: rent,
      homePrice: homePrice,
      downPct: downPct,
      yearlyRatePct: buyRate,
      termMonths: buyTerm.round(),
      monthlyExtras: extras,
      years: compareYears.round(),
    );
    final refi = refinanceBreakEven(
      balance: refiBalance,
      currentRate: currentRate,
      remainingMonths: remaining.round(),
      newRate: newRate,
      newMonths: newTerm.round(),
      closingCosts: closing,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Tools',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Affordability, DTI, rent vs buy, and refinance break-even.',
            style: TextStyle(color: Pocket.muted),
          ),
          const SizedBox(height: 14),
          const FeatureBanner(
            asset: 'assets/images/illust_afford.jpg',
            title: 'Plan before you borrow',
            subtitle: 'Check budget fit, debt load, and refinance timing.',
          ),
          const SizedBox(height: 16),
          _card(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/illust_afford.jpg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'What can I afford?',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 8),
              Text(
                money(maxLoan),
                style: const TextStyle(
                  color: Pocket.sky,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Estimated max loan at this payment, rate, and term',
                style: TextStyle(color: Pocket.muted, fontSize: 13),
              ),
              _slider('Monthly budget', money(budget), budget, 50, 4000, (v) {
                setState(() => budget = v);
              }),
              _slider('APR', '${rate.toStringAsFixed(1)}%', rate, 1, 40, (v) {
                setState(() => rate = v);
              }),
              _slider('Term', '${months.round()} mo', months, 12, 360, (v) {
                setState(() => months = v);
              }),
            ],
          ),
          const SizedBox(height: 14),
          _card(
            children: [
              const Text(
                'Debt-to-income',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${dti.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: dti > 36 ? const Color(0xFFFF6B6B) : Pocket.sky,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                dti > 36
                    ? 'Often considered stretched. Lenders commonly look near 36%.'
                    : 'Within a common 36% guideline. Not a credit decision.',
                style: const TextStyle(
                  color: Pocket.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              _slider(
                'Gross monthly income',
                money(income),
                income,
                500,
                20000,
                (v) => setState(() => income = v),
              ),
              _slider(
                'Other monthly debts',
                money(debts),
                debts,
                0,
                8000,
                (v) => setState(() => debts = v),
              ),
              Text(
                'Room under 36%: ${money(room)} / month',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FeatureBanner(
            asset: 'assets/images/illust_rent_vs_buy.jpg',
            title: 'Rent vs buy',
            subtitle:
                'Compare cash spent renting vs buying over several years.',
          ),
          const SizedBox(height: 10),
          _card(
            children: [
              Text(
                rvb.buyWins ? 'Buying looks cheaper' : 'Renting looks cheaper',
                style: TextStyle(
                  color: rvb.buyWins ? Pocket.sky : const Color(0xFFFFC857),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gap ${money(rvb.gap)} over ${compareYears.round()} years '
                '(rent ${money(rvb.rentTotal)} vs buy cash ${money(rvb.buyTotal)}). '
                'Simplified estimate — not a full ownership model.',
                style: const TextStyle(
                  color: Pocket.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              _slider('Monthly rent', money(rent), rent, 400, 8000, (v) {
                setState(() => rent = v);
              }),
              _slider('Home price', money(homePrice), homePrice, 80000, 1200000,
                  (v) {
                setState(() => homePrice = v);
              }),
              _slider(
                'Down payment',
                '${downPct.toStringAsFixed(0)}%',
                downPct,
                0,
                40,
                (v) => setState(() => downPct = v),
              ),
              _slider(
                'Mortgage APR',
                '${buyRate.toStringAsFixed(1)}%',
                buyRate,
                1,
                15,
                (v) => setState(() => buyRate = v),
              ),
              _slider(
                'Tax / insurance / HOA',
                money(extras),
                extras,
                0,
                2500,
                (v) => setState(() => extras = v),
              ),
              _slider(
                'Compare years',
                '${compareYears.round()} yr',
                compareYears,
                3,
                15,
                (v) => setState(() => compareYears = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FeatureBanner(
            asset: 'assets/images/illust_refinance.jpg',
            title: 'Refinance break-even',
            subtitle:
                'See monthly savings and when closing costs pay for themselves.',
          ),
          const SizedBox(height: 10),
          _card(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _miniStat(
                      'Current',
                      money(refi.currentPayment),
                      Pocket.muted,
                    ),
                  ),
                  Expanded(
                    child: _miniStat(
                      'New',
                      money(refi.newPayment),
                      Pocket.sky,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                refi.monthlySave > 0
                    ? 'Save ${money(refi.monthlySave)} / mo · interest ${money(refi.interestSave)}'
                    : 'New payment is not lower — tweak rate or term.',
                style: TextStyle(
                  color: refi.monthlySave > 0 ? Pocket.sky : Pocket.muted,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              if (refi.breakEvenMonths != null) ...[
                const SizedBox(height: 6),
                Text(
                  refi.breakEvenMonths == 0
                      ? 'Break-even: immediate (no closing costs).'
                      : 'Break-even: ~${refi.breakEvenMonths} months after closing costs.',
                  style: const TextStyle(color: Pocket.muted, fontSize: 13),
                ),
              ],
              _slider(
                'Remaining balance',
                money(refiBalance),
                refiBalance,
                10000,
                900000,
                (v) => setState(() => refiBalance = v),
              ),
              _slider(
                'Current APR',
                '${currentRate.toStringAsFixed(1)}%',
                currentRate,
                1,
                15,
                (v) => setState(() => currentRate = v),
              ),
              _slider(
                'Months left',
                '${remaining.round()}',
                remaining,
                12,
                360,
                (v) => setState(() => remaining = v),
              ),
              _slider(
                'New APR',
                '${newRate.toStringAsFixed(1)}%',
                newRate,
                1,
                15,
                (v) => setState(() => newRate = v),
              ),
              _slider(
                'New term',
                '${newTerm.round()} mo',
                newTerm,
                60,
                360,
                (v) => setState(() => newTerm = v),
              ),
              _slider(
                'Closing costs',
                money(closing),
                closing,
                0,
                15000,
                (v) => setState(() => closing = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Pocket.muted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: Pocket.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Pocket.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _slider(
    String label,
    String value,
    double v,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: Pocket.muted)),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        Slider(value: v.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
