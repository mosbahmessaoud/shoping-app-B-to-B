import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class MyBillsScreen extends StatefulWidget {
  const MyBillsScreen({super.key});

  @override
  State<MyBillsScreen> createState() => _MyBillsScreenState();
}

class _MyBillsScreenState extends State<MyBillsScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<dynamic> _bills = [];
  bool _loading = true;
  late TabController _tabController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBills();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      print('🔍 Loading bills...');
      final response = await _api.getMyBills();
      print('✅ Bills response: ${response.data}');
      
      setState(() {
        _bills = response.data ?? [];
        _loading = false;
      });
      
      print('✅ Loaded ${_bills.length} bills');
    } catch (e) {
      print('❌ Error loading bills: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement factures: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<dynamic> _filterBills(String? status) {
    if (status == null) return _bills;
    return _bills.where((b) => b['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allBills = _bills;
    final paidBills = _filterBills('paid');
    final partialBills = _filterBills('partial');
    final unpaidBills = _filterBills('unpaid');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Factures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBills,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Toutes (${allBills.length})'),
            Tab(text: 'Payées (${paidBills.length})'),
            Tab(text: 'Partielles (${partialBills.length})'),
            Tab(text: 'Impayées (${unpaidBills.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBillsList(allBills),
                    _buildBillsList(paidBills),
                    _buildBillsList(partialBills),
                    _buildBillsList(unpaidBills),
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
            onPressed: _loadBills,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList(List<dynamic> bills) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Aucune facture', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/client/products'),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Parcourir les produits'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBills,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        itemBuilder: (ctx, i) => _BillCard(
          bill: bills[i],
          onTap: () {
            print('📄 Opening bill: ${bills[i]['id']}');
            context.push('/client/bill/${bills[i]['id']}');
          },
        ),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Map<String, dynamic> bill;
  final VoidCallback onTap;

  const _BillCard({
    required this.bill,
    required this.onTap,
  });

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.orange;
      case 'unpaid': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'paid': return 'Payée';
      case 'partial': return 'Partielle';
      case 'unpaid': return 'Impayée';
      default: return 'Inconnu';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'paid': return Icons.check_circle;
      case 'partial': return Icons.timelapse;
      case 'unpaid': return Icons.pending;
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

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse "$value" as double: $e');
        return 0.0;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final status = bill['status'];
    final statusColor = _getStatusColor(status);
    final totalAmount = _toDouble(bill['total_amount']);
    final totalPaid = _toDouble(bill['total_paid']);
    final remaining = _toDouble(bill['total_remaining']);
    
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with bill number and status
              _buildHeader(status, statusColor, isSmallScreen, isMediumScreen),
              
              SizedBox(height: isSmallScreen ? 8 : 12),
              const Divider(),
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              // Amount details
              _buildAmountSection(
                totalAmount, 
                totalPaid, 
                isSmallScreen, 
                isMediumScreen
              ),
              
              // Remaining amount (if any)
              if (remaining > 0) ...[
                SizedBox(height: isSmallScreen ? 6 : 8),
                _buildRemainingAmount(remaining, isSmallScreen),
              ],
              
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              // Footer with date and view details
              _buildFooter(isSmallScreen, isMediumScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String? status, Color statusColor, bool isSmallScreen, bool isMediumScreen) {
    return Flex(
      direction: isMediumScreen ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: isMediumScreen 
          ? MainAxisAlignment.start 
          : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMediumScreen 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(status), 
              color: statusColor, 
              size: isSmallScreen ? 20 : 24
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Facture #${bill['bill_number'] ?? bill['id']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (isMediumScreen) const SizedBox(height: 8),
        Chip(
          label: Text(
            _getStatusLabel(status),
            style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
          ),
          backgroundColor: statusColor.withOpacity(0.2),
          side: BorderSide(color: statusColor),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 6 : 8,
            vertical: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(
    double totalAmount, 
    double totalPaid, 
    bool isSmallScreen,
    bool isMediumScreen
  ) {
    return Flex(
      direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isSmallScreen 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Montant Total',
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: isSmallScreen ? 11 : 12
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${totalAmount.toStringAsFixed(2)} DA',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isSmallScreen) const SizedBox(height: 8),
        if (!isSmallScreen) const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: isSmallScreen 
                ? CrossAxisAlignment.start 
                : CrossAxisAlignment.end,
            children: [
              Text(
                'Payé',
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: isSmallScreen ? 11 : 12
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: isSmallScreen 
                    ? Alignment.centerLeft 
                    : Alignment.centerRight,
                child: Text(
                  '${totalPaid.toStringAsFixed(2)} DA',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingAmount(double remaining, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Reste à payer',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${remaining.toStringAsFixed(2)} DA',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isSmallScreen, bool isMediumScreen) {
    return Flex(
      direction: isMediumScreen ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: isMediumScreen 
          ? MainAxisAlignment.start 
          : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMediumScreen 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today, 
              size: isSmallScreen ? 12 : 14, 
              color: Colors.grey[600]
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(bill['created_at']),
              style: TextStyle(
                color: Colors.grey[600], 
                fontSize: isSmallScreen ? 11 : 12
              ),
            ),
          ],
        ),
        if (isMediumScreen) const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Voir détails',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: isSmallScreen ? 12 : 14),
          ],
        ),
      ],
    );
  }
}