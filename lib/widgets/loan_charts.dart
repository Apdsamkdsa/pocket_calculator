import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pocket_calculator/loan_math.dart';
import 'package:pocket_calculator/theme.dart';

class PrincipalInterestPie extends StatelessWidget {
  const PrincipalInterestPie({
    super.key,
    required this.principal,
    required this.interest,
  });

  final double principal;
  final double interest;

  @override
  Widget build(BuildContext context) {
    final total = principal + interest;
    final interestShare = total <= 0 ? 0.0 : interest / total;
    return Row(
      children: [
        SizedBox(
          width: 92,
          height: 92,
          child: CustomPaint(
            painter: _PiePainter(
              interestShare: interestShare,
              principalColor: Pocket.sky,
              interestColor: Pocket.mid,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legend('Principal', money(principal), Pocket.sky),
              const SizedBox(height: 8),
              _legend('Interest', money(interest), Pocket.mid),
              const SizedBox(height: 8),
              Text(
                total <= 0
                    ? '—'
                    : '${(interestShare * 100).toStringAsFixed(0)}% of total is interest',
                style: const TextStyle(color: Pocket.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Pocket.muted, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class BalanceCurveChart extends StatelessWidget {
  const BalanceCurveChart({super.key, required this.schedule});

  final List<LoanRow> schedule;

  @override
  Widget build(BuildContext context) {
    if (schedule.isEmpty) {
      return const SizedBox(height: 120);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Balance over time',
          style: TextStyle(color: Pocket.muted, fontSize: 13),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: CustomPaint(
            painter: _BalancePainter(schedule: schedule),
          ),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({
    required this.interestShare,
    required this.principalColor,
    required this.interestColor,
  });

  final double interestShare;
  final Color principalColor;
  final Color interestColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: c, radius: radius);
    final interestSweep = (interestShare.clamp(0, 1)) * 2 * math.pi;
    final principalSweep = 2 * math.pi - interestSweep;

    final principalPaint = Paint()
      ..color = principalColor
      ..style = PaintingStyle.fill;
    final interestPaint = Paint()
      ..color = interestColor
      ..style = PaintingStyle.fill;
    final hole = Paint()
      ..color = Pocket.card
      ..style = PaintingStyle.fill;

    canvas.drawArc(rect, -math.pi / 2, principalSweep, true, principalPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2 + principalSweep,
      interestSweep,
      true,
      interestPaint,
    );
    canvas.drawCircle(c, radius * 0.58, hole);
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.interestShare != interestShare;
}

class _BalancePainter extends CustomPainter {
  _BalancePainter({required this.schedule});

  final List<LoanRow> schedule;

  @override
  void paint(Canvas canvas, Size size) {
    if (schedule.isEmpty) return;
    final maxBal = schedule
        .map((e) => e.balance)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final startBal = schedule.first.balance + schedule.first.principal;
    final top = startBal > maxBal ? startBal : maxBal;
    if (top <= 0) return;

    final path = Path();
    final fill = Path();
    final n = schedule.length;
    for (var i = 0; i < n; i++) {
      final x = n == 1 ? 0.0 : size.width * i / (n - 1);
      final y = size.height * (1 - schedule[i].balance / top);
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    final grid = Paint()
      ..color = Pocket.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Pocket.sky.withValues(alpha: 0.35),
            Pocket.sky.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Pocket.sky
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BalancePainter old) =>
      old.schedule != schedule;
}
