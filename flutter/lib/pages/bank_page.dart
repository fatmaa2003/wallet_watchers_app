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
          SnackBar(
            content: Text('Error loading cards: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
                      SnackBar(
                        content: const Text('Card added successfully'),
                        backgroundColor: Colors.green[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding card: $e'),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    
    // Add null safety checks with default values
    final cardNumber = card['cardNumber']?.toString() ?? '****-****-****-****';
    final cardHolder = card['cardHolder']?.toString().toUpperCase() ?? 'CARD HOLDER';
    final cardName = card['cardName']?.toString() ?? '';
    
    // Format expiry date to MM/YY
    String formattedExpiryDate = 'MM/YY';
    if (card['expiryDate'] != null) {
      try {
        final date = DateTime.parse(card['expiryDate'].toString());
        final month = date.month.toString().padLeft(2, '0');
        final year = (date.year % 100).toString().padLeft(2, '0');
        formattedExpiryDate = '$month/$year';
      } catch (e) {
        formattedExpiryDate = 'MM/YY';
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16, 
        vertical: isTablet ? 12 : 8
      ),
      height: isTablet ? 240 : 200,
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
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
            right: isTablet ? -25 : -20,
            top: isTablet ? -25 : -20,
            child: Container(
              width: isTablet ? 180 : 150,
              height: isTablet ? 180 : 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: isTablet ? -35 : -30,
            bottom: isTablet ? -35 : -30,
            child: Container(
              width: isTablet ? 140 : 120,
              height: isTablet ? 140 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Card Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    Container(
                      width: isTablet ? 48 : 40,
                      height: isTablet ? 36 : 30,
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.credit_card,
                          color: Colors.amber[800],
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Card Number
                Text(
                  '•••• •••• •••• ${cardNumber.split('-').last}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 16 : 14,
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
                        Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isTablet ? 12 : 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: isTablet ? 6 : 4),
                        Text(
                          formattedExpiryDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 16 : 14,
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
            top: isTablet ? 12 : 8,
            right: isTablet ? 12 : 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Card'),
                      content: const Text('Are you sure you want to delete this card?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await _apiService.deleteCard(widget.user.id, cardName);
                      _loadCards();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Card deleted successfully'),
                            backgroundColor: Colors.green[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting card: $e'),
                            backgroundColor: Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      }
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white70,
                    size: isTablet ? 22 : 18,
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    
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
                        size: isTablet ? 80 : 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      Text(
                        'No cards added yet',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 100.0 : 80.0),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 20 : 16,
                      horizontal: isTablet ? 8 : 0,
                    ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) => _buildCardWidget(_cards[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(Icons.add),
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