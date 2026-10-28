import 'dart:convert';

import 'package:http/http.dart' as http;

class RatesRepo {
  Future<Map<String, double>> fetchRates() async {
    final response = await http
        .get(
          Uri.parse(
            'https://cdn.jsdelivr.net/gh/NemesisX1/currency-api@main/v1/currencies/usd.json',
          ),
          headers: {'Authorization': 'Bearer API KEY'},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List;
    if (data.isEmpty) {
      throw Exception('No rates returned');
    }

    final rate = (data[0]['rate'] as num).toDouble();
    return {'USD': rate};
  }
}
