enum PayFrequency { monthly, biweekly }

class LoanResult {
  const LoanResult({
    required this.monthly,
    required this.total,
    required this.overpay,
    required this.schedule,
    required this.monthsTaken,
    this.periodLabel = 'Month',
    this.periodsPerYear = 12,
  });

  /// Base period payment (monthly installment, or biweekly installment).
  final double monthly;
  final double total;
  final double overpay;
  final List<LoanRow> schedule;
  /// Calendar months until payoff (approx for biweekly).
  final int monthsTaken;
  final String periodLabel;
  final int periodsPerYear;
}

class LoanRow {
  const LoanRow({
    required this.month,
    required this.payment,
    required this.interest,
    required this.principal,
    required this.balance,
  });

  final int month;
  final double payment;
  final double interest;
  final double principal;
  final double balance;
}

enum LoanHealth { excellent, good, fair, poor }

class LoanHealthResult {
  const LoanHealthResult({
    required this.score,
    required this.level,
    required this.label,
    required this.hint,
  });

  final int score;
  final LoanHealth level;
  final String label;
  final String hint;
}

class RentVsBuyResult {
  const RentVsBuyResult({
    required this.rentTotal,
    required this.buyTotal,
    required this.buyWins,
    required this.gap,
  });

  final double rentTotal;
  final double buyTotal;
  final bool buyWins;
  final double gap;
}

class RefinanceResult {
  const RefinanceResult({
    required this.currentPayment,
    required this.newPayment,
    required this.monthlySave,
    required this.breakEvenMonths,
    required this.interestSave,
  });

  final double currentPayment;
  final double newPayment;
  final double monthlySave;
  final int? breakEvenMonths;
  final double interestSave;
}

LoanResult calculateAnnuity({
  required double amount,
  required double yearlyRatePct,
  required int months,
  double extra = 0,
  PayFrequency frequency = PayFrequency.monthly,
}) {
  if (amount <= 0 || months <= 0) {
    return const LoanResult(
      monthly: 0,
      total: 0,
      overpay: 0,
      schedule: [],
      monthsTaken: 0,
    );
  }

  if (frequency == PayFrequency.biweekly) {
    return _biweekly(
      amount: amount,
      yearlyRatePct: yearlyRatePct,
      months: months,
      extraMonthly: extra,
    );
  }

  final r = yearlyRatePct / 100 / 12;
  final base = r == 0
      ? amount / months
      : amount * r * _pow(1 + r, months) / (_pow(1 + r, months) - 1);
  final payment = base + extra;

  var balance = amount;
  final rows = <LoanRow>[];
  for (var i = 1; i <= months && balance > 0.01; i++) {
    final interest = r == 0 ? 0.0 : balance * r;
    var principal = payment - interest;
    if (principal > balance) principal = balance;
    if (principal < 0) principal = 0;
    final pay = principal + interest;
    balance = (balance - principal).clamp(0, double.infinity);
    rows.add(
      LoanRow(
        month: i,
        payment: pay,
        interest: interest,
        principal: principal,
        balance: balance,
      ),
    );
  }
  final total = rows.fold<double>(0, (s, e) => s + e.payment);
  return LoanResult(
    monthly: base,
    total: total,
    overpay: total - amount,
    schedule: rows,
    monthsTaken: rows.length,
  );
}

LoanResult _biweekly({
  required double amount,
  required double yearlyRatePct,
  required int months,
  required double extraMonthly,
}) {
  // Classic biweekly: half the monthly annuity every 2 weeks (26×/year),
  // which equals ~13 monthly payments/year and pays the loan off earlier.
  final monthly = calculateAnnuity(
    amount: amount,
    yearlyRatePct: yearlyRatePct,
    months: months,
  );
  final periodsPerYear = 26;
  final r = yearlyRatePct / 100 / periodsPerYear;
  final base = monthly.monthly / 2;
  final extra = extraMonthly * 12 / periodsPerYear;
  final payment = base + extra;
  final maxPeriods = (months * periodsPerYear / 12).round() + periodsPerYear * 2;

  var balance = amount;
  final rows = <LoanRow>[];
  for (var i = 1; i <= maxPeriods && balance > 0.01; i++) {
    final interest = r == 0 ? 0.0 : balance * r;
    var principal = payment - interest;
    if (principal > balance) principal = balance;
    if (principal < 0) principal = 0;
    final pay = principal + interest;
    balance = (balance - principal).clamp(0, double.infinity);
    rows.add(
      LoanRow(
        month: i,
        payment: pay,
        interest: interest,
        principal: principal,
        balance: balance,
      ),
    );
  }
  final total = rows.fold<double>(0, (s, e) => s + e.payment);
  final monthsTaken = (rows.length * 12 / periodsPerYear).ceil();
  return LoanResult(
    monthly: base,
    total: total,
    overpay: total - amount,
    schedule: rows,
    monthsTaken: monthsTaken,
    periodLabel: 'Period',
    periodsPerYear: periodsPerYear,
  );
}

