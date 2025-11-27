import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AdminClientsScreen extends StatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  State<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends State<AdminClientsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _clients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getAllClients();
      setState(() {
        _clients = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive(int id) async {
    await _api.toggleClientActive(id);
    _loadClients();
  }

  Future<void> _deleteClient(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Supprimer ce client?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await _api.deleteClient(id);
      _loadClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadClients,
              child: _clients.isEmpty
                  ? const Center(child: Text('Aucun client'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _clients.length,
                      itemBuilder: (ctx, i) {
                        final client = _clients[i];
                        final isActive = client['is_active'] ?? false;
                        final username = client['username'] ?? '';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive ? Colors.green : Colors.grey,
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : 'C',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(username),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(client['email'] ?? 'Pas d\'email'),
                                Text('Tel: ${client['phone_number'] ?? 'N/A'}'),
                                if (client['city'] != null) Text('Ville: ${client['city']}'),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(children: [
                                    Icon(isActive ? Icons.block : Icons.check_circle),
                                    const SizedBox(width: 8),
                                    Text(isActive ? 'Désactiver' : 'Activer'),
                                  ]),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: const Row(children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Supprimer'),
                                  ]),
                                ),
                              ],
                              onSelected: (val) {
                                if (val == 'toggle') _toggleActive(client['id']);
                                if (val == 'delete') _deleteClient(client['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}