import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../core/app_routes.dart';

class PaymentSimulationScreen extends StatefulWidget {
  final String paymentMethod;

  const PaymentSimulationScreen({
    super.key,
    required this.paymentMethod,
  });

  @override
  State<PaymentSimulationScreen> createState() =>
      _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState
    extends State<PaymentSimulationScreen>
    with SingleTickerProviderStateMixin {
  final _cart = CartService();
  bool _isProcessing = false;
  bool _isSuccess = false;
  bool _isFailed = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  // Card form controllers
  final _cardNumberCtrl =
      TextEditingController(text: '4242 4242 4242 4242');
  final _expiryCtrl =
      TextEditingController(text: '12/28');
  final _cvvCtrl =
      TextEditingController(text: '123');
  final _nameCtrl =
      TextEditingController(text: 'Test User');

  // FPX selected bank
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _isFailed = false;
    });

    // Simulate network delay
    await Future.delayed(
      const Duration(seconds: 2),
    );

    try {
      // Create the order in Supabase
      await OrderService().createSupabaseOrder(
        paymentMethod: widget.paymentMethod,
      );

      // Clear the cart
      _cart.clearCart();

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });

      _animController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isFailed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _goToOrders() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
    // After navigating to home, push orders
    Navigator.pushNamed(context, AppRoutes.orders);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessView();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: _isProcessing
              ? null
              : () => Navigator.pop(context),
        ),
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Summary Card
            _buildOrderSummary(),

            const SizedBox(height: 16),

            // Payment Form
            _buildPaymentForm(),

            const SizedBox(height: 24),

            // Process Button
            _buildProcessButton(),

            const SizedBox(height: 16),

            // Simulation notice
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is a simulated payment for testing purposes.',
                      style: TextStyle(
                        color:
                            Colors.amber.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isFailed) ...[
              const SizedBox(height: 16),
              Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Payment failed. Please try again.',
                        style: TextStyle(
                          color:
                              Colors.red.shade900,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.paymentMethod) {
      case 'Credit / Debit Card':
        return 'Card Payment';
      case 'Online Payment via FPX':
        return 'FPX Payment';
      case "Touch 'n Go":
        return "Touch 'n Go";
      default:
        return 'Payment';
    }
  }

  Widget _buildOrderSummary() {
    final items = _cart.items;
    final total = _cart.totalAmount;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} x${item.quantity}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'RM ${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'RM ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (widget.paymentMethod) {
      case 'Credit / Debit Card':
        return _buildCardForm();
      case 'Online Payment via FPX':
        return _buildFPXForm();
      case "Touch 'n Go":
        return _buildTNGForm();
      default:
        return _buildCardForm();
    }
  }

  Widget _buildCardForm() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // Card visual
          Container(
            width: double.infinity,
            height: 180,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A1A2E)
                      .withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'VISA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Icon(
                      Icons.contactless,
                      color: Colors.white
                          .withOpacity(0.7),
                      size: 28,
                    ),
                  ],
                ),
                Text(
                  _cardNumberCtrl.text,
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.9),
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Text(
                      _nameCtrl.text
                          .toUpperCase(),
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      _expiryCtrl.text,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildTextField(
            controller: _cardNumberCtrl,
            label: 'Card Number',
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _expiryCtrl,
                  label: 'MM/YY',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _cvvCtrl,
                  label: 'CVV',
                  icon: Icons.lock,
                  obscure: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameCtrl,
            label: 'Cardholder Name',
            icon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildFPXForm() {
    final banks = [
      {'name': 'Maybank', 'code': 'MBB'},
      {'name': 'CIMB Bank', 'code': 'CIMB'},
      {'name': 'Public Bank', 'code': 'PBB'},
      {'name': 'RHB Bank', 'code': 'RHB'},
      {'name': 'Hong Leong Bank', 'code': 'HLB'},
      {'name': 'AmBank', 'code': 'AMB'},
      {'name': 'Bank Islam', 'code': 'BIMB'},
      {'name': 'Bank Rakyat', 'code': 'BKRK'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Your Bank',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: banks.length,
            itemBuilder: (context, index) {
              final bank = banks[index];
              final isSelected =
                  _selectedBank ==
                      bank['code'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedBank =
                        bank['code'];
                  });
                },
                borderRadius:
                    BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                            .withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius:
                        BorderRadius.circular(
                            10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade200,
                      width:
                          isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      bank['name']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.black87,
                      ),
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTNGForm() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // TNG eWallet Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF005ABE)
                  .withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 50,
              color: Color(0xFF005ABE),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Touch 'n Go eWallet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Complete Payment" to simulate\npayment via Touch \'n Go eWallet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Simulated QR
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.qr_code_2,
                size: 140,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan to Pay (Simulated)',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildProcessButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            elevation: 3,
          ),
          onPressed:
              _isProcessing ? null : _processPayment,
          child: _isProcessing
              ? const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 14),
                    Text(
                      'Processing Payment...',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Complete Payment  •  RM ${_cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your order has been placed\nsuccessfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment via ${widget.paymentMethod}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),
                    onPressed: _goToOrders,
                    child: const Text(
                      'View My Orders',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator
                        .pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
