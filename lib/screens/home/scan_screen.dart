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
    for (final barcode in capture.barcodes) {
<<<<<<< HEAD
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _lookupProduct(code);
        break;
      }
=======
      print('RAW VALUE: ${barcode.rawValue}');
      print('DISPLAY VALUE: ${barcode.displayValue}');
      print('FORMAT: ${barcode.format}');

  String? code = barcode.displayValue ?? barcode.rawValue;

  if (code == null || code.isEmpty) {
    continue;
  }

  if (code.startsWith(']C1')) {
  code = code.substring(3);
}

debugPrint('RAW VALUE: ${barcode.rawValue}');
debugPrint('DISPLAY VALUE: ${barcode.displayValue}');
debugPrint('SEARCHING BARCODE: $code');

  _lookupProduct(code);

  break;
>>>>>>> 2f6300bb5f434a9f10612a177cde67cf1a214f1f
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
        onAddToCart: () {
          CartService().addToCart(product);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to cart!'),
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

<<<<<<< HEAD
  void _resetScanner() => _controller.start();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }
=======
  void _resetScanner() {
  if (!mounted) return;

  _lastScannedCode = null;
  _lastScanTime = null;

  try {
    _controller.start();
  } catch (_) {}
}
>>>>>>> 2f6300bb5f434a9f10612a177cde67cf1a214f1f

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
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
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

class _ProductResultSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onDismiss;

  const _ProductResultSheet({
    required this.product,
    required this.onAddToCart,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      builder: (_, controller) => Container(
        color: Colors.white,
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              product.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'RM ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAddToCart,
              child: const Text('Add to Cart'),
            ),
            OutlinedButton(onPressed: onDismiss, child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
