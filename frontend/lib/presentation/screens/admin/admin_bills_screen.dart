import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class AdminBillsScreen extends StatefulWidget {
  const AdminBillsScreen({super.key});

  @override
  State<AdminBillsScreen> createState() => _AdminBillsScreenState();
}

class _AdminBillsScreenState extends State<AdminBillsScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _bills = [];
  bool _loading = true;
  String? _statusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBills();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getAllBills();
      setState(() {
        _bills = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _calculateStatus(double totalPaid, double remaining) {
    if (remaining == 0.0 && totalPaid > 0.0) {
      return 'paid';
    } else if (totalPaid > 0.0 && remaining > 0.0) {
      return 'partial';
    } else {
      return 'not paid';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.amber;
      case 'unpaid':
      case 'not paid': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'paid': return 'Payée';
      case 'partial': return 'Paiement Partiel';
      case 'unpaid':
      case 'not paid': return 'Impayée';
      default: return 'Inconnu';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'paid': return Icons.check_circle;
      case 'partial': return Icons.schedule;
      case 'unpaid':
      case 'not paid': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return date;
    }
  }

  List<dynamic> _getFilteredBills() {
    List<dynamic> filtered = _bills;

    if (_statusFilter != null) {
      filtered = filtered.where((bill) {
        final totalPaid = _toDouble(bill['total_paid']);
        final remaining = _toDouble(bill['total_remaining']);
        final calculatedStatus = _calculateStatus(totalPaid, remaining);
        return calculatedStatus == _statusFilter;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((bill) {
        final clientName = (bill['client_name'] ?? '').toString().toLowerCase();
        final clientPhone = (bill['client_phone'] ?? '').toString().toLowerCase();
        return clientName.contains(_searchQuery) || clientPhone.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par statut',
            onSelected: (val) {
              setState(() => _statusFilter = val == 'all' ? null : val);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('Toutes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'paid',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Payées'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'partial',
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text('Paiement Partiel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'not paid',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Impayées'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBills,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou téléphone du client...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
          ),
          // Active Filters Chips
          if (_statusFilter != null || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Filtres actifs:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_statusFilter != null)
                      Chip(
                        label: Text(_getStatusLabel(_statusFilter)),
                        onDeleted: () {
                          setState(() => _statusFilter = null);
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('Recherche: "$_searchQuery"'),
                        onDeleted: () {
                          _searchController.clear();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // Bills List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadBills,
                    child: _getFilteredBills().isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty 
                                      ? 'Aucun résultat trouvé'
                                      : 'Aucune facture',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                ),
                                if (_statusFilter != null || _searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _statusFilter = null;
                                        _searchController.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.clear_all),
                                    label: const Text('Effacer tous les filtres'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _getFilteredBills().length,
                            itemBuilder: (ctx, i) {
                              final bill = _getFilteredBills()[i];
                              final totalPaid = _toDouble(bill['total_paid']);
                              final remaining = _toDouble(bill['total_remaining']);
                              final totalAmount = _toDouble(bill['total_amount']);
                              final actualStatus = _calculateStatus(totalPaid, remaining);
                              final statusColor = _getStatusColor(actualStatus);
                              final notifSent = bill['notification_sent'] ?? false;
                              
                              return _ResponsiveBillCard(
                                bill: bill,
                                totalAmount: totalAmount,
                                totalPaid: totalPaid,
                                remaining: remaining,
                                actualStatus: actualStatus,
                                statusColor: statusColor,
                                notifSent: notifSent,
                                getStatusIcon: _getStatusIcon,
                                getStatusLabel: _getStatusLabel,
                                formatDate: _formatDate,
                                onTap: () => context.push('/admin/bill/${bill['id']}'),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveBillCard extends StatelessWidget {
  final Map<String, dynamic> bill;
  final double totalAmount;
  final double totalPaid;
  final double remaining;
  final String actualStatus;
  final Color statusColor;
  final bool notifSent;
  final IconData Function(String?) getStatusIcon;
  final String Function(String?) getStatusLabel;
  final String Function(String?) formatDate;
  final VoidCallback onTap;

  const _ResponsiveBillCard({
    required this.bill,
    required this.totalAmount,
    required this.totalPaid,
    required this.remaining,
    required this.actualStatus,
    required this.statusColor,
    required this.notifSent,
    required this.getStatusIcon,
    required this.getStatusLabel,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row - Responsive layout
              isSmallScreen
                  ? _buildSmallScreenHeader()
                  : _buildNormalHeader(),
              Divider(height: isSmallScreen ? 12 : 16),
              // Financial details - Responsive layout
              _buildFinancialDetails(isSmallScreen, isMediumScreen),
              SizedBox(height: isSmallScreen ? 6 : 8),
              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today, 
                    size: isSmallScreen ? 12 : 14, 
                    color: Colors.grey[600]
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(bill['created_at']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallScreenHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(
                getStatusIcon(actualStatus),
                color: statusColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Facture #${bill['bill_number']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (notifSent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.notifications_active,
                          size: 12,
                          color: Colors.green[700],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Client: ${bill['client_name'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(
            getStatusLabel(actualStatus),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
          side: BorderSide(color: statusColor, width: 1),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ],
    );
  }

  Widget _buildNormalHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            getStatusIcon(actualStatus),
            color: statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Facture #${bill['bill_number']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (notifSent) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.notifications_active,
                      size: 14,
                      color: Colors.green[700],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Client: ${bill['client_name'] ?? 'N/A'}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text(
            getStatusLabel(actualStatus),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
          side: BorderSide(color: statusColor, width: 1),
        ),
      ],
    );
  }

  Widget _buildFinancialDetails(bool isSmallScreen, bool isMediumScreen) {
    if (isSmallScreen) {
      // Stack layout for very small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FinancialDetail(
            label: 'Total',
            value: '${totalAmount.toStringAsFixed(2)} DA',
            color: Colors.blue,
            isCompact: true,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _FinancialDetail(
                  label: 'Payé',
                  value: '${totalPaid.toStringAsFixed(2)} DA',
                  color: Colors.green,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FinancialDetail(
                  label: 'Reste',
                  value: '${remaining.toStringAsFixed(2)} DA',
                  color: remaining > 0 ? Colors.orange : Colors.green,
                  isCompact: true,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Row layout for normal screens
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _FinancialDetail(
              label: 'Total',
              value: '${totalAmount.toStringAsFixed(2)} DA',
              color: Colors.blue,
              isCompact: isMediumScreen,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: _FinancialDetail(
              label: 'Payé',
              value: '${totalPaid.toStringAsFixed(2)} DA',
              color: Colors.green,
              isCompact: isMediumScreen,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: _FinancialDetail(
              label: 'Reste',
              value: '${remaining.toStringAsFixed(2)} DA',
              color: remaining > 0 ? Colors.orange : Colors.green,
              isCompact: isMediumScreen,
            ),
          ),
        ],
      );
    }
  }
}

class _FinancialDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isCompact;

  const _FinancialDetail({
    required this.label,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 11 : 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}