import 'dart:math';
import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://abdental.up.railway.app';
  // static const String baseUrl = 'http://127.0.0.1:8000';
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  ApiService() {
    _dio.options.baseUrl = baseUrl;   
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
    ));
  }

  // Generic methods
  Future<Response> get(String path, {Map<String, dynamic>? params}) => 
    _dio.get(path, queryParameters: params);
  
  Future<Response> post(String path, {dynamic data}) => 
    _dio.post(path, data: data);
  
  Future<Response> put(String path, {dynamic data}) => 
    _dio.put(path, data: data);
  
  Future<Response> patch(String path, {dynamic data}) => 
    _dio.patch(path, data: data);
  
  Future<Response> delete(String path) => 
    _dio.delete(path);

  // General endpoints
  Future<Response> getTypeOfUser(Map<String, dynamic> data) => 
    post('/auth/type_user', data: data);

  // ============================================
  // OTP Endpoints
  // ============================================
  
  /// Send OTP code to email
  /// Required: { "email": "user@example.com", "otp_type": "registration" | "password_reset" }
  Future<Response> sendOTP(Map<String, dynamic> data) => 
    post('/otp/send', data: data);
  
  /// Verify OTP code
  /// Required: { "email": "user@example.com", "otp_code": "123456", "otp_type": "registration" | "password_reset" }
  Future<Response> verifyOTP(Map<String, dynamic> data) => 
    post('/otp/verify', data: data);
  
  /// Reset password using OTP
  /// Required: { "email": "user@example.com", "otp_code": "123456", "new_password": "newpass123" }
  Future<Response> resetPassword(Map<String, dynamic> data) => 
    post('/otp/reset-password', data: data);

  // ============================================
  // Client endpoints
  // ============================================
  
  /// Register new client (requires OTP verification first)
  Future<Response> registerClient(Map<String, dynamic> data) => 
    post('/client/register', data: data);
  
  Future<Response> loginClient(Map<String, dynamic> data) => 
    post('/client/login', data: data);
  
  Future<Response> getClientProfile() => get('/client/me');
  
  Future<Response> updateClientProfile(Map<String, dynamic> data) => 
    put('/client/me', data: data);
  
  Future<Response> getAllClients({int skip = 0, int limit = 100}) => 
    get('/client/', params: {'skip': skip, 'limit': limit});
  
  Future<Response> getClientById(int id) => get('/client/$id');
  
  Future<Response> toggleClientActive(int id) => 
    patch('/client/$id/toggle-active');
  
  Future<Response> deleteClient(int id) => delete('/client/$id');

  // ============================================
  // Admin endpoints
  // ============================================
  
  Future<Response> loginAdmin(Map<String, dynamic> data) => 
    post('/admin/login', data: data);
  
  Future<Response> getAdminProfile() => get('/admin/me');
  
  Future<Response> updateAdminProfile(Map<String, dynamic> data) => 
    put('/admin/me', data: data);
  
  Future<Response> getAllAdmins({int skip = 0, int limit = 100}) => 
    get('/admin/', params: {'skip': skip, 'limit': limit});
  
  Future<Response> deleteAdmin(int id) => delete('/admin/$id');

  // ============================================
  // Product endpoints (UPDATED for multiple images)
  // ============================================
  
  /// Create product with 1-5 images
  /// Required: {
  ///   "name": "Product Name",
  ///   "price": 99.99,
  ///   "quantity_in_stock": 100,
  ///   "image_urls": ["url1", "url2", ...],  // 1-5 URLs
  ///   "category_id": 1
  /// }
  Future<Response> createProduct(Map<String, dynamic> data) => 
    post('/product/', data: data);
  
  /// Get all products with filters
  Future<Response> getAllProducts({
    int? categoryId, 
    bool? isActive, 
    int skip = 0, 
    int limit = 100
  }) => get('/product/', params: {
    'skip': skip,
    'limit': limit,
    if (categoryId != null) 'category_id': categoryId,
    if (isActive != null) 'is_active': isActive,
  });
  
  /// Get products with low stock (admin only)
  Future<Response> getLowStockProducts() => 
    get('/product/low-stock');
  
  /// Get single product by ID (returns ProductWithCategory)
  Future<Response> getProductById(int id) => 
    get('/product/$id');
  
  /// Update product (including images)
  /// Optional: {
  ///   "name": "New Name",
  ///   "price": 149.99,
  ///   "image_urls": ["url1", "url2"],  // 1-5 URLs
  ///   "category_id": 2
  /// }
  Future<Response> updateProduct(int id, Map<String, dynamic> data) => 
    put('/product/$id', data: data);
  
  /// Update only product stock quantity
  Future<Response> updateProductStock(int id, int quantity) => 
    patch('/product/$id/stock', data: {'quantity': quantity});
  
  /// Delete product (admin only)
  Future<Response> deleteProduct(int id) => 
    delete('/product/$id');
  
  /// Get total product count
  Future<Response> getProductSummary() => 
    get('/product/count');

  // ============================================
  // Category endpoints
  // ============================================
  
  Future<Response> createCategory(Map<String, dynamic> data) => 
    post('/category/', data: data);
  
  Future<Response> getAllCategories({int skip = 0, int limit = 100}) => 
    get('/category/', params: {'skip': skip, 'limit': limit});
  
  Future<Response> getCategoryById(int id) => 
    get('/category/$id');
  
  Future<Response> updateCategory(int id, Map<String, dynamic> data) => 
    put('/category/$id', data: data);
  
  Future<Response> deleteCategory(int id) => 
    delete('/category/$id');

  // ============================================
  // Bill endpoints
  // ============================================
  
  Future<Response> createBill(Map<String, dynamic> data) => 
    post('/bill/', data: data);
  
  Future<Response> getMyBills({int skip = 0, int limit = 100}) => 
    get('/bill/my-bills', params: {'skip': skip, 'limit': limit});
  
  Future<Response> getAllMyBills() => 
    get('/bill/my-bills/count');
  
  Future<Response> getAllUnpaidBills() => 
    get('/bill/unpaid-bills/count');
  
  Future<Response> getAllBills({String? status, int skip = 0, int limit = 100}) => 
    get('/bill/all', params: {
      'status_filter': status, 
      'skip': skip, 
      'limit': limit
    });
  
  Future<Response> getBillSummary() => 
    get('/bill/summary');
  
  Future<Response> getBillById(int id) => 
    get('/bill/$id');
  
  Future<Response> getAdminBillById(int id) => 
    get('/bill/admin/$id');
  
  Future<Response> payBill(int billId, double amount) => 
    _dio.post('/bill/$billId/pay', queryParameters: {'amount': amount});
  
  Future<Response> updateBillStatus(int id, String status) => 
    patch('/bill/$id/status', data: {'status': status});
  
  Future<Response> deleteBill(int id) => 
    delete('/bill/$id');
  
  // ============================================
  // Statistics endpoints
  // ============================================
  
  Future<Response> getDailyBillSummary({
    required int year, 
    required int month
  }) => get('/bill/statistics/daily', params: {
    'year': year, 
    'month': month
  });
  
  Future<Response> getMonthlyBillSummary({int? year}) => 
    get('/bill/statistics/monthly', params: year != null ? {'year': year} : {});
  
  Future<Response> getYearlyBillSummary() => 
    get('/bill/statistics/yearly');
  
  Future<Response> getPeriodRangeSummary({
    required String startDate,
    required String endDate,
    required String groupBy,
  }) => get('/bill/statistics/period-range', params: {
    'start_date': startDate,
    'end_date': endDate,
    'group_by': groupBy,
  });

  // ============================================
  // Payment endpoints
  // ============================================
  
  Future<Response> createPayment(Map<String, dynamic> data) => 
    post('/payment/', data: data);
  
  Future<Response> getBillPaymentHistory(int billId) => 
    get('/payment/bill/$billId');
  
  Future<Response> getAllPayments({int skip = 0, int limit = 100}) => 
    get('/payment/', params: {'skip': skip, 'limit': limit});
  
  Future<Response> getPaymentById(int id) => 
    get('/payment/$id');
  
  Future<Response> updatePayment(int id, Map<String, dynamic> data) => 
    put('/payment/$id', data: data);
  
  Future<Response> deletePayment(int id) => 
    delete('/payment/$id');

  // ============================================
  // Stock Alert endpoints
  // ============================================
  
  Future<Response> getAllStockAlerts({
    bool? isResolved, 
    int skip = 0, 
    int limit = 100
  }) => get('/stock-alert/', params: {
    'is_resolved': isResolved, 
    'skip': skip, 
    'limit': limit
  });
  
  Future<Response> getUnresolvedStockAlerts() => 
    get('/stock-alert/unresolved');
  
  Future<Response> getStockAlertSummary() => 
    get('/stock-alert/summary');
  
  Future<Response> getStockAlertById(int id) => 
    get('/stock-alert/$id');
  
  Future<Response> resolveStockAlert(int id) => 
    patch('/stock-alert/$id/resolve');
  
  Future<Response> unresolveStockAlert(int id) => 
    patch('/stock-alert/$id/unresolve');
  
  Future<Response> deleteStockAlert(int id) => 
    delete('/stock-alert/$id');

  // ============================================
  // Notification endpoints
  // ============================================
  

