import 'dart:developer';
import 'package:dio/dio.dart';
import '../../models/deal.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dealhunter-scraper-production-88ed.up.railway.app',
  );

  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (o) => log(o.toString()),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('[API REQUEST] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('[API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('[API ERROR] ${e.type} | ${e.message} | ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  // ───────────────────────────────────────────────
  // GET DEALS
  // ───────────────────────────────────────────────
  Future<List<Deal>> getDeals({String? source, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/deals',
        queryParameters: {
          if (source != null && source != 'all') 'source': source,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final dealsList = data['deals'] as List<dynamic>? ?? [];
        return dealsList
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return _getMockDeals();
    } on DioException catch (e) {
      log('[ApiService] DioException in getDeals: ${e.type} - ${e.message}');
      return _getMockDeals();
    } catch (e) {
      log('[ApiService] Unexpected error in getDeals: $e');
      return _getMockDeals();
    }
  }

  // ───────────────────────────────────────────────
  // SEARCH DEALS
  // ───────────────────────────────────────────────
  Future<List<Deal>> searchDeals(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await _dio.get(
        '/api/search',
        queryParameters: {'q': query.trim()},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final dealsList = data['deals'] as List<dynamic>? ?? [];
        return dealsList
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      log('[ApiService] DioException in searchDeals: ${e.type} - ${e.message}');
      return [];
    } catch (e) {
      log('[ApiService] Unexpected error in searchDeals: $e');
      return [];
    }
  }

  // ───────────────────────────────────────────────
  // GET SOURCE COUNTS
  // ───────────────────────────────────────────────
  Future<Map<String, int>> getSourceCounts() async {
    try {
      final response = await _dio.get('/api/deals', queryParameters: {'limit': 1});

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final sources = data['sources'] as Map<String, dynamic>? ?? {};
        return sources.map((key, value) => MapEntry(key, (value as num).toInt()));
      }
      return _getMockSourceCounts();
    } on DioException catch (e) {
      log('[ApiService] DioException in getSourceCounts: ${e.type} - ${e.message}');
      return _getMockSourceCounts();
    } catch (e) {
      log('[ApiService] Unexpected error in getSourceCounts: $e');
      return _getMockSourceCounts();
    }
  }

  // ───────────────────────────────────────────────
  // GET SINGLE DEAL
  // ───────────────────────────────────────────────
  Future<Deal?> getDealById(String id) async {
    try {
      final response = await _dio.get('/api/deals/$id');

      if (response.statusCode == 200 && response.data != null) {
        final dealData = response.data['deal'] ?? response.data;
        if (dealData != null) {
          return Deal.fromJson(dealData as Map<String, dynamic>);
        }
      }
      return null;
    } on DioException catch (e) {
      log('[ApiService] DioException in getDealById: ${e.type} - ${e.message}');
      return null;
    } catch (e) {
      log('[ApiService] Unexpected error in getDealById: $e');
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // MOCK SOURCE COUNTS (offline fallback)
  // ───────────────────────────────────────────────
  Map<String, int> _getMockSourceCounts() {
    return {
      'amazon_eg': 52,
      'noon_eg': 38,
      'jumia_eg': 24,
    };
  }

  // ───────────────────────────────────────────────
  // MOCK DEALS (offline fallback — 6 realistic deals)
  // ───────────────────────────────────────────────
  List<Deal> _getMockDeals() {
    return [
      // ── Amazon Egypt ──
      Deal(
        id: 'amz_001',
        title: 'Samsung Galaxy S23 Ultra 5G - 256GB - Phantom Black',
        site: 'amazon_eg',
        siteDisplay: 'Amazon Egypt',
        category: 'electronics',
        currentPrice: 28499.00,
        originalPrice: 42999.00,
        discount: 34,
        discountDisplay: '34% OFF',
        imageUrl: 'https://m.media-amazon.com/images/I/61VfL-aiToL._AC_SL1000_.jpg',
        productUrl: 'https://www.amazon.eg/dp/B0BSH4FRTX',
        rating: 4.6,
        reviewCount: 2341,
        asin: 'B0BSH4FRTX',
        currency: 'EGP',
        verificationStatus: 'GENUINE',
        verificationConfidence: 0.92,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Deal(
        id: 'amz_002',
        title: 'Apple AirPods Pro (2nd Generation) with MagSafe Case USB-C',
        site: 'amazon_eg',
        siteDisplay: 'Amazon Egypt',
        category: 'electronics',
        currentPrice: 8999.00,
        originalPrice: 14999.00,
        discount: 40,
        discountDisplay: '40% OFF',
        imageUrl: 'https://m.media-amazon.com/images/I/61SUj2aKoEL._AC_SL1500_.jpg',
        productUrl: 'https://www.amazon.eg/dp/B0CHWRXH8B',
        rating: 4.7,
        reviewCount: 1856,
        asin: 'B0CHWRXH8B',
        currency: 'EGP',
        verificationStatus: 'GENUINE',
        verificationConfidence: 0.95,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      // ── Noon Egypt ──
      Deal(
        id: 'noon_001',
        title: 'Sony WH-1000XM5 Wireless Noise Canceling Headphones - Black',
        site: 'noon_eg',
        siteDisplay: 'Noon Egypt',
        category: 'electronics',
        currentPrice: 11999.00,
        originalPrice: 18999.00,
        discount: 37,
        discountDisplay: '37% OFF',
        imageUrl: 'https://f.nooncdn.com/p/pnsku/N53432547A/45/_/1702713008/53e38b87-75b5-4ea6-9718-76f9c0610fee.jpg',
        productUrl: 'https://www.noon.com/egypt-en/sony-wh-1000xm5/N53432547A/p',
        rating: 4.5,
        reviewCount: 967,
        currency: 'EGP',
        verificationStatus: 'GENUINE',
        verificationConfidence: 0.88,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Deal(
        id: 'noon_002',
        title: 'Nespresso Vertuo Plus Coffee Machine - Matte Black',
        site: 'noon_eg',
        siteDisplay: 'Noon Egypt',
        category: 'home',
        currentPrice: 5499.00,
        originalPrice: 8999.00,
        discount: 39,
        discountDisplay: '39% OFF',
        imageUrl: 'https://f.nooncdn.com/p/pzsku/ZA4B5A5F8A6C7E8D9F0A1B2C3D4E5F6A7B/45/_/1678901234/image.jpg',
        productUrl: 'https://www.noon.com/egypt-en/nespresso-vertuo-plus/ZA4B5A5F8A6C7E8D9F0A1B2C3D4E5F6A7B/p',
        rating: 4.4,
        reviewCount: 534,
        currency: 'EGP',
        verificationStatus: 'VERIFIED',
        verificationConfidence: 0.82,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      // ── Jumia Egypt ──
      Deal(
        id: 'jum_001',
        title: 'Xiaomi Redmi Note 13 Pro 8GB RAM 256GB - Midnight Black',
        site: 'jumia_eg',
        siteDisplay: 'Jumia Egypt',
        category: 'electronics',
        currentPrice: 9999.00,
        originalPrice: 12999.00,
        discount: 23,
        discountDisplay: '23% OFF',
        imageUrl: 'https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/12/345678/1.jpg',
        productUrl: 'https://www.jumia.com.eg/xiaomi-redmi-note-13-pro-12345678.html',
        rating: 4.3,
        reviewCount: 1245,
        currency: 'EGP',
        verificationStatus: 'GENUINE',
        verificationConfidence: 0.90,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Deal(
        id: 'jum_002',
        title: 'Samsung 55" Crystal UHD 4K Smart TV - TU7000',
        site: 'jumia_eg',
        siteDisplay: 'Jumia Egypt',
        category: 'electronics',
        currentPrice: 14499.00,
        originalPrice: 18999.00,
        discount: 24,
        discountDisplay: '24% OFF',
        imageUrl: 'https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/98/765432/1.jpg',
        productUrl: 'https://www.jumia.com.eg/samsung-55-crystal-uhd-98765432.html',
        rating: 4.5,
        reviewCount: 876,
        currency: 'EGP',
        verificationStatus: 'VERIFIED',
        verificationConfidence: 0.85,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
