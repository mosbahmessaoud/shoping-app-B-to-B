// import 'dart:math';
// import 'package:dio/dio.dart';
// import 'storage_service.dart';

// class ApiService {
//   static const String baseUrl = 'http://127.0.0.1:8000';
//   final Dio _dio = Dio();
//   final StorageService _storage = StorageService();

//   ApiService() {
//     _dio.options.baseUrl = baseUrl;
//     _dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         final token = await _storage.getToken();
        
//         if (token != null) {
//           options.headers['Authorization'] = 'Bearer $token';
//         }
        
//         return handler.next(options);
//       },
//     ));
//   }

//   // Generic methods
//   Future<Response> get(String path, {Map<String, dynamic>? params}) => 
//     _dio.get(path, queryParameters: params);
  
//   Future<Response> post(String path, {dynamic data}) => 
//     _dio.post(path, data: data);
  
//   Future<Response> put(String path, {dynamic data}) => 
//     _dio.put(path, data: data);
  
//   Future<Response> patch(String path, {dynamic data}) => 
//     _dio.patch(path, data: data);
  
//   Future<Response> delete(String path) => 
//     _dio.delete(path);

//   // General endpoints
//   Future<Response> getTypeOfUser(Map<String, dynamic> data) => post('/auth/type_user', data: data);

//   // Client endpoints
//   Future<Response> registerClient(Map<String, dynamic> data) => post('/client/register', data: data);
//   Future<Response> loginClient(Map<String, dynamic> data) => post('/client/login', data: data);
//   Future<Response> getClientProfile() => get('/client/me');
//   Future<Response> updateClientProfile(Map<String, dynamic> data) => put('/client/me', data: data);
//   Future<Response> getAllClients({int skip = 0, int limit = 100}) => get('/client/', params: {'skip': skip, 'limit': limit});
//   Future<Response> getClientById(int id) => get('/client/$id');
//   Future<Response> toggleClientActive(int id) => patch('/client/$id/toggle-active');
//   Future<Response> deleteClient(int id) => delete('/client/$id');

//   // Admin endpoints
//   Future<Response> loginAdmin(Map<String, dynamic> data) => post('/admin/login', data: data);
//   Future<Response> getAdminProfile() => get('/admin/me');
//   Future<Response> updateAdminProfile(Map<String, dynamic> data) => put('/admin/me', data: data);
//   Future<Response> getAllAdmins({int skip = 0, int limit = 100}) => get('/admin/', params: {'skip': skip, 'limit': limit});
//   Future<Response> deleteAdmin(int id) => delete('/admin/$id');

//   // Product endpoints
//   Future<Response> createProduct(Map<String, dynamic> data) => post('/product/', data: data);
//   Future<Response> getAllProducts({
//     int? categoryId, 
//     bool? isActive, 
//     int skip = 0, 
//     int limit = 100
//   }) => get('/product/', params: {
//     'skip': skip,
//     'limit': limit,
//     if (categoryId != null) 'category_id': categoryId,
//     if (isActive != null) 'is_active': isActive,
//   });
//   Future<Response> getLowStockProducts() => get('/product/low-stock');
//   Future<Response> getProductById(int id) => get('/product/$id');
//   Future<Response> updateProduct(int id, Map<String, dynamic> data) => put('/product/$id', data: data);
//   Future<Response> updateProductStock(int id, int quantity) => 
//     patch('/product/$id/stock', data: {'quantity': quantity});
//   Future<Response> deleteProduct(int id) => delete('/product/$id');
//   Future<Response> getProductSummary() => get('/product/count');

//   // Category endpoints
//   Future<Response> createCategory(Map<String, dynamic> data) => post('/category/', data: data);
//   Future<Response> getAllCategories({int skip = 0, int limit = 100}) => get('/category/', params: {'skip': skip, 'limit': limit});
//   Future<Response> getCategoryById(int id) => get('/category/$id');
//   Future<Response> updateCategory(int id, Map<String, dynamic> data) => put('/category/$id', data: data);
//   Future<Response> deleteCategory(int id) => delete('/category/$id');

