import 'package:flutter_test/flutter_test.dart';
import 'package:softether_vpn_app/models/vpn_profile.dart';

void main() {
  test('serializes and restores a VPN profile correctly', () {
    final profile = VpnProfile(
      id: '1',
      name: 'Office SSTP',
      serverAddress: 'vpn.example.com',
      port: 443,
      username: 'user',
      password: 'pass',
      hubName: 'default',
      protocol: 'SSTP',
    );

    final json = profile.toJson();
    final restored = VpnProfile.fromJson(json);

    expect(restored.id, profile.id);
    expect(restored.name, profile.name);
    expect(restored.serverAddress, profile.serverAddress);
    expect(restored.port, profile.port);
    expect(restored.protocol, 'SSTP');
  });
}
