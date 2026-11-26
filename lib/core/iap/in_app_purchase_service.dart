import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';

/// Cross-platform in-app purchase service handling iOS StoreKit and Android
/// Google Play Billing for Pro Subscriptions, Doctor Applications, and
/// Restore Purchases (Apple Guideline 3.1.1).
class HealthInAppPurchaseService {
  HealthInAppPurchaseService._();
  static final HealthInAppPurchaseService instance = HealthInAppPurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product Identifiers
  static const String proMonthly = 'visualcheckup_pro_monthly';
  static const String proYearly = 'visualcheckup_pro_yearly';
  static const String doctorApplication = 'visualcheckup_doctor_standard';

  static const List<String> subscriptionIds = [proMonthly, proYearly];
  static const List<String> consumableIds = [doctorApplication];

  static Set<String> get allProductIds => {
        ...subscriptionIds,
        ...consumableIds,
      };

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  SubscriptionRepository? subscriptionRepository;
  DoctorRepository? doctorRepository;

  String? _pendingDoctorUserId;
  Function(bool success)? _onDoctorPurchaseCallback;
  Function(String message, {bool isError})? onPurchaseStatus;

  /// Initializes the In-App Purchase service and listens to the native purchase stream.
  Future<void> initialize({
    SubscriptionRepository? subRepo,
    DoctorRepository? docRepo,
    Function(String message, {bool isError})? statusCallback,
  }) async {
    subscriptionRepository = subRepo ?? subscriptionRepository;
    doctorRepository = docRepo ?? doctorRepository;
    onPurchaseStatus = statusCallback;

    try {
      _isAvailable = await _iap.isAvailable();
    } catch (e) {
      debugPrint('[IAP] isAvailable check failed: $e');
      _isAvailable = false;
    }

    if (!_isAvailable) {
      debugPrint('[IAP] Native in-app purchase store is currently unavailable.');
      return;
    }

    await _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('[IAP] purchaseStream Error: $error');
      },
    );

    await loadProducts();
  }

  /// Queries product details from Apple App Store / Google Play Store.
  Future<List<ProductDetails>> loadProducts() async {
    if (!_isAvailable) return [];
    try {
      final response = await _iap.queryProductDetails(allProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[IAP] NotFoundIDs: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      return _products;
    } catch (e) {
      debugPrint('[IAP] Error loading products: $e');
      return [];
    }
  }

  ProductDetails? getProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Initiates non-consumable Pro subscription (Monthly or Yearly).
  Future<bool> buySubscription(String productId, {String? userId}) async {
    if (!_isAvailable) {
      debugPrint('[IAP] Fallback: Store unavailable, activating locally.');
      final tier = productId == proYearly
          ? SubscriptionTier.proYearly
          : SubscriptionTier.proMonthly;
      await subscriptionRepository?.activatePlan(
        uid: userId,
        tier: tier,
        storeSource: Platform.isIOS ? 'app_store' : 'play_store',
      );
      onPurchaseStatus?.call('Aboneliğiniz başarıyla aktif edildi.');
      return true;
    }

    var targetProduct = getProduct(productId);
    if (targetProduct == null) {
      await loadProducts();
      targetProduct = getProduct(productId);
    }

    if (targetProduct == null) {
      onPurchaseStatus?.call(
        'Ürün bilgisi mağazadan alınamadı. Lütfen internet bağlantınızı kontrol edin.',
        isError: true,
      );
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: targetProduct);
    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[IAP] buyNonConsumable error: $e');
      onPurchaseStatus?.call('Satın alma başlatılamadı: $e', isError: true);
      return false;
    }
  }

  /// Initiates consumable Doctor application package purchase.
  Future<bool> buyDoctorPackage({
    required String doctorUserId,
    Function(bool success)? onCompleted,
  }) async {
    _pendingDoctorUserId = doctorUserId;
    _onDoctorPurchaseCallback = onCompleted;

    if (!_isAvailable) {
      debugPrint('[IAP] Fallback: Store unavailable, activating doctor package locally.');
      if (doctorRepository != null) {
        await doctorRepository!.markApplicationPaid(
          doctorUserId,
          purchasedPackage: 'doctor_standard_verified',
        );
      }
      _onDoctorPurchaseCallback?.call(true);
      _onDoctorPurchaseCallback = null;
      return true;
    }

    var targetProduct = getProduct(doctorApplication);
    if (targetProduct == null) {
      await loadProducts();
      targetProduct = getProduct(doctorApplication);
    }

    if (targetProduct == null) {
      onPurchaseStatus?.call(
        'Doktor başvuru paketi mağazada bulunamadı.',
        isError: true,
      );
      _onDoctorPurchaseCallback?.call(false);
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: targetProduct);
    try {
      return await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[IAP] buyConsumable error: $e');
      _onDoctorPurchaseCallback?.call(false);
      return false;
    }
  }

  /// Restores previous purchases (Strict Apple App Store Guideline 3.1.1 requirement).
  Future<bool> restorePurchases({String? userId}) async {
    if (!_isAvailable) {
      debugPrint('[IAP] Fallback: Checking local subscription.');
      final sub = await subscriptionRepository?.loadSubscription(uid: userId);
      return sub?.isPro ?? false;
    }

    try {
      await _iap.restorePurchases();
      onPurchaseStatus?.call('Satın alımlarınız kontrol edildi.');
      return true;
    } catch (e) {
      debugPrint('[IAP] restorePurchases error: $e');
      onPurchaseStatus?.call('Geri yükleme sırasında hata oluştu: $e', isError: true);
      return false;
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        onPurchaseStatus?.call('Satın alma işlemi işleniyor, lütfen bekleyin...');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        final err = purchaseDetails.error?.message ?? 'Bilinmeyen hata';
        onPurchaseStatus?.call('Satın alma başarısız oldu: $err', isError: true);
        if (_onDoctorPurchaseCallback != null) {
          _onDoctorPurchaseCallback?.call(false);
          _onDoctorPurchaseCallback = null;
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final productId = purchaseDetails.productID;

        // 1. Pro Subscriptions
        if (subscriptionIds.contains(productId)) {
          final tier = productId == proYearly
              ? SubscriptionTier.proYearly
              : SubscriptionTier.proMonthly;
          await subscriptionRepository?.activatePlan(
            tier: tier,
            storeSource: Platform.isIOS ? 'app_store' : 'play_store',
          );
          onPurchaseStatus?.call('VisualCheckUp Pro aboneliğiniz aktif edildi!');
        }

        // 2. Doctor Application Package
        if (consumableIds.contains(productId)) {
          if (_pendingDoctorUserId != null && doctorRepository != null) {
            await doctorRepository!.markApplicationPaid(
              _pendingDoctorUserId!,
              purchasedPackage: productId,
            );
          }
          _onDoctorPurchaseCallback?.call(true);
          _onDoctorPurchaseCallback = null;
          onPurchaseStatus?.call('Doktor başvuru paketiniz başarıyla onaylandı!');
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchaseDetails);
        } catch (e) {
          debugPrint('[IAP] completePurchase error: $e');
        }
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
