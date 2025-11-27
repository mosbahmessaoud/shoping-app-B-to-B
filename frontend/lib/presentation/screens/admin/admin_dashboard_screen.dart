import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _currentMonthStats;
  Map<String, dynamic>? _stockSummary;
  Map<String, dynamic>? _products;
  Map<String, dynamic>? _notifSummary;
  List<dynamic> _lowStockProducts = [];
  List<dynamic> _unresolvedAlerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.getMonthlyBillSummary(),
        _api.getStockAlertSummary(),
        _api.getNotificationSummary(),
        _api.getLowStockProducts(),
        _api.getUnresolvedStockAlerts(),
        _api.getProductSummary(),
      ]);

      // Get current month data from monthly summary
      final monthlyData = results[0].data as List<dynamic>;
      final now = DateTime.now();
      final currentMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      
      // Find current month's data
      Map<String, dynamic>? currentMonth;
      if (monthlyData.isNotEmpty) {
        // Assuming the API returns data with a 'month' field or the last item is the most recent
        currentMonth = monthlyData.lastWhere(
          (item) => true, // Get the most recent month
          orElse: () => {
            'total_bills': 0,
            'total_revenue': 0.0,
            'total_paid': 0.0,
            'total_pending': 0.0,
          },
        );
      }

      setState(() {
        _currentMonthStats = currentMonth ?? {
          'total_bills': 0,
          'total_revenue': 0.0,
          'total_paid': 0.0,
          'total_pending': 0.0,
        };
        _stockSummary = results[1].data;
        _notifSummary = results[2].data;
        _lowStockProducts = results[3].data;
        _unresolvedAlerts = results[4].data;
        _products = results[5].data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement: $e')),
        );
      }
    }
  }

  String _getCurrentMonthName() {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[DateTime.now().month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/admin/statistics'),
            tooltip: 'Statistiques',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/admin/profile'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),
                  _buildMonthlyStatsGrid(),
                  const SizedBox(height: 24),
                  if (_unresolvedAlerts.isNotEmpty) ...[
                    _buildUrgentAlertsSection(),
                    const SizedBox(height: 24),
                  ],
                  if (_lowStockProducts.isNotEmpty) ...[
                    _buildLowStockSection(),
                    const SizedBox(height: 24),
                  ],
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.medical_services, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Medical Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administration',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistiques'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/statistics');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Produits'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Catégories'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/clients');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Factures'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/bills');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Paiements'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/payments');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Alertes Stock'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/stock-alerts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/notifications');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.waving_hand,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Aperçu de ${_getCurrentMonthName()} ${DateTime.now().year}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
// 1. Update _buildMonthlyStatsGrid() method
Widget _buildMonthlyStatsGrid() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Ce Mois (${_getCurrentMonthName()})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: () => context.push('/admin/statistics'),
            icon: const Icon(Icons.bar_chart, size: 18),
            label: const Text('Voir plus'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          double childAspectRatio;
          final bool isVerySmallScreen = constraints.maxWidth < 280;
          final bool isSmallScreen = constraints.maxWidth < 300;
            crossAxisCount = 1;
            childAspectRatio = 2.0;
          
          if (constraints.maxWidth >= 1200) {
            crossAxisCount = 3;
            childAspectRatio = 1.6;
          } else if (constraints.maxWidth >= 900) {
            crossAxisCount = 3;
            childAspectRatio = 1.4;
          } else if (constraints.maxWidth >= 600) {
            crossAxisCount = 2;
            childAspectRatio = 1.5;

          } else  if (constraints.maxWidth >= 370)  {
            crossAxisCount = 2;
            childAspectRatio = 1.3;
          } else {
            crossAxisCount = 1;
            childAspectRatio = 2.2;
          }
          
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
            children: [
              _StatCard(
                title: 'Factures',
                value: '${_currentMonthStats?['total_bills'] ?? 0}',
                subtitle: (isSmallScreen || isVerySmallScreen ) ? null : 'Ce mois',
                icon:  isVerySmallScreen ? null : Icons.receipt_long,
                color: Colors.blue,
                onTap: () => context.push('/admin/bills'),
              ),
              _StatCard(
                title: 'Revenu',
                value: '${(_currentMonthStats?['total_revenue'] ?? 0)} DA',
                subtitle:  (isSmallScreen || isVerySmallScreen) ? null : 'Ce mois',
                icon:  isVerySmallScreen ? null : Icons.attach_money,
                color: Colors.green,
                onTap: () => context.push('/admin/statistics'),
              ),
              _StatCard(
                title: 'Payé',
                value: '${(_currentMonthStats?['total_paid'] ?? 0)} DA',
                subtitle:  (isSmallScreen || isVerySmallScreen) ? null : 'Ce mois',
                icon:  isVerySmallScreen ? null : Icons.check_circle,
                color: Colors.teal,
                onTap: () => context.push('/admin/bills'),
              ),
              _StatCard(
                title: 'Impayé',
                value: '${(_currentMonthStats?['total_pending'] ?? 0)} DA',
                subtitle:  (isSmallScreen || isVerySmallScreen) ? null : 'Ce mois',
                icon:  isVerySmallScreen ? null : Icons.money_off,
                color: Colors.orange,
                onTap: () => context.push('/admin/bills'),
              ),
              _StatCard(
                title: 'Alertes Stock',
                value: '${_stockSummary?['total_unresolved'] ?? 0}',
                subtitle:  (isSmallScreen || isVerySmallScreen) ? null : 'Non résolues',
                icon:  isVerySmallScreen ? null : Icons.warning,
                color: Colors.red,
                onTap: () => context.push('/admin/stock-alerts'),
              ),
              _StatCard(
                title: 'Produits',
                value: '${_products?["count"] ?? 0}',
                subtitle:  (isSmallScreen || isVerySmallScreen) ? null : 'Dans l\'inventaire',
                icon:  isVerySmallScreen ? null : Icons.inventory,
                color: Colors.purple,
                onTap: () => context.push('/admin/products'),
              ),
            ],
          );
        },
      ),
    ],
  );
}
  Widget _buildUrgentAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Alertes Urgentes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/admin/stock-alerts'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(_unresolvedAlerts.take(3).map((alert) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.red.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.warning, color: Colors.white, size: 20),
                ),
                title: Text(alert['product']?['name'] ?? 'Produit inconnu'),
                subtitle: Text(alert['message'] ?? 'Alerte stock'),
                trailing: Text(
                  '${alert['product']?['quantity_in_stock'] ?? 0} unités',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ))),
      ],
    );
  }

  Widget _buildLowStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_down, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Stock Faible',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/admin/products'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(_lowStockProducts.take(3).map((product) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    '${product['quantity_in_stock']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(product['name'] ?? ''),
                subtitle: Text(
                  'Minimum: ${product['minimum_stock_level']} • ${product['price']} DA',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/admin/product/edit/${product['id']}'),
              ),
            ))),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              label: 'Nouveau Produit',
              icon: Icons.add_box,
              color: Colors.blue,
              onTap: () => context.push('/admin/product/add'),
            ),
            _QuickActionButton(
              label: 'Clients',
              icon: Icons.people,
              color: Colors.green,
              onTap: () => context.push('/admin/clients'),
            ),
            _QuickActionButton(
              label: 'Catégories',
              icon: Icons.category,
              color: Colors.purple,
              onTap: () => context.push('/admin/categories'),
            ),
            _QuickActionButton(
              label: 'Statistiques',
              icon: Icons.bar_chart,
              color: Colors.indigo,
              onTap: () => context.push('/admin/statistics'),
            ),
          ],
        ),
      ],
    );
  }
}

// 2. Update _StatCard class to accept nullable parameters
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;  // Changed to nullable
  final IconData? icon;    // Changed to nullable
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,  // No longer required
    this.icon,      // No longer required
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (icon != null)  // Conditionally show icon
                    Icon(icon, color: color, size: 28),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (subtitle != null)  // Conditionally show subtitle
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}