import 'package:shared_preferences/shared_preferences.dart';
import '../models/vpn_profile.dart';

class StorageService {
  static const String _keyProfiles = 'vpn_profiles';
  static const String _keyLastConnected = 'last_connected_profile_id';

  // Load all profiles from storage
  Future<List<VpnProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? profilesJson = prefs.getStringList(_keyProfiles);
    
    if (profilesJson == null) {
      return [];
    }

    try {
      return profilesJson
          .map((jsonStr) => VpnProfile.fromJsonString(jsonStr))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error loading profiles: $e');
      return [];
    }
  }

  // Save a profile (or update existing)
  Future<void> saveProfile(VpnProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await loadProfiles();
    
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }

    final List<String> profilesJson =
        profiles.map((p) => p.toJsonString()).toList();
    await prefs.setStringList(_keyProfiles, profilesJson);
  }

  // Delete a profile by ID
  Future<void> deleteProfile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await loadProfiles();
    
    profiles.removeWhere((p) => p.id == id);
    
    final List<String> profilesJson =
        profiles.map((p) => p.toJsonString()).toList();
    await prefs.setStringList(_keyProfiles, profilesJson);

    // If deleted last connected, clear it
    final lastId = prefs.getString(_keyLastConnected);
    if (lastId == id) {
      await prefs.remove(_keyLastConnected);
    }
  }

  // Save last connected profile ID
  Future<void> saveLastConnectedProfile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastConnected, id);
  }

  // Get last connected profile ID
  Future<String?> getLastConnectedProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastConnected);
  }
}
