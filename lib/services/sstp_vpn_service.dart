import 'package:flutter/services.dart';
import '../models/vpn_profile.dart';

class SstpVpnService {
  static const MethodChannel _channel = MethodChannel('softether_vpn_app/sstp');

  Future<void> connect(VpnProfile profile) async {
    if (profile.serverAddress.trim().isEmpty) {
      throw Exception('Server address is required');
    }
    if (profile.username.trim().isEmpty) {
      throw Exception('Username is required');
    }
    if (profile.password.trim().isEmpty) {
      throw Exception('Password is required');
    }

    final validationErrors = profile.validationErrors();
    if (validationErrors.isNotEmpty) {
      throw Exception(validationErrors.join(', '));
    }

    if (profile.hubName.trim().isEmpty) {
      throw Exception('Hub name is required for SoftEther connections');
    }

    final transport = profile.protocol.toUpperCase() == 'SSL' ? 'SSL' : 'SSTP';

    try {
      await _channel.invokeMethod('connect', {
        'serverAddress': profile.serverAddress,
        'port': profile.port,
        'username': profile.username,
        'password': profile.password,
        'hubName': profile.hubName,
        'protocol': transport,
        'transport': transport,
      });
    } on PlatformException catch (error) {
      throw Exception(error.message ?? 'SSTP connection failed');
    }
  }

  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
    } on PlatformException {
      // Ignore native disconnect errors for now.
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
