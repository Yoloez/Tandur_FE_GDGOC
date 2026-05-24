import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/buyer/checkout/models/transaction_model.dart';

class CheckoutService {
  /// Fetches the latest transaction (or all transactions) from GET /transactions.
  /// For checkout, we assume we need to show the details from the first transaction in the list,
  /// or filter to the 'menunggu' one if needed. Let's just return the latest.
  static Future<TransactionModel?> fetchLatestTransaction() async {
    try {
      final response = await ApiClient.dio.get('/transactions');
      final List<dynamic> data = response.data;
      if (data.isNotEmpty) {
        // Assuming the first one is the relevant one, or we filter by status
        // Let's just take the first one or the latest one
        return TransactionModel.fromJson(data.first);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data transaksi');
      }
      throw Exception('Kesalahan jaringan');
    }
  }
}