double maxAffordableLoan({
  required double monthlyBudget,
  required double yearlyRatePct,
  required int months,
}) {
  if (monthlyBudget <= 0 || months <= 0) return 0;
  final r = yearlyRatePct / 100 / 12;
  if (r == 0) return monthlyBudget * months;
  return monthlyBudget * (_pow(1 + r, months) - 1) / (r * _pow(1 + r, months));
}

/// Principal after down payment (and optional trade-in for auto loans).
double financedAmount({
  required double price,
  double downPayment = 0,
  double tradeIn = 0,
}) {
  return (price - downPayment - tradeIn).clamp(0, double.infinity);
}

LoanHealthResult loanHealthScore({
  required double amount,
  required double yearlyRatePct,
  required int months,
  required double overpay,
}) {
  if (amount <= 0) {
    return const LoanHealthResult(
      score: 0,
      level: LoanHealth.poor,
      label: 'N/A',
      hint: 'Enter a loan amount to score the terms.',
    );
  }
  final interestRatio = overpay / amount;
  var score = 100.0;
  // Rate pressure
  if (yearlyRatePct > 4) score -= (yearlyRatePct - 4) * 4.5;
  // Interest burden vs principal
  score -= interestRatio * 55;
  // Very long terms drag the score
  if (months > 84) score -= (months - 84) / 12 * 2.5;
  score = score.clamp(0, 100);

  final s = score.round();
  if (s >= 80) {
    return LoanHealthResult(
      score: s,
      level: LoanHealth.excellent,
      label: 'Excellent',
      hint: 'Strong terms — interest share of the loan looks healthy.',
    );
  }
  if (s >= 62) {
    return LoanHealthResult(
      score: s,
      level: LoanHealth.good,
      label: 'Good',
      hint: 'Solid offer. Extra principal or a shorter term can still help.',
    );
  }
  if (s >= 42) {
    return LoanHealthResult(
      score: s,
      level: LoanHealth.fair,
      label: 'Fair',
      hint: 'Worth shopping rates or shortening the term if you can.',
    );
  }
  return LoanHealthResult(
    score: s,
    level: LoanHealth.poor,
    label: 'Stretched',
    hint: 'High interest load — compare other offers before you commit.',
  );
}

RentVsBuyResult rentVsBuy({
  required double monthlyRent,
  required double homePrice,
  required double downPct,
  required double yearlyRatePct,
  required int termMonths,
  required double monthlyExtras,
  required int years,
}) {
  final down = homePrice * (downPct / 100);
  final loan = financedAmount(price: homePrice, downPayment: down);
  final mortgage = calculateAnnuity(
    amount: loan,
    yearlyRatePct: yearlyRatePct,
    months: termMonths,
  );
  final months = (years * 12).clamp(1, termMonths);
  final rentTotal = monthlyRent * months;
  // Buy cost ≈ down + mortgage payments over period + extras − remaining equity proxy (principal paid)
  var principalPaid = 0.0;
  for (var i = 0; i < months && i < mortgage.schedule.length; i++) {
    principalPaid += mortgage.schedule[i].principal;
  }
  var paySum = 0.0;
  for (var i = 0; i < months && i < mortgage.schedule.length; i++) {
    paySum += mortgage.schedule[i].payment;
  }
  final buyCash = down + paySum + monthlyExtras * months - principalPaid;
  final gap = (rentTotal - buyCash).abs();
  return RentVsBuyResult(
    rentTotal: rentTotal,
    buyTotal: buyCash,
    buyWins: buyCash < rentTotal,
    gap: gap,
  );
}

RefinanceResult refinanceBreakEven({
  required double balance,
  required double currentRate,
  required int remainingMonths,
  required double newRate,
  required int newMonths,
  required double closingCosts,
}) {
  final current = calculateAnnuity(
    amount: balance,
    yearlyRatePct: currentRate,
    months: remainingMonths,
  );
  final neu = calculateAnnuity(
    amount: balance,
    yearlyRatePct: newRate,
    months: newMonths,
  );
  final monthlySave = current.monthly - neu.monthly;
  int? breakEven;
  if (monthlySave > 0.5 && closingCosts > 0) {
    breakEven = (closingCosts / monthlySave).ceil();
  } else if (monthlySave > 0.5 && closingCosts <= 0) {
    breakEven = 0;
  }
  return RefinanceResult(
    currentPayment: current.monthly,
    newPayment: neu.monthly,
    monthlySave: monthlySave,
    breakEvenMonths: breakEven,
    interestSave: current.overpay - neu.overpay,
  );
}

double _pow(double x, int n) {
  var r = 1.0;
  for (var i = 0; i < n; i++) {
    r *= x;
  }
  return r;
}

String money(double v) {
  final n = v.round();
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
  }
  return '${n < 0 ? '-' : ''}\$$buf';
}

String payoffLabel(DateTime start, int monthsTaken) {
  final end = DateTime(start.year, start.month + monthsTaken, start.day);
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${names[end.month - 1]} ${end.year}';
}
