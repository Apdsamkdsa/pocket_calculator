import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_calculator/loan_math.dart';

void main() {
  test('annuity monthly is positive', () {
    final r = calculateAnnuity(amount: 100000, yearlyRatePct: 12, months: 12);
    expect(r.monthly > 0, true);
    expect(r.overpay > 0, true);
    expect(r.schedule.length, 12);
  });

  test('biweekly finishes sooner than monthly', () {
    final m = calculateAnnuity(amount: 25000, yearlyRatePct: 7.9, months: 60);
    final b = calculateAnnuity(
      amount: 25000,
      yearlyRatePct: 7.9,
      months: 60,
      frequency: PayFrequency.biweekly,
    );
    expect(b.monthsTaken < m.monthsTaken, true);
    expect(b.overpay < m.overpay, true);
  });

  test('loan health scores excellent for cheap short loan', () {
    final r = calculateAnnuity(amount: 10000, yearlyRatePct: 3.5, months: 24);
    final h = loanHealthScore(
      amount: 10000,
      yearlyRatePct: 3.5,
      months: 24,
      overpay: r.overpay,
    );
    expect(h.level, LoanHealth.excellent);
  });

  test('refinance break-even when rate drops', () {
    final refi = refinanceBreakEven(
      balance: 200000,
      currentRate: 7.5,
      remainingMonths: 300,
      newRate: 5.5,
      newMonths: 300,
      closingCosts: 4000,
    );
    expect(refi.monthlySave > 0, true);
    expect(refi.breakEvenMonths != null, true);
  });
}
