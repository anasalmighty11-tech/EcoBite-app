import 'dart:io';
import 'package:dio/dio.dart';

class FoodService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080/api/food",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 1. Create a New Food Post (With Image)
  Future<Response?> uploadFood({
    required String title,
    required String description,
    required String category,
    required String quantity,
    required File imageFile,
    required String userId,
  }) async {
    try {
      // For images, we must use FormData
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "title": title,
        "description": description,
        "category": category,
        "quantity": quantity,
        "userId": userId,
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      return await _dio.post("/add", data: formData);
    } on DioException catch (e) {
      print("Upload Error: ${e.message}");
      // MOCK SUCCESS: Simulating successful upload for UI testing
      return Response(
        requestOptions: RequestOptions(path: "/add"),
        data: {"status": "success", "message": "Food posted (Simulated)"},
        statusCode: 200,
      );
    }
  }

  // 2. Get All Food Offers (For the Home Screen)
  Future<List<dynamic>> getAllOffers() async {
    try {
      final response = await _dio.get("/all");
      return response.data; // Returns list of food items
    } catch (e) {
      print("Fetch Error: $e");
      return []; // Return empty list to trigger the fallback in the UI
    }
  }

  // 3. Get Food by Category
  Future<List<dynamic>> getByCategory(String category) async {
    try {
      final response = await _dio.get("/category/$category");
      return response.data;
    } catch (e) {
      return [];
    }
  }

  // 4. Delete a Post (For the Profile Page / My Posts)
  Future<bool> deleteFood(String foodId) async {
    try {
      final response = await _dio.delete("/delete/$foodId");
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}