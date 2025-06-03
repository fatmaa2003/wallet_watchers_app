import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class BankPage extends StatefulWidget {
  final User user;
  const BankPage({super.key, required this.user});

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final cards = await _apiService.getCardsByUserId(widget.user.id);
      setState(() {
        _cards = cards;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cards: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddCardDialog() {
    final _formKey = GlobalKey<FormState>();
    String cardName = '';
    String cardNumber = '';
    String cardHolder = '';
    String expiryDate = '';
    String cvv = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Card'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Name',
                    hintText: 'My Credit Card',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a card name';
                    }
                    return null;
                  },
                  onSaved: (value) => cardName = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234-5678-9012-3456',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    // Remove any non-digit characters for validation
                    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (digitsOnly.length != 16) {
                      return 'Card number must be 16 digits';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Format the card number with dashes
                    final digitsOnly = value!.replaceAll(RegExp(r'[^\d]'), '');
                    cardNumber = '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 8)}-${digitsOnly.substring(8, 12)}-${digitsOnly.substring(12)}';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Holder',
                    hintText: 'JOHN DOE',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                  onSaved: (value) => cardHolder = value!,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'MM/YY',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          // Validate MM/YY format
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Use MM/YY format';
                          }
                          final parts = value.split('/');
                          final month = int.parse(parts[0]);
                          final year = int.parse(parts[1]);
                          if (month < 1 || month > 12) {
                            return 'Invalid month';
                          }
                          // Check if the date is in the past
                          final now = DateTime.now();
                          final currentYear = now.year % 100; // Get last 2 digits of current year
                          if (year < currentYear || (year == currentYear && month < now.month)) {
                            return 'Card is expired';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          final parts = value!.split('/');
                          final month = int.parse(parts[0]);
                          final year = int.parse(parts[1]);
                          final now = DateTime.now();
                          final currentYear = now.year ~/ 100; // Get first 2 digits of current year
                          final fullYear = currentYear * 100 + year; // Combine with input year
                          final date = DateTime(fullYear, month + 1, 0); // Last day of the month
                          expiryDate = date.toIso8601String();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (!RegExp(r'^\d{3}$').hasMatch(value)) {
                            return 'Must be 3 digits';
                          }
                          return null;
                        },
                        onSaved: (value) => cvv = value!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try {
                  await _apiService.postCard(widget.user.id, {
                    'cardName': cardName,
                    'cardNumber': cardNumber,
                    'cardHolder': cardHolder,
                    'expiryDate': expiryDate,
                    'cvv': cvv,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    _loadCards();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Card added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding card: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWidget(Map<String, dynamic> card) {
    // Add null safety checks with default values
    final cardNumber = card['cardNumber']?.toString() ?? '****-****-****-****';
    final cardHolder = card['cardHolder']?.toString().toUpperCase() ?? 'CARD HOLDER';
    final expiryDate = card['expiryDate']?.toString() ?? 'MM/YY';
    final cardName = card['cardName']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A), // Deep blue
            const Color(0xFF3B82F6), // Bright blue
            const Color(0xFF60A5FA), // Light blue
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Elements
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Card Name and Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (cardName.isNotEmpty)
                      Text(
                        cardName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.credit_card,
                          color: Colors.amber[800],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Card Number
                Text(
                  '•••• •••• •••• ${cardNumber.split('-').last}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
                const Spacer(),
                // Bottom Row: Card Holder and Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Card Holder
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardHolder,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Expiry Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expiryDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete Button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  try {
                    await _apiService.deleteCard(widget.user.id, cardName);
                    _loadCards();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Card deleted successfully')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting card: $e')),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("My Cards"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No cards added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) => _buildCardWidget(_cards[index]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardDialog,
        backgroundColor: Colors.lightBlueAccent,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 3, user: widget.user),
    );
  }
}

// Custom painter for card background pattern
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw horizontal lines
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw vertical lines
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 