Future<Response> getAllNotifications({
  bool? isSent, 
  String? type, 
  int skip = 0, 
  int limit = 100
}) {
  final params = <String, dynamic>{
    'skip': skip, 
    'limit': limit,
  };
  
  // Only add parameters if they are not null
  if (isSent != null) {
    params['is_sent'] = isSent;
  }
  if (type != null && type.isNotEmpty) {
    params['notification_type'] = type;
  }
  
  return get('/notification/', params: params);
}
  
Future<Response> getAllNotificationsAdmin({
  bool? isSent, 
  String? type, 
  int skip = 0, 
  int limit = 100
}) {
  final params = <String, dynamic>{
    'skip': skip, 
    'limit': limit,
  };
  
  // Only add parameters if they are not null
  if (isSent != null) {
    params['is_sent'] = isSent;
  }
  if (type != null && type.isNotEmpty) {
    params['notification_type'] = type;
  }
  
  return get('/notification/admin', params: params);
}
  
  Future<Response> getPendingNotifications() => 
    get('/notification/pending');
  
  Future<Response> getNotificationSummary() => 
    get('/notification/summary');
  
  Future<Response> getNotificationById(int id) => 
    get('/notification/$id');
  
  Future<Response> markNotificationSent(int id) => 
    patch('/notification/$id/mark-sent');
  
  Future<Response> deleteNotification(int id) => 
    delete('/notification/$id');
  
  Future<Response> sendPendingNotifications() => 
    post('/notification/send-pending');
