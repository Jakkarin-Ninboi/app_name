import 'dart:convert';
import 'package:http/http.dart' as http;
import 'air_quality.dart';
class ApiService {
  final String token = "11cd6dea26cef3046ccf9effaead0c0271ad49ae";
  Future<AirQuality> fetchAirQuality(String city) async {
    final url = "https://api.waqi.info/feed/$city/?token=$token";
    print("🔗 Fetching: $url"); // debug URL
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(" API: $json"); // debug JSON
      if (json['status'] == 'ok') {
        return AirQuality.fromJson(json);
      } else {
        throw Exception("API error: ${json['data'].toString()}");
      }
    } else {
      throw Exception("HTTP error: ${response.statusCode}");
    }
  }
}
