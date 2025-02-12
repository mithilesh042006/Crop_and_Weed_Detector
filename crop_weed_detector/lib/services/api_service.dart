import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = "http://10.0.2.2:8000"; // Change if needed

  // In-memory copies of cookies (sessionid, csrftoken)
  static String? _sessionId;
  static String? _csrfToken;

  // -----------------------------------------------------
  //  Helper: Save cookies from response
  // -----------------------------------------------------
  static Future<void> _saveCookies(http.Response response) async {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null) {
      // No cookies returned
      return;
    }

    // Example header: "sessionid=abc123; Path=/; HttpOnly, csrftoken=xyz456; Path=/"
    // We'll do a very basic parse:
    final cookieParts = setCookie.split(',');
    for (var part in cookieParts) {
      part = part.trim();
      if (part.startsWith('sessionid=')) {
        _sessionId = part.split(';')[0].replaceAll('sessionid=', '');
      } else if (part.startsWith('csrftoken=')) {
        _csrfToken = part.split(';')[0].replaceAll('csrftoken=', '');
      }
    }

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (_sessionId != null) {
      await prefs.setString('sessionid', _sessionId!);
    }
    if (_csrfToken != null) {
      await prefs.setString('csrftoken', _csrfToken!);
    }
  }

  // -----------------------------------------------------
  //  Helper: Load cookies from SharedPreferences
  // -----------------------------------------------------
  static Future<void> _loadCookies() async {
    if (_sessionId == null || _csrfToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _sessionId ??= prefs.getString('sessionid');
      _csrfToken ??= prefs.getString('csrftoken');
    }
  }

  // -----------------------------------------------------
  //  Helper: Build Cookie header string
  // -----------------------------------------------------
  static Future<String> _buildCookieHeader() async {
    await _loadCookies();
    // If either is null, we just won't include it
    final cookieBuffer = <String>[];
    if (_csrfToken != null) {
      cookieBuffer.add("csrftoken=$_csrfToken");
    }
    if (_sessionId != null) {
      cookieBuffer.add("sessionid=$_sessionId");
    }

    if (cookieBuffer.isEmpty) {
      return ""; // No cookies
    } else {
      // e.g. "csrftoken=xyz123; sessionid=abc456"
      return cookieBuffer.join("; ");
    }
  }

  // -----------------------------------------------------
  //  User Login
  // -----------------------------------------------------
  static Future<bool> loginUser(String username, String password) async {
    try {
      // Prepare headers (include cookies if already stored)
      String cookieHeader = await _buildCookieHeader();
      final headers = {
        "Content-Type": "application/json",
        if (cookieHeader.isNotEmpty) "Cookie": cookieHeader,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/auth/user_login"),
        headers: headers,
        body: jsonEncode({"username": username, "password": password}),
      );

      // Save any new cookies (sessionid, csrftoken) from response
      await _saveCookies(response);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
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

  // -----------------------------------------------------
  //  User Registration
  // -----------------------------------------------------
  static Future<bool> registerUser(String username, String password) async {
    try {
      // Include cookies if any (unlikely for register, but consistent)
      String cookieHeader = await _buildCookieHeader();
      final headers = {
        "Content-Type": "application/json",
        if (cookieHeader.isNotEmpty) "Cookie": cookieHeader,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: headers,
        body: jsonEncode({"username": username, "password": password}),
      );

      // Save cookies if server sets them on register
      await _saveCookies(response);

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

  // -----------------------------------------------------
  //  Fetch Tips
  // -----------------------------------------------------
  static Future<List<dynamic>> fetchTips() async {
    try {
      // Include cookies
      String cookieHeader = await _buildCookieHeader();
      final headers = {
        if (cookieHeader.isNotEmpty) "Cookie": cookieHeader,
      };

      final response = await http.get(
        Uri.parse("$baseUrl/api/tips"),
        headers: headers,
      );

      // Save new cookies if any
      await _saveCookies(response);

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

  // -----------------------------------------------------
  //  Fetch Diseases
  // -----------------------------------------------------
  static Future<List<dynamic>> fetchDiseases() async {
    try {
      String cookieHeader = await _buildCookieHeader();
      final headers = {
        if (cookieHeader.isNotEmpty) "Cookie": cookieHeader,
      };

      final response = await http.get(
        Uri.parse("$baseUrl/api/diseases"),
        headers: headers,
      );

      await _saveCookies(response);

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

  // -----------------------------------------------------
  //  Fetch News
  // -----------------------------------------------------
  static Future<List<dynamic>> fetchNews() async {
    try {
      String cookieHeader = await _buildCookieHeader();
      final headers = {
        if (cookieHeader.isNotEmpty) "Cookie": cookieHeader,
      };

      final response = await http.get(
        Uri.parse("$baseUrl/api/news"),
        headers: headers,
      );

      await _saveCookies(response);

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

  // -----------------------------------------------------
  //  Fetch History
  // -----------------------------------------------------
  static Future<List<dynamic>> fetchHistory() async {
    try {
      // Include cookies
      String cookieHeader = await _buildCookieHeader();
      final headers = {
        if (cookieHeader.isNotEmpty) "Cookie": cookieHeader,
      };

      final response = await http.get(
        Uri.parse("$baseUrl/api/history"),
        headers: headers,
      );

      // Save new cookies if any
      await _saveCookies(response);

      if (response.statusCode == 200) {
        // /api/history typically returns a list of objects:
        // [
        //   {"image_id":..., "username":..., ...},
        //   ...
        // ]
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception("Failed to load history: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No Internet connection");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // -----------------------------------------------------
  //  Clear local storage (Logout)
  // -----------------------------------------------------
  static Future<void> clearLocalStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // Also clear in-memory
      _sessionId = null;
      _csrfToken = null;
    } catch (e) {
      throw Exception("Failed to clear local storage: $e");
    }
  }

  // -----------------------------------------------------
  //  Check login status
  // -----------------------------------------------------
  static Future<bool> isUserLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      return false;
    }
  }

  // -----------------------------------------------------
  //  Get current username
  // -----------------------------------------------------
  static Future<String?> getCurrentUsername() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('username');
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------------
  //  Upload Image (Classification or Detection)
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String model,
    required String mode,
  }) async {
    try {
      // Build the cookie header
      String cookieHeader = await _buildCookieHeader();

      // Create the multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload'),
      );

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      // Add fields
      request.fields['model'] = model;
      request.fields['mode'] = mode;

      // Add Cookie header if we have it
      if (cookieHeader.isNotEmpty) {
        request.headers['Cookie'] = cookieHeader;
      }

      // Send request
      var streamedResponse = await request.send();
      var responseData = await streamedResponse.stream.bytesToString();
      var response = http.Response(
        responseData,
        streamedResponse.statusCode ?? 500,
        headers: streamedResponse.headers,
      );

      // Parse and save any updated cookies
      await _saveCookies(response);

      // Parse the JSON
      var result = json.decode(responseData);
      if (response.statusCode == 200) {
        // e.g. {"class_name": "...", "confidence": "..."} etc.
        return result;
      } else {
        // If there's an error or redirect, handle accordingly
        throw Exception(
          result["error"] ??
              "Error uploading image. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("No Internet connection");
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }
}
