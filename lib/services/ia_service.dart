import 'dart:convert';
import 'package:http/http.dart' as http;

class IaService {
  final String apiKey = "AIzaSyCYuclPqcN7GK1f2njlcrWx13CN2Q7lHms"; 

  final String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  Future<String> generarInsight(String prompt) async {
    final url = Uri.parse("$baseUrl?key=$apiKey");

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        final texto =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

        return texto?.trim() ?? "La IA no generó texto.";
      } else {
        return "Error IA (${res.statusCode}): ${res.body}";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }
}
