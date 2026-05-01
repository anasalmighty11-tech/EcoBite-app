import 'package:dio/dio.dart';

class UserProfile {
  final String name;
  final String email;
  final String location;
  final int postsCount;
  final int sharedCount;

  UserProfile({
    required this.name, 
    required this.email, 
    required this.location, 
    required this.postsCount, 
    required this.sharedCount
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['username'] ?? "User Name",
      email: json['email'] ?? "user@example.com",
      location: json['location'] ?? "Sétif, Algeria",
      postsCount: json['postsCount'] ?? 0,
      sharedCount: json['sharedCount'] ?? 0,
    );
  }
}

class UserService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080/api/users"));

  // Fetch Profile Data
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _dio.get("/$userId");
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  // Logout Logic
  Future<void> logout() async {
    // In a real app, you'd clear your JWT token from secure storage here
    print("User logged out");
  }
}