//   // Bill endpoints
//   Future<Response> createBill(Map<String, dynamic> data) => post('/bill/', data: data);
//   Future<Response> getMyBills({int skip = 0, int limit = 100}) => get('/bill/my-bills', params: {'skip': skip, 'limit': limit});
//   Future<Response> getAllMyBills() => get('/bill/my-bills/count');
//   Future<Response> getAllUnpaidBills() => get('/bill/unpaid-bills/count');
//   Future<Response> getAllBills({String? status, int skip = 0, int limit = 100}) => 
//     get('/bill/all', params: {'status_filter': status, 'skip': skip, 'limit': limit});
//   Future<Response> getBillSummary() => get('/bill/summary');
//   Future<Response> getBillById(int id) => get('/bill/$id');
//   Future<Response> getAdminBillById(int id) => get('/bill/admin/$id');
//   Future<Response> payBill(int billId, double amount) => 
//     _dio.post('/bill/$billId/pay', queryParameters: {'amount': amount});
//   Future<Response> updateBillStatus(int id, String status) => 
//     patch('/bill/$id/status', data: {'status': status});
//   Future<Response> deleteBill(int id) => delete('/bill/$id');
  
  
//   // Statistics endpoints
//   Future<Response> getDailyBillSummary({required int year, required int month}) => 
//     get('/bill/statistics/daily', params: {'year': year, 'month': month});
  
//   Future<Response> getMonthlyBillSummary({int? year}) => 
//     get('/bill/statistics/monthly', params: year != null ? {'year': year} : {});
  
//   Future<Response> getYearlyBillSummary() => 
//     get('/bill/statistics/yearly');
  
//   Future<Response> getPeriodRangeSummary({
//     required String startDate,
//     required String endDate,
//     required String groupBy,
//   }) => get('/bill/statistics/period-range', params: {
//     'start_date': startDate,
//     'end_date': endDate,
//     'group_by': groupBy,
//   });

//   // Payment endpoints
//   Future<Response> createPayment(Map<String, dynamic> data) => post('/payment/', data: data);
//   Future<Response> getBillPaymentHistory(int billId) => get('/payment/bill/$billId');
//   Future<Response> getAllPayments({int skip = 0, int limit = 100}) => get('/payment/', params: {'skip': skip, 'limit': limit});
//   Future<Response> getPaymentById(int id) => get('/payment/$id');
//   Future<Response> updatePayment(int id, Map<String, dynamic> data) => put('/payment/$id', data: data);
//   Future<Response> deletePayment(int id) => delete('/payment/$id');

//   // Stock Alert endpoints
//   Future<Response> getAllStockAlerts({bool? isResolved, int skip = 0, int limit = 100}) => 
//     get('/stock-alert/', params: {'is_resolved': isResolved, 'skip': skip, 'limit': limit});
//   Future<Response> getUnresolvedStockAlerts() => get('/stock-alert/unresolved');
//   Future<Response> getStockAlertSummary() => get('/stock-alert/summary');
//   Future<Response> getStockAlertById(int id) => get('/stock-alert/$id');
//   Future<Response> resolveStockAlert(int id) => patch('/stock-alert/$id/resolve');
//   Future<Response> unresolveStockAlert(int id) => patch('/stock-alert/$id/unresolve');
//   Future<Response> deleteStockAlert(int id) => delete('/stock-alert/$id');

//   // Notification endpoints
//   Future<Response> getAllNotifications({bool? isSent, String? type, int skip = 0, int limit = 100}) => 
//     get('/notification/', params: {'is_sent': isSent, 'notification_type': type, 'skip': skip, 'limit': limit});
//   Future<Response> getPendingNotifications() => get('/notification/pending');
//   Future<Response> getNotificationSummary() => get('/notification/summary');
//   Future<Response> getNotificationById(int id) => get('/notification/$id');
//   Future<Response> markNotificationSent(int id) => patch('/notification/$id/mark-sent');
//   Future<Response> deleteNotification(int id) => delete('/notification/$id');
//   Future<Response> sendPendingNotifications() => post('/notification/send-pending');
// }