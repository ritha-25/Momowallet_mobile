import 'dart:convert';
import 'package:http/http.dart' as http;

class RatesRepo {
  Future<Map<String, double>> fetchRates() async {
    final response = await http
        .get(Uri.parse('https://api.frankfurter.dev/v1/latest?base=RWF'))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Server error');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = data['rates'] as Map<String, dynamic>;
    return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }
}