import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000"; // Change if needed

  // ✅ User Login with error handling
  static Future<bool> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/user_login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isLoggedIn", true);
        prefs.setString("username", username);
        return true;
      } else if (response.statusCode == 401) {
        print("Login failed: Invalid credentials");
        return false;
      } else {
        print("Login failed: ${response.statusCode}");
        return false;
      }
    } on SocketException {
      print("No Internet connection");
      return false;
    } catch (e) {
      print("Unexpected error: $e");
      return false;
    }
  }

  // ✅ User Registration with error handling
  static Future<bool> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Registration failed: ${response.statusCode}");
        return false;
      }
    } on SocketException {
      print("No Internet connection");
      return false;
    } catch (e) {
      print("Unexpected error: $e");
      return false;
    }
  }

  // ✅ Fetch Tips with error handling
  static Future<List<dynamic>> fetchTips() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/tips"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["tips"];
      } else {
        throw Exception("Failed to load tips: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No Internet connection");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✅ Fetch Diseases with error handling
  static Future<List<dynamic>> fetchDiseases() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/diseases"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["diseases"];
      } else {
        throw Exception("Failed to load diseases: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No Internet connection");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✅ Fetch News with error handling
  static Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/news"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["news"];
      } else {
        throw Exception("Failed to load news: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No Internet connection");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
