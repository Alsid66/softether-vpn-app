import 'package:flutter_test/flutter_test.dart';
import 'package:softether_vpn_app/models/vpn_profile.dart';

void main() {
  test('valid profile has no validation errors', () {
    final profile = VpnProfile(
      id: '1',
      name: 'Office VPN',
      serverAddress: 'vpn.example.com',
      port: 443,
      username: 'user',
      password: 'secret',
      hubName: 'default',
      protocol: 'SSTP',
    );

    expect(profile.validationErrors(), isEmpty);
  });

  test('invalid profile reports all missing required fields', () {
    final profile = VpnProfile(
      id: '2',
      name: '   ',
      serverAddress: ' ',
      port: 0,
      username: ' ',
      password: ' ',
      hubName: '',
      protocol: 'SSTP',
    );

    final errors = profile.validationErrors();

    expect(errors, contains('Profile name is required'));
    expect(errors, contains('Server address is required'));
    expect(errors, contains('Port must be between 1 and 65535'));
    expect(errors, contains('Username is required'));
    expect(errors, contains('Password is required'));
  });
}
