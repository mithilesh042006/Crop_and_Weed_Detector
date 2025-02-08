// api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; // Change if needed

  // ✅ User Login
  static Future<bool> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/user_login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("username", username);
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

  // ✅ User Registration
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

  // ✅ Fetch Tips
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

  // ✅ Fetch Diseases
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

  // ✅ Fetch News
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

  // ✅ Clear local storage (Logout)
  static Future<void> clearLocalStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception("Failed to clear local storage: $e");
    }
  }

  // ✅ Check login status
  static Future<bool> isUserLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Get current username
  static Future<String?> getCurrentUsername() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('username');
    } catch (e) {
      return null;
    }
  }
}