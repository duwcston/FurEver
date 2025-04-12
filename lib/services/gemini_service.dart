import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PetCareInfo {
  final String feedingInfo;
  final String groomingTips;

  PetCareInfo({required this.feedingInfo, required this.groomingTips});
}

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent';

  Future<PetCareInfo> generatePetCareInfo({
    required String petName,
    required String breed,
    required String sex,
    required int age,
    required double weight,
  }) async {
    try {
      final apiKey = dotenv.env['GEMINI_FLASH_API_KEY'];

      if (apiKey == null) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }

      final url = '$_baseUrl?key=$apiKey';

      final requestBody = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    '''Generate care information for a $breed dog named $petName with the following details:
                  Sex: $sex
                  Age: $age years
                  Weight: $weight kg
                  
                  1. Summary the detail for feeding recommendations according to the breed, sex, age, weight (70 - 100 words)
                  2. Summary the grooming tips according to the breed, sex, age, weight (70 - 100 words)
                  
                  Format as JSON with keys "feedingInfo" and "groomingTips".
                ''',
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        final jsonText = text.substring(jsonStart, jsonEnd);

        final careInfo = jsonDecode(jsonText);

        return PetCareInfo(
          feedingInfo: careInfo['feedingInfo'],
          groomingTips: careInfo['groomingTips'],
        );
      } else {
        throw Exception(
          'Failed to generate pet care info: ${response.statusCode}',
        );
      }
    } catch (e) {
      return PetCareInfo(
        feedingInfo:
            'Could not generate feeding information. Please try again later.',
        groomingTips:
            'Could not generate grooming tips. Please try again later.',
      );
    }
  }
}
