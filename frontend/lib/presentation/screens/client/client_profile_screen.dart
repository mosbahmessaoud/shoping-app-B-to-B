import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/theme_service.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  final ThemeService _theme = ThemeService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadTheme();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getClientProfile();
      setState(() {
        _profile = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadTheme() async {
    final mode = await _theme.getThemeMode();
    setState(() => _themeMode = mode);
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    await _theme.setThemeMode(mode);
    setState(() => _themeMode = mode);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _auth.logout();
      if (mounted) context.go('/login');
    }
  }

  void _showEditDialog() {
    final usernameController = TextEditingController(text: _profile?['username']);
    final emailController = TextEditingController(text: _profile?['email']);
    final phoneController = TextEditingController(text: _profile?['phone_number']);
    final addressController = TextEditingController(text: _profile?['address']);
    final cityController = TextEditingController(text: _profile?['city']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _api.updateClientProfile({
                  'username': usernameController.text,
                  'email': emailController.text,
                  'phone_number': phoneController.text,
                  'address': addressController.text,
                  'city': cityController.text,
                });
                Navigator.pop(ctx);
                _loadProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil mis à jour avec succès')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    final dt = DateTime.parse(date);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        _profile?['username']?[0].toUpperCase() ?? 'C',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _profile?['username'] ?? 'Client',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _profile?['email'] ?? '',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Chip(
                      label: Text(_profile?['is_active'] == true ? 'Compte Actif' : 'Compte Inactif'),
                      backgroundColor: _profile?['is_active'] == true 
                        ? Colors.green.withOpacity(0.2) 
                        : Colors.grey.withOpacity(0.2),
                      avatar: Icon(
                        _profile?['is_active'] == true ? Icons.check_circle : Icons.cancel,
                        color: _profile?['is_active'] == true ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Personal Information Card
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Informations Personnelles'),
                          subtitle: Text('Membre depuis: ${_formatDate(_profile?['created_at'])}'),
                        ),
                        const Divider(height: 1),
                        if (_profile?['phone_number'] != null)
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text('Téléphone'),
                            subtitle: Text(_profile!['phone_number']),
                          ),
                        if (_profile?['address'] != null)
                          ListTile(
                            leading: const Icon(Icons.home),
                            title: const Text('Adresse'),
                            subtitle: Text(_profile!['address']),
                          ),
                        if (_profile?['city'] != null)
                          ListTile(
                            leading: const Icon(Icons.location_city),
                            title: const Text('Ville'),
                            subtitle: Text(_profile!['city']),
                          ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Modifier profil'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showEditDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Theme Card
                  Card(
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.palette),
                          title: Text('Thème de l\'application'),
                          subtitle: Text('Choisissez votre mode préféré'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode),
                                label: Text('Clair'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto),
                                label: Text('Auto'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode),
                                label: Text('Sombre'),
                              ),
                            ],
                            selected: {_themeMode},
                            onSelectionChanged: (val) => _changeTheme(val.first),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Actions Card
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: const Text('Mon Panier'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/client/cart'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: const Text('Mes Factures'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/client/bills'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Logout Card
                  Card(
                    color: Colors.red.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Déconnexion',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.red),
                      onTap: _logout,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}