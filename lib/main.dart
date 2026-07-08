import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vpn_provider.dart';
import 'screens/vpn_home_page.dart';

void main() {
  runApp(const SoftEtherVpnApp());
}

class SoftEtherVpnApp extends StatelessWidget {
  const SoftEtherVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VpnProvider()..loadProfiles(),
      child: MaterialApp(
        title: 'SoftEther VPN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const VpnHomePage(),
      ),
    );
  }
}
