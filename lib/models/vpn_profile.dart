import 'dart:convert';

class VpnProfile {
  final String id;
  final String name;
  final String serverAddress;
  final int port;
  final String username;
  final String password;
  final String hubName;
  final String protocol; // 'SSTP' or 'OpenVPN'
  final String? ovpnConfig; // Base64 or plain text OpenVPN config
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
      ovpnConfig: json['ovpnConfig'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert to String for storage
  String toJsonString() {
    return jsonEncode(toJson());
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
      ovpnConfig: ovpnConfig ?? this.ovpnConfig,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'VpnProfile(name: $name, protocol: $protocol, server: $serverAddress:$port)';
  }
}
