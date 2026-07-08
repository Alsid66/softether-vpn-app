import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_profile.dart';
import '../providers/vpn_provider.dart';

class VpnHomePage extends StatefulWidget {
  const VpnHomePage({super.key});

  @override
  State<VpnHomePage> createState() => _VpnHomePageState();
}

class _VpnHomePageState extends State<VpnHomePage> {
  final _nameController = TextEditingController();
  final _serverController = TextEditingController();
  final _portController = TextEditingController(text: '443');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _hubController = TextEditingController();
  String _protocol = 'SSTP';

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _hubController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(VpnProvider provider) async {
    if (_nameController.text.trim().isEmpty || _serverController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least the profile name and server address.')),
      );
      return;
    }

    await provider.saveProfile(
      name: _nameController.text,
      serverAddress: _serverController.text,
      port: int.tryParse(_portController.text) ?? 443,
      username: _usernameController.text,
      password: _passwordController.text,
      hubName: _hubController.text,
      protocol: _protocol,
    );

    _nameController.clear();
    _serverController.clear();
    _portController.text = '443';
    _usernameController.clear();
    _passwordController.clear();
    _hubController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSTP VPN Client'),
        centerTitle: true,
      ),
      body: Consumer<VpnProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.selectedProfile == null
                            ? 'No profile selected'
                            : 'Selected: ${provider.selectedProfile!.name}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(provider.statusMessage),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: provider.isConnecting || provider.selectedProfile == null
                                  ? null
                                  : () => provider.connectProfile(provider.selectedProfile!),
                              icon: const Icon(Icons.power_settings_new),
                              label: Text(provider.isConnecting ? 'Connecting...' : 'Connect'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: provider.isConnecting ? null : provider.disconnect,
                              icon: const Icon(Icons.stop),
                              label: const Text('Disconnect'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('New SSTP profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Profile name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _serverController,
                decoration: const InputDecoration(labelText: 'Server address'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Port'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hubController,
                decoration: const InputDecoration(labelText: 'Hub name (optional)'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _protocol,
                decoration: const InputDecoration(labelText: 'Protocol'),
                items: const [
                  DropdownMenuItem(value: 'SSTP', child: Text('SSTP')),
                  DropdownMenuItem(value: 'OpenVPN', child: Text('OpenVPN')),
                ],
                onChanged: (value) {
                  setState(() {
                    _protocol = value ?? 'SSTP';
                  });
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _saveProfile(provider),
                icon: const Icon(Icons.save),
                label: const Text('Save profile'),
              ),
              const SizedBox(height: 24),
              Text('Saved profiles', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (provider.profiles.isEmpty)
                const Text('No saved profiles yet.')
              else
                ...provider.profiles.map((profile) => _buildProfileTile(profile, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTile(VpnProfile profile, VpnProvider provider) {
    return Card(
      child: ListTile(
        title: Text(profile.name),
        subtitle: Text('${profile.serverAddress}:${profile.port} • ${profile.protocol}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => provider.deleteProfile(profile.id),
        ),
        onTap: () async {
          await provider.connectProfile(profile);
        },
      ),
    );
  }
}
