import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_profile.dart';
import '../providers/vpn_provider.dart';
import '../widgets/connection_status_badge.dart';

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
  final _sniController = TextEditingController();
  final _dnsController = TextEditingController();
  String _protocol = 'SSTP';
  bool _useCertificate = false;
  bool _showAdvanced = false;
  bool _isEditing = false;
  String? _editingProfileId;

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _hubController.dispose();
    _sniController.dispose();
    _dnsController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingProfileId = null;
      _nameController.clear();
      _serverController.clear();
      _portController.text = '443';
      _usernameController.clear();
      _passwordController.clear();
      _hubController.clear();
      _sniController.clear();
      _dnsController.clear();
      _protocol = 'SSTP';
      _useCertificate = false;
    });
  }

  void _startEditing(VpnProfile profile) {
    setState(() {
      _isEditing = true;
      _editingProfileId = profile.id;
      _nameController.text = profile.name;
      _serverController.text = profile.serverAddress;
      _portController.text = profile.port.toString();
      _usernameController.text = profile.username;
      _passwordController.text = profile.password;
      _hubController.text = profile.hubName;
      _sniController.text = profile.sni;
      _dnsController.text = profile.dns;
      _protocol = profile.protocol;
      _useCertificate = profile.useCertificate;
    });
  }

  Future<void> _saveProfile(VpnProvider provider) async {
    final name = _nameController.text.trim();
    final serverAddress = _serverController.text.trim();

    if (name.isEmpty || serverAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least the profile name and server address.')),
      );
      return;
    }

    try {
      await provider.saveProfile(
        id: _editingProfileId,
        name: name,
        serverAddress: serverAddress,
        port: int.tryParse(_portController.text) ?? 443,
        username: _usernameController.text,
        password: _passwordController.text,
        hubName: _hubController.text,
        protocol: _protocol,
        useCertificate: _useCertificate,
        sni: _sniController.text,
        dns: _dnsController.text,
      );

      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Profile updated successfully.' : 'Profile saved successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoftEther VPN'),
        centerTitle: true,
      ),
      body: Consumer<VpnProvider>(
        builder: (context, provider, _) {
          final connectionColor = switch (provider.connectionStatus) {
            VpnConnectionStatus.connected => Colors.green,
            VpnConnectionStatus.connecting => Colors.orange,
            VpnConnectionStatus.failed => Colors.red,
            VpnConnectionStatus.disconnected => Colors.blueGrey,
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [connectionColor.withOpacity(0.08), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: connectionColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'SSTP',
                              style: TextStyle(
                                color: connectionColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              provider.selectedProfile == null
                                  ? 'No profile selected'
                                  : provider.selectedProfile!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ConnectionStatusBadge(
                            label: provider.connectionStatus.name.toUpperCase(),
                            color: connectionColor,
                          ),
                          const SizedBox(width: 8),
                          if (provider.connectedAt != null)
                            Expanded(
                              child: Text(
                                'Connected ${provider.connectedAt!.toLocal().toString().split('.')[0]}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (provider.isConnected)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Connected successfully. VPN is active.', style: TextStyle(color: Colors.green.shade800))),
                            ],
                          ),
                        )
                      else
                        Text(provider.statusMessage, style: const TextStyle(fontSize: 14)),
                      if (provider.errorMessage != null) ...[
                        const SizedBox(height: 6),
                        Text(provider.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isConnecting || provider.selectedProfile == null
                              ? null
                              : () => provider.connectProfile(provider.selectedProfile!),
                          icon: const Icon(Icons.power_settings_new),
                          label: Text(provider.isConnecting ? 'Connecting...' : 'Connect'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: provider.isConnecting ? null : provider.disconnect,
                          icon: const Icon(Icons.stop),
                          label: const Text('Disconnect'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(_isEditing ? 'Edit profile' : 'Add profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Profile name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Server address',
                  hintText: 'vpn.example.com',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: '443 or 5555',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _hubController,
                      decoration: const InputDecoration(labelText: 'Hub name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'SoftEther username',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'SoftEther password',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _protocol,
                decoration: const InputDecoration(labelText: 'Protocol'),
                items: const [
                  DropdownMenuItem(value: 'SSTP', child: Text('SSTP')),
                  DropdownMenuItem(value: 'SSL', child: Text('SSL')),
                ],
                onChanged: (value) {
                  setState(() {
                    _protocol = value ?? 'SSTP';
                  });
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Advanced settings'),
                trailing: Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more),
                onTap: () {
                  setState(() {
                    _showAdvanced = !_showAdvanced;
                  });
                },
              ),
              if (_showAdvanced) ...[
                const SizedBox(height: 4),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use certificate'),
                  value: _useCertificate,
                  onChanged: (value) {
                    setState(() {
                      _useCertificate = value;
                    });
                  },
                ),
                TextField(
                  controller: _sniController,
                  decoration: const InputDecoration(labelText: 'SNI'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dnsController,
                  decoration: const InputDecoration(labelText: 'DNS'),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveProfile(provider),
                      icon: Icon(_isEditing ? Icons.update : Icons.save),
                      label: Text(_isEditing ? 'Update profile' : 'Save profile'),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Text('Saved profiles', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (provider.profiles.isEmpty)
                const Text('No saved profiles yet.')
              else
                ...provider.profiles.map((profile) => _buildProfileTile(profile, provider)),
              const SizedBox(height: 16),
              Text('Event log', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: provider.eventLog.isEmpty
                      ? [const Text('No events yet.')]
                      : provider.eventLog.reversed.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(entry, style: const TextStyle(fontSize: 12)),
                          )).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTile(VpnProfile profile, VpnProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(profile.protocol == 'SSTP' ? Icons.lock_open : Icons.vpn_key),
        ),
        title: Text(profile.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${profile.serverAddress}:${profile.port} • ${profile.protocol}'),
            const SizedBox(height: 4),
            Text('${profile.username} • ${profile.hubName.isEmpty ? 'default hub' : profile.hubName}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _startEditing(profile),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.deleteProfile(profile.id),
            ),
          ],
        ),
        onTap: () async {
          provider.selectProfile(profile);
          await provider.connectProfile(profile);
        },
      ),
    );
  }
}
