import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vpn_profile.dart';
import '../services/sstp_vpn_service.dart';
import '../services/storage_service.dart';

enum VpnConnectionStatus { disconnected, connecting, connected, failed }

class VpnProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final SstpVpnService _vpnService = SstpVpnService();

  List<VpnProfile> _profiles = [];
  VpnProfile? _selectedProfile;
  VpnConnectionStatus _connectionStatus = VpnConnectionStatus.disconnected;
  bool _isConnecting = false;
  String _statusMessage = 'Ready to connect';
  String? _errorMessage;
  DateTime? _connectedAt;
  final List<String> _eventLog = [];

  List<VpnProfile> get profiles => _profiles;
  VpnProfile? get selectedProfile => _selectedProfile;
  bool get isConnecting => _isConnecting;
  String get statusMessage => _statusMessage;
  VpnConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus == VpnConnectionStatus.connected;
  String? get errorMessage => _errorMessage;
  DateTime? get connectedAt => _connectedAt;
  List<String> get eventLog => _eventLog;

  Future<void> loadProfiles() async {
    _profiles = await _storageService.loadProfiles();
    _eventLog.add('Loaded ${_profiles.length} VPN profiles');
    developer.log('Loaded ${_profiles.length} VPN profiles');
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
    required bool useCertificate,
    required String sni,
    required String dns,
    String? id,
  }) async {
    final profile = VpnProfile(
      id: id ?? const Uuid().v4(),
      name: name.trim(),
      serverAddress: serverAddress.trim(),
      port: port,
      username: username.trim(),
      password: password,
      hubName: hubName.trim(),
      protocol: protocol.trim().isEmpty ? 'SSTP' : protocol.trim(),
      useCertificate: useCertificate,
      sni: sni.trim(),
      dns: dns.trim(),
    );

    final validationErrors = profile.validationErrors();
    if (validationErrors.isNotEmpty) {
      throw Exception(validationErrors.join(', '));
    }

    await _storageService.saveProfile(profile);
    _profiles = await _storageService.loadProfiles();
    _selectedProfile = profile;
    _connectionStatus = VpnConnectionStatus.disconnected;
    _eventLog.add('Saved profile: ${profile.name} (${profile.serverAddress}:${profile.port})');
    developer.log('Saved profile: ${profile.name} (${profile.serverAddress}:${profile.port})');
    _statusMessage = id == null ? 'Saved ${profile.name}' : 'Updated ${profile.name}';
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> connectProfile(VpnProfile profile) async {
    _isConnecting = true;
    _connectionStatus = VpnConnectionStatus.connecting;
    _selectedProfile = profile;
    _statusMessage = 'Connecting to ${profile.name}...';
    _errorMessage = null;
    notifyListeners();

    try {
      _eventLog.add('Connecting to profile: ${profile.name} via ${profile.protocol}');
      developer.log('Connecting to profile: ${profile.name} via ${profile.protocol}');
      await _vpnService.connect(profile);
      await _storageService.saveLastConnectedProfile(profile.id);
      _connectionStatus = VpnConnectionStatus.connected;
      _connectedAt = DateTime.now();
      _statusMessage = 'Connected to ${profile.name}';
      _eventLog.add('Connected successfully to ${profile.name}');
    } catch (error) {
      _eventLog.add('Connection failed for ${profile.name}: $error');
      developer.log('Connection failed for ${profile.name}: $error');
      _connectionStatus = VpnConnectionStatus.failed;
      _statusMessage = 'Connection failed';
      _errorMessage = error.toString();
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _isConnecting = false;
    _connectionStatus = VpnConnectionStatus.disconnected;
    _connectedAt = null;
    _statusMessage = 'Disconnected';
    _errorMessage = null;
    notifyListeners();
    _eventLog.add('Disconnected from VPN');
    developer.log('Disconnected from VPN');
    await _vpnService.disconnect();
  }

  Future<void> deleteProfile(String id) async {
    await _storageService.deleteProfile(id);
    _profiles = await _storageService.loadProfiles();
    if (_selectedProfile?.id == id) {
      _selectedProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    _statusMessage = 'Removed profile';
    _eventLog.add('Deleted profile: $id');
    developer.log('Deleted profile: $id');
    _errorMessage = null;
    notifyListeners();
  }

  void selectProfile(VpnProfile profile) {
    _selectedProfile = profile;
    notifyListeners();
  }
}
