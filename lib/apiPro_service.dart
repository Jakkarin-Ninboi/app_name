// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ## สำคัญ! แก้ไข URL ตรงนี้ ##
  static const String _baseUrl = 'http://localhost:3000/products';

  // ดึงข้อมูลสินค้าทั้งหมด (GET)
  static Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  // เพิ่มสินค้า (POST)
  static Future<void> createProduct(Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(product),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create product.');
    }
  }

  // แก้ไขสินค้า (PUT)
  static Future<void> updateProduct(String id, Map<String, dynamic> product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(product),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product.');
    }
  }

  // ลบสินค้า (DELETE)
  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product.');
    }
  }
}
