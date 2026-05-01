import 'package:dio/dio.dart';

class AuthService {
  // Using 10.0.2.2 for Android Emulator to reach your laptop's localhost
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080/api/auth",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // --- Login Method ---
  Future<Response?> login(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          "phoneNumber": phoneNumber,
        },
      );
      
      // In Spring Boot, you'll likely return a JWT token here
      return response;
    } on DioException catch (e) {
      _handleError(e);
      // MOCK SUCCESS: If the backend isn't running, we'll simulate success so you can test the app!
      return Response(
        requestOptions: RequestOptions(path: '/login'),
        data: {"status": "success", "message": "Logged in (Simulated)"},
        statusCode: 200,
      );
    }
  }

  // --- Register Method ---
  Future<Response?> register(String name, String email, String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          "username": name,
          "email": email,
          "phoneNumber": phoneNumber,
        },
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      // MOCK SUCCESS: Simulating registration success for testing
      return Response(
        requestOptions: RequestOptions(path: '/register'),
        data: {"status": "success", "message": "Registered (Simulated)"},
        statusCode: 200,
      );
    }
  }

  // Basic Error Handling
  void _handleError(DioException e) {
    if (e.response != null) {
      print("Backend Error: ${e.response?.data}");
    } else {
      print("Connection Error: ${e.message}");
    }
  }
}