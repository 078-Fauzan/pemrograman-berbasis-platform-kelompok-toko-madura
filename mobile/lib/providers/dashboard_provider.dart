import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../models/dashboard_summary_model.dart';
import '../models/sales_chart_model.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  DashboardSummaryModel _summary = DashboardSummaryModel.empty();
  List<SalesChartPoint> _chartData = [];
  List<Map<String, dynamic>> _bestSelling = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardSummaryModel get summary => _summary;
  List<SalesChartPoint> get chartData => _chartData;
  List<Map<String, dynamic>> get bestSelling => _bestSelling;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Memuat data dashboard (ringkasan omset, grafik, produk terlaris)
  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil ringkasan KPI
      final summaryRes = await ApiService.get(ApiEndpoints.dashboard);
      if (summaryRes.success && summaryRes.data != null) {
        _summary = DashboardSummaryModel.fromJson(summaryRes.data);
      } else {
        _errorMessage = summaryRes.message;
      }

      // 2. Ambil data time-series grafik
      final chartRes = await ApiService.get(ApiEndpoints.salesChart);
      if (chartRes.success && chartRes.data != null) {
        final list = chartRes.data as List;
        _chartData = list.map((item) => SalesChartPoint.fromJson(item)).toList();
      }

      // 3. Ambil produk terlaris
      final bestRes = await ApiService.get(ApiEndpoints.bestSelling);
      if (bestRes.success && bestRes.data != null) {
        final list = bestRes.data as List;
        _bestSelling = list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
