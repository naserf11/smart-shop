import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/scan_overlay_painter.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  final int _currentIndex = 2;

  bool _isTorchOn = false;
  bool _isLoading = false;
  bool _hasPermission = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  static const Duration _scanDebounceDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    setState(() => _hasPermission = true);
  }

  void _onBottomNavTap(int index) {
    if (_currentIndex == index) return;
    _controller.stop();
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.cart,
          (route) => false,
        );
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.notifications,
          (route) => false,
        );
        break;
      case 4:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.more,
          (route) => false,
        );
        break;
    }
  }

  Future<void> _lookupProduct(String code) async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseService.client
          .from('products')
          .select()
          .eq('barcode', code)
          .maybeSingle();

      if (!mounted) return;
      if (response == null) {
        _onProductNotFound(code);
        return;
      }

      final product = Product(
        id: response['product_id'].toString(),
        name: response['product_name'] ?? 'Unknown Product',
        description: response['description'] ?? '',
        categoryId: response['category_id']?.toString() ?? '',
        image: 'assets/images/basket.png',
        price: (response['selling_price'] as num).toDouble(),
        oldPrice:
            (response['original_price'] as num?)?.toDouble() ??
            (response['selling_price'] as num).toDouble(),
        stock: (response['stock_quantity'] as num?)?.toInt() ?? 0,
        rating: 0.0,
        isDiscounted: false,
      );

      await _controller.stop();

      _showProductSheet(product);
    } catch (e) {
      debugPrint('Lookup error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isLoading) return;
    final now = DateTime.now();

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      final display = barcode.displayValue;
      debugPrint('RAW VALUE: $raw');
      debugPrint('DISPLAY VALUE: $display');
      debugPrint('FORMAT: ${barcode.format}');

      String? code = display ?? raw;
      if (code == null || code.isEmpty) continue;

      if (code.startsWith(']C1')) {
        code = code.substring(3);
      }

      // Debounce: ignore repeated scans of the same code within the debounce window
      if (_lastScannedCode != null &&
          _lastScannedCode == code &&
          _lastScanTime != null) {
        final diff = now.difference(_lastScanTime!);
        if (diff < _scanDebounceDuration) {
          debugPrint(
            'Ignored duplicate scan ($code) - ${diff.inMilliseconds}ms since last',
          );
          continue;
        }
      }

      // Record this scan
      _lastScannedCode = code;
      _lastScanTime = now;

      debugPrint('SEARCHING BARCODE: $code');
      _lookupProduct(code);
      break;
    }
  }

  void _onProductNotFound(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No product found for: $code'),
        backgroundColor: Colors.red,
      ),
    );
    _resetScanner();
  }

  void _showProductSheet(Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductResultSheet(
        product: product,
        onAddToCart: (int quantity) {
          for (int i = 0; i < quantity; i++) {
            CartService().addToCart(product);
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                quantity > 1
                    ? 'Added $quantity items to cart!'
                    : 'Added to cart!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _resetScanner();
        },
        onDismiss: () {
          Navigator.pop(context);
          _resetScanner();
        },
      ),
    );
  }

  void _resetScanner() {
    if (!mounted) return;

    _lastScannedCode = null;
    _lastScanTime = null;

    try {
      _controller.start();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (!_hasPermission)
            const _PermissionDeniedView()
          else
            MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_hasPermission)
            CustomPaint(
              painter: ScanOverlayPainter(),
              child: const SizedBox.expand(),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    'Scan Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isTorchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: _isTorchOn ? Colors.amber : Colors.white,
                    ),
                    onPressed: () {
                      _controller.toggleTorch();
                      setState(() => _isTorchOn = !_isTorchOn);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt, size: 64, color: Colors.white54),
          const SizedBox(height: 20),
          const Text(
            'Camera access required',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          ElevatedButton(
            onPressed: openAppSettings,
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _ProductResultSheet extends StatefulWidget {
  final Product product;
  final Function(int quantity) onAddToCart;
  final VoidCallback onDismiss;

  const _ProductResultSheet({
    required this.product,
    required this.onAddToCart,
    required this.onDismiss,
  });

  @override
  State<_ProductResultSheet> createState() => _ProductResultSheetState();
}

class _ProductResultSheetState extends State<_ProductResultSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onDismiss,
                  ),
                ],
              ),
            ),
            // Divider
            const Divider(height: 1),
            // Product Image
            Container(
              color: Colors.grey[100],
              height: 220,
              width: double.infinity,
              child: Image.asset(
                widget.product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.stock > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.product.stock > 0
                              ? '${widget.product.stock} in stock'
                              : 'Out of stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.product.stock > 0
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'RM ${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.product.oldPrice > widget.product.price)
                        Text(
                          'RM ${widget.product.oldPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (widget.product.isDiscounted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SALE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  if (widget.product.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Quantity Selector
                  const Text(
                    'Quantity',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          splashRadius: 20,
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Text(
                            _quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _quantity < widget.product.stock
                              ? () => setState(() => _quantity++)
                              : null,
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.product.stock > 0
                          ? () => widget.onAddToCart(_quantity)
                          : null,
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.onDismiss,
                      child: const Text(
                        'Continue Scanning',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
