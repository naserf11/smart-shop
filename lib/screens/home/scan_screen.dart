import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/scan_overlay_painter.dart';

int currentIndex = 2; // Keep your existing nav index

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;

  bool _isTorchOn = false;
  bool _isLoading = false;
  bool _hasPermission = false;

  // Debounce: prevent re-processing same code within 3 seconds
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  static const _debounceDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _requestPermission();
  }

  Future<void> _requestPermission() async {

  setState(() {

    _hasPermission = true;

  });

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
debugPrint(response.toString());
    final product = Product(
  id: response['product_id'].toString(),
  name: response['product_name'] ?? 'Unknown Product',
  description: response['description'] ?? '',
  categoryId: response['category_id']?.toString() ?? '',
  image: 'assets/images/basket.png',

  price: (response['selling_price'] as num).toDouble(),

  oldPrice: (response['original_price'] as num?)?.toDouble() ??
      (response['selling_price'] as num).toDouble(),

  stock: (response['stock_quantity'] as num?)?.toInt() ?? 0,

  rating: 0.0,

  isDiscounted: false,
);

    _showProductSheet(product);

  } catch (e) {

    debugPrint('Lookup error: $e');

  } finally {

    if (mounted) {

      setState(() => _isLoading = false);

    }

  }

}
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause camera when app is backgrounded — saves battery
    if (state == AppLifecycleState.paused) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed && _hasPermission) {
      _controller.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }
void _onDetect(BarcodeCapture capture) {
  print('BARCODES FOUND: ${capture.barcodes.length}');

  if (_isLoading) return;

  for (final barcode in capture.barcodes) {
    print('RAW VALUE: ${barcode.rawValue}');
    print('DISPLAY VALUE: ${barcode.displayValue}');
    print('FORMAT: ${barcode.format}');

    final code = barcode.rawValue;

    if (code == null || code.isEmpty) {
      continue;
    }

    print('SCANNED CODE: $code');

    _lookupProduct(code);

    break;
  }
}
  void _onProductNotFound(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No product found for: $code'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: _resetScanner,
        ),
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
            SnackBar(
              content: Text('${product.name} added to cart!'),
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
    _lastScannedCode = null;
    _lastScanTime = null;
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera feed ──────────────────────────────────────────
          if (!_hasPermission)
            const _PermissionDeniedView()
          else
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

          // ── Scan bracket overlay ─────────────────────────────────
          if (_hasPermission)
            CustomPaint(
              painter: ScanOverlayPainter(),
              child: const SizedBox.expand(),
            ),

          // ── Top app bar ──────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.home,
                        );
                      }
                    },
                  ),

                  const Text(
                    'Scan Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Torch toggle
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

          // ── Loading overlay ──────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Looking up product...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission Denied View
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera access required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please allow camera access in Settings to scan products.',
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open Settings'),
              onPressed: openAppSettings,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Result Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

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
    final bool inStock = product.stock > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Product image
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: product.image.startsWith('assets/')
                      ? Image.asset(product.image, fit: BoxFit.contain)
                      : Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Product name
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Price + stock row
              Row(
                children: [
                  Text(
                    'RM ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (product.isDiscounted &&
                      product.oldPrice > product.price) ...[
                    const SizedBox(width: 8),
                    Text(
                      'RM ${product.oldPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: inStock
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: inStock ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      inStock
                          ? 'In Stock (${product.stock})'
                          : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: inStock
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              // Description
              if (product.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDismiss,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Add to Cart'),
                      onPressed: inStock ? onAddToCart : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}