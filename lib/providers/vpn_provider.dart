import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/vpn_profile.dart';
import '../services/sstp_vpn_service.dart';
import '../services/storage_service.dart';

class VpnProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final SstpVpnService _vpnService = SstpVpnService();

  List<VpnProfile> _profiles = [];
  VpnProfile? _selectedProfile;
  bool _isConnecting = false;
  String _statusMessage = 'Ready to connect';

  List<VpnProfile> get profiles => _profiles;
  VpnProfile? get selectedProfile => _selectedProfile;
  bool get isConnecting => _isConnecting;
  String get statusMessage => _statusMessage;

  Future<void> loadProfiles() async {
    _profiles = await _storageService.loadProfiles();
    if (_profiles.isNotEmpty) {
      final lastId = await _storageService.getLastConnectedProfileId();
      _selectedProfile = _profiles.firstWhere(
        (profile) => profile.id == lastId,
        orElse: () => _profiles.first,
      );
    }
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String serverAddress,
    required int port,
    required String username,
    required String password,
    required String hubName,
    required String protocol,
  }) async {
    final profile = VpnProfile(
      id: const Uuid().v4(),
      name: name.trim(),
      serverAddress: serverAddress.trim(),
      port: port,
      username: username.trim(),
      password: password,
      hubName: hubName.trim(),
      protocol: protocol.trim().isEmpty ? 'SSTP' : protocol.trim(),
    );

    await _storageService.saveProfile(profile);
    _profiles = await _storageService.loadProfiles();
    _selectedProfile = profile;
    _statusMessage = 'Saved ${profile.name}';
    notifyListeners();
  }

  Future<void> connectProfile(VpnProfile profile) async {
    _isConnecting = true;
    _selectedProfile = profile;
    _statusMessage = 'Connecting to ${profile.name}...';
    notifyListeners();

    try {
      await _vpnService.connect(profile);
      await _storageService.saveLastConnectedProfile(profile.id);
      _statusMessage = 'Connected to ${profile.name}';
    } catch (error) {
      _statusMessage = 'Connection failed: $error';
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _isConnecting = false;
    _statusMessage = 'Disconnected';
    notifyListeners();
    await _vpnService.disconnect();
  }

  Future<void> deleteProfile(String id) async {
    await _storageService.deleteProfile(id);
    _profiles = await _storageService.loadProfiles();
    if (_selectedProfile?.id == id) {
      _selectedProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    _statusMessage = 'Removed profile';
    notifyListeners();
  }
}