//////////
///
///
///
Future<Response> createNotification(Map<String, dynamic> data) => 
  post('/notification/', data: data);


////
///

// Future<Response> getAllNotifications({
//   bool? isSent, 
//   String? type, 
//   int skip = 0, 
//   int limit = 100
// }) {
//   final params = <String, dynamic>{
//     'skip': skip, 
//     'limit': limit,
//   };
  
//   // Only add parameters if they are not null
//   if (isSent != null) params['is_sent'] = isSent;
//   if (type != null) params['notification_type'] = type;
  
//   return get('/notification/', params: params);
// }





    // ============================================
  // Upload endpoints (Cloudinary)
  // ============================================
  
  /// Upload multiple product images to Cloudinary (1-5 images)
  /// Returns: { "success": true, "image_urls": [...], "public_ids": [...], "count": 2 }
  // Future<Response> uploadProductImages(List<String> imagePaths) async {
  //   FormData formData = FormData();
    
  //   for (String path in imagePaths) {
  //     formData.files.add(
  //       MapEntry(
  //         'files',
  //         await MultipartFile.fromFile(
  //           path,
  //           filename: path.split('/').last,
  //         ),
  //       ),
  //     );
  //   }
    
  //   return _dio.post('/upload/product-images', data: formData);
  // }
  // Replace the uploadProductImages method in your api_service.dart with this:

/// Upload multiple product images to Cloudinary (0-5 images)
/// Returns: { "success": true, "image_urls": [...], "public_ids": [...], "count": 2 }
Future<Response> uploadProductImages(List<String> imagePaths) async {
  // Handle empty list
  if (imagePaths.isEmpty) {
    return Response(
      requestOptions: RequestOptions(path: '/upload/product-images'),
      data: {
        "success": true,
        "image_urls": [],
        "public_ids": [],
        "count": 0
      },
      statusCode: 200,
    );
  }
  
  FormData formData = FormData();
  
  for (String path in imagePaths) {
    formData.files.add(
      MapEntry(
        'files',
        await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
        ),
      ),
    );
  }
  
  return _dio.post('/upload/product-images', data: formData);
}
  /// Delete single image from Cloudinary
  /// public_id example: "products/abc123"
  Future<Response> deleteProductImage(String publicId) => 
    delete('/upload/product-image?public_id=$publicId');


}