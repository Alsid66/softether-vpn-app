import 'dart:convert';

class VpnProfile {
  final String id;
  final String name;
  final String serverAddress;
  final int port;
  final String username;
  final String password;
  final String hubName;
  final String protocol; // 'SSTP' or 'SSL'
  final bool useCertificate;
  final String sni;
  final String dns;
  final String? ovpnConfig; // Reserved for future extensions
  final DateTime createdAt;

  VpnProfile({
    required this.id,
    required this.name,
    required this.serverAddress,
    required this.port,
    required this.username,
    required this.password,
    required this.hubName,
    required this.protocol,
    this.useCertificate = false,
    this.sni = '',
    this.dns = '',
    this.ovpnConfig,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert profile to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serverAddress': serverAddress,
      'port': port,
      'username': username,
      'password': password,
      'hubName': hubName,
      'protocol': protocol,
      'useCertificate': useCertificate,
      'sni': sni,
      'dns': dns,
      'ovpnConfig': ovpnConfig,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create profile from JSON Map
  factory VpnProfile.fromJson(Map<String, dynamic> json) {
    return VpnProfile(
      id: json['id'],
      name: json['name'],
      serverAddress: json['serverAddress'],
      port: json['port'] is int ? json['port'] : int.parse(json['port'].toString()),
      username: json['username'],
      password: json['password'],
      hubName: json['hubName'] ?? '',
      protocol: json['protocol'] ?? 'SSTP',
      useCertificate: json['useCertificate'] ?? false,
      sni: json['sni'] ?? '',
      dns: json['dns'] ?? '',
      ovpnConfig: json['ovpnConfig'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert to String for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  List<String> validationErrors() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Profile name is required');
    }

    if (serverAddress.trim().isEmpty) {
      errors.add('Server address is required');
    }

    if (port < 1 || port > 65535) {
      errors.add('Port must be between 1 and 65535');
    }

    if (username.trim().isEmpty) {
      errors.add('Username is required');
    }

    if (password.trim().isEmpty) {
      errors.add('Password is required');
    }

    return errors;
  }

  // Create from JSON String
  factory VpnProfile.fromJsonString(String jsonString) {
    return VpnProfile.fromJson(jsonDecode(jsonString));
  }

  // Copy with modifications
  VpnProfile copyWith({
    String? id,
    String? name,
    String? serverAddress,
    int? port,
    String? username,
    String? password,
    String? hubName,
    String? protocol,
    bool? useCertificate,
    String? sni,
    String? dns,
    String? ovpnConfig,
    DateTime? createdAt,
  }) {
    return VpnProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      hubName: hubName ?? this.hubName,
      protocol: protocol ?? this.protocol,
      useCertificate: useCertificate ?? this.useCertificate,
      sni: sni ?? this.sni,
      dns: dns ?? this.dns,
      ovpnConfig: ovpnConfig ?? this.ovpnConfig,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'VpnProfile(name: $name, protocol: $protocol, server: $serverAddress:$port)';
  }
}
