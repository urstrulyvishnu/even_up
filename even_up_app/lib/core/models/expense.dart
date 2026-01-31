class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy;
  final DateTime createdAt;
  final String splitType;
  final List<String> splitWith;
  final String? groupId;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.createdAt,
    required this.splitType,
    this.splitWith = const [],
    this.groupId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'],
      createdAt: DateTime.parse(json['createdAt']),
      splitType: json['splitType'],
      splitWith: (json['splitWith'] as List?)?.map((m) => m.toString()).toList() ?? [],
      groupId: json['groupId'],
    );
  }
}
