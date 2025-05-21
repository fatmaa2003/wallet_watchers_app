import 'package:flutter/material.dart';

enum TransactionType { expense, income }

enum TransactionCategory {
  Food,
  Transportation,
  shopping,
  bills,
  entertainment,
  other
}

class Transaction {
  final String id;
  final double amount;
  final String expenseName;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;

  Transaction({
    required this.id,
    required this.amount,
    required this.expenseName,
    required this.date,
    required this.type,
    required this.category,
  });

  Color get color => type == TransactionType.income ? Colors.green : Colors.red;
  IconData get icon {
    switch (category) {
      case TransactionCategory.Food:
        return Icons.restaurant;
      case TransactionCategory.Transportation:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_cart;
      case TransactionCategory.bills:
        return Icons.receipt;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.other:
        return Icons.category;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'expenseName': expenseName,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
    };
  }

  static Transaction fromJson(Map<String, dynamic> json, TransactionType type) {
    return Transaction(
      id: json['id'] ?? json['_id'] ?? '',
      amount: (json['amount'] ?? json['expenseAmount'] ?? json['incomeAmount'] ?? 0).toDouble(),
      expenseName: json['expenseName'] ?? json['incomeName'] ?? 'Unnamed',
      date: DateTime.parse(json['date'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      type: type,
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() ==
            (json['category'] ?? json['categoryName'] ?? 'other').toString().toLowerCase(),
        orElse: () => TransactionCategory.other,
      ),
    );
  }
}
