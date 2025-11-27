import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _statisticsData = [];
  String _selectedView = 'month'; // 'day', 'month', 'year'
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      Response response;
      
      switch (_selectedView) {
        case 'day':
          // Load data for a single day using period-range
          final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
          response = await _api.getPeriodRangeSummary(
            startDate: dateStr,
            endDate: dateStr,
            groupBy: 'day',
          );
          break;
          
        case 'month':
          // Load data for a single month using period-range
          final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
          final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
          response = await _api.getPeriodRangeSummary(
            startDate: '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}',
            endDate: '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}',
            groupBy: 'month',
          );
          break;
          
        case 'year':
          // Load data for a single year using period-range
          final firstDay = DateTime(_selectedDate.year, 1, 1);
          final lastDay = DateTime(_selectedDate.year, 12, 31);
          response = await _api.getPeriodRangeSummary(
            startDate: '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}',
            endDate: '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}',
            groupBy: 'year',
          );
          break;
          
        default:
          response = await _api.getMonthlyBillSummary();
      }
      
      print('📊 Statistics response: ${response.data}');
      
      setState(() {
        _statisticsData = response.data ?? [];
        _loading = false;
      });
    } catch (e) {
      print('❌ Error loading statistics: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to safely convert to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  // Helper method to safely convert to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _getViewTitle() {
    switch (_selectedView) {
      case 'day':
        return 'Vue Journalière';
      case 'month':
        return 'Vue Mensuelle';
      case 'year':
        return 'Vue Annuelle';
      default:
        return 'Statistiques';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildViewSelector(),
          _buildDateSelector(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorView()
                    : _buildStatisticsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'day',
                  label: Text('Jour'),
                  icon: Icon(Icons.today),
                ),
                ButtonSegment(
                  value: 'month',
                  label: Text('Mois'),
                  icon: Icon(Icons.calendar_month),
                ),
                ButtonSegment(
                  value: 'year',
                  label: Text('Année'),
                  icon: Icon(Icons.calendar_today),
                ),
              ],
              selected: {_selectedView},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedView = newSelection.first;
                });
                _loadStatistics();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    switch (_selectedView) {
                      case 'day':
                        // Navigate to previous day
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        break;
                      case 'month':
                        // Navigate to previous month
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                          1,
                        );
                        break;
                      case 'year':
                        // Navigate to previous year
                        _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
                        break;
                    }
                  });
                  _loadStatistics();
                },
              ),
              InkWell(
                onTap: () async {
                  if (_selectedView == 'year') {
                    // Year picker
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sélectionner une année'),
                        content: SizedBox(
                          width: 300,
                          height: 300,
                          child: YearPicker(
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            selectedDate: _selectedDate,
                            onChanged: (date) {
                              setState(() => _selectedDate = date);
                              Navigator.pop(context);
                              _loadStatistics();
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Date picker for day/month
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _loadStatistics();
                    }
                  }
                },
                child: Row(
                  children: [
                    Text(
                      _getDateText(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    switch (_selectedView) {
                      case 'day':
                        // Navigate to next day
                        _selectedDate = _selectedDate.add(const Duration(days: 1));
                        break;
                      case 'month':
                        // Navigate to next month
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                          1,
                        );
                        break;
                      case 'year':
                        // Navigate to next year
                        _selectedDate = DateTime(_selectedDate.year + 1, 1, 1);
                        break;
                    }
                  });
                  _loadStatistics();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateText() {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    switch (_selectedView) {
      case 'day':
        // Show specific day: "15 Novembre 2024"
        return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 'month':
        // Show specific month: "Novembre 2024"
        return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 'year':
        // Show specific year: "2024"
        return _selectedDate.year.toString();
      default:
        return '';
    }
  }

  Widget _buildStatisticsContent() {
    if (_statisticsData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'pour ${_getDateText()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(_statisticsData),
          const SizedBox(height: 24),
          _buildDetailedList(_statisticsData),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<dynamic> data) {
    // Calculate totals
    double totalRevenue = 0;
    double totalPaid = 0;
    double totalPending = 0;
    int totalBills = 0;

    for (var item in data) {
      totalRevenue += _toDouble(item['total_revenue']);
      totalPaid += _toDouble(item['total_paid']);
      totalPending += _toDouble(item['total_pending']);
      totalBills += _toInt(item['total_bills']);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé ${_getViewTitle()}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _SummaryCard(
              title: 'Total Factures',
              value: totalBills.toString(),
              icon: Icons.receipt_long,
              color: Colors.blue,
            ),
            _SummaryCard(
              title: 'Revenu Total',
              value: '${totalRevenue.toStringAsFixed(0)} DA',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _SummaryCard(
              title: 'Total Payé',
              value: '${totalPaid.toStringAsFixed(0)} DA',
              icon: Icons.check_circle,
              color: Colors.teal,
            ),
            _SummaryCard(
              title: 'Total Impayé',
              value: '${totalPending.toStringAsFixed(0)} DA',
              icon: Icons.money_off,
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedList(List<dynamic> data) {
    // For single period views, we don't need to show a list
    // The summary cards already show the data
    // if (data.length <= 1) {
    //   return const SizedBox.shrink();
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...data.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${_toInt(item['total_bills'])}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  _getPeriodLabel(item),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Revenu: ${_toDouble(item['total_revenue']).toStringAsFixed(0)} DA',
                  style: const TextStyle(color: Colors.green),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Total Factures',
                          value: '${_toInt(item['total_bills'])}',
                          icon: Icons.receipt_long,
                        ),
                        const Divider(),
                        _DetailRow(
                          label: 'Revenu Total',
                          value: '${_toDouble(item['total_revenue']).toStringAsFixed(2)} DA',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                        const Divider(),
                        _DetailRow(
                          label: 'Total Payé',
                          value: '${_toDouble(item['total_paid']).toStringAsFixed(2)} DA',
                          icon: Icons.check_circle,
                          color: Colors.teal,
                        ),
                        const Divider(),
                        _DetailRow(
                          label: 'Total Impayé',
                          value: '${_toDouble(item['total_pending']).toStringAsFixed(2)} DA',
                          icon: Icons.money_off,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _getPeriodLabel(Map<String, dynamic> item) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    final period = item['period']?.toString();
    if (period == null) return 'Période inconnue';
    
    try {
      switch (_selectedView) {
        case 'day':
          // Format: "2024-11-15"
          final date = DateTime.parse(period);
          return '${date.day} ${months[date.month - 1]} ${date.year}';
          
        case 'month':
          // Format: "2024-11"
          final parts = period.split('-');
          if (parts.length == 2) {
            final year = parts[0];
            final month = int.parse(parts[1]);
            return '${months[month - 1]} $year';
          }
          break;
          
        case 'year':
          // Format: "2024"
          return period;
      }
    } catch (e) {
      print('⚠️ Error parsing period: $e');
    }
    
    return period;
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}