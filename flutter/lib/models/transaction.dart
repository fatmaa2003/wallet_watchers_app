import 'package:flutter/material.dart';

enum TransactionType { expense, income }

enum TransactionCategory {
  Gas,
  Transportation,
  shopping,
  bills,
  entertainment,
  other
}

class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
  });

  Color get color => type == TransactionType.income ? Colors.green : Colors.red;
  IconData get icon {
    switch (category) {
      case TransactionCategory.Gas:
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
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
    };
  }
}
