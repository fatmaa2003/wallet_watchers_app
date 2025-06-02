import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/category.dart';

enum TransactionType { expense, income }

class Transaction {
  final String id;
  final double amount;
  final String expenseName;
  final DateTime date;
  final TransactionType type;
  final Category category;

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
    final categoryName = category.categoryName.toLowerCase();
    if (categoryName.contains('food')) return Icons.restaurant;
    if (categoryName.contains('transport')) return Icons.directions_car;
    if (categoryName.contains('shop')) return Icons.shopping_cart;
    if (categoryName.contains('bill')) return Icons.receipt;
    if (categoryName.contains('entertain')) return Icons.movie;
    return Icons.category;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'expenseName': expenseName,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'category': category.toJson(),
    };
  }

  static Transaction fromJson(Map<String, dynamic> json, TransactionType type) {
    return Transaction(
      id: json['id'] ?? json['_id'] ?? '',
      amount: (json['amount'] ?? json['expenseAmount'] ?? json['incomeAmount'] ?? 0).toDouble(),
      expenseName: json['expenseName'] ?? json['incomeName'] ?? 'Unnamed',
      date: DateTime.parse(json['date'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      type: type,
      category: json['category'] != null 
          ? Category.fromJson(json['category'])
          : Category(id: '', categoryName: json['categoryName'] ?? 'Other'),
    );
  }
}
