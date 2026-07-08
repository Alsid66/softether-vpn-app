import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softether_vpn_app/models/vpn_profile.dart';
import 'package:softether_vpn_app/services/sstp_vpn_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('softether_vpn_app/sstp');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('sends the transport and hub name for SSL profiles', () async {
    final payloads = <Map<String, dynamic>>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      payloads.add(Map<String, dynamic>.from(call.arguments as Map));
      return true;
    });

    final service = SstpVpnService();
    final profile = VpnProfile(
      id: 'profile-1',
      name: 'Office VPN',
      serverAddress: 'vpn.example.com',
      port: 443,
      username: 'user',
      password: 'pass',
      hubName: 'default',
      protocol: 'SSL',
    );

    await service.connect(profile);

    expect(payloads.first['transport'], 'SSL');
    expect(payloads.first['hubName'], 'default');
  });

  test('requires a hub name for SoftEther profiles', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      return true;
    });

    final service = SstpVpnService();
    final profile = VpnProfile(
      id: 'profile-2',
      name: 'Office VPN',
      serverAddress: 'vpn.example.com',
      port: 443,
      username: 'user',
      password: 'pass',
      hubName: '',
      protocol: 'SSTP',
    );

    expect(service.connect(profile), throwsA(isA<Exception>()));
  });
}
