import 'package:flutter/material.dart';
import 'package:pocket_calculator/loan_math.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:pocket_calculator/widgets/loan_charts.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key, required this.result});

  final LoanResult result;

  @override
  Widget build(BuildContext context) {
    final label = result.periodLabel;
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: result.schedule.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Pocket.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Pocket.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.schedule.length} $label${result.schedule.length == 1 ? '' : 's'} · interest ${money(result.overpay)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  BalanceCurveChart(schedule: result.schedule),
                ],
              ),
            );
          }
          final row = result.schedule[i - 1];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Pocket.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Pocket.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label ${row.month}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Payment ${money(row.payment)}  ·  Interest ${money(row.interest)}  ·  Principal ${money(row.principal)}',
                  style: const TextStyle(color: Pocket.muted, height: 1.4),
                ),
                Text(
                  'Balance ${money(row.balance)}',
                  style: const TextStyle(
                    color: Pocket.sky,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
