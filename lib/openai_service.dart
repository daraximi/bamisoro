import 'dart:convert';

import 'package:bamisoro/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];

  // Future<String> isArtPromptAPI(String prompt) async {
  //   try {
  //     var uri = 'https://api.openai.com/v1/chat/completions';
  //     final res = await http.post(Uri.parse(uri),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $openAPIKEY'
  //         },
  //         body: jsonEncode({
  //           "model": "gpt-3.5-turbo",
  //           "messages": [
  //             {
  //               'role': 'user',
  //               'content':
  //                   'Does this prompt want to generate, art, anything similar: $prompt . Simply answer with a yes or no.'
  //             }
  //           ]
  //         }));
  //     if (res.statusCode == 200) {
  //       String content =
  //           jsonDecode(res.body)['choices'][0]['message']['content'];
  //       content = content.trim();
  //       switch (content) {
  //         case 'Yes':
  //         case 'yes':
  //         case 'Yes.':
  //         case 'yes.':
  //           final res = await dallEAPI(prompt);
  //           return res;
  //         default:
  //           final res = await chatGPTAPI(prompt);
  //           return res;
  //       }
  //     } else {
  //       return 'ERROR';
  //     }
  //   } catch (e) {
  //     return 'ERROR';
  //   }
  // }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      var uri = 'https://api.openai.com/v1/chat/completions';
      final res = await http.post(Uri.parse(uri),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAPIKEY'
          },
          body: jsonEncode({"model": "gpt-4o-mini", "messages": messages}));
      //print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({'role': 'assistant', 'content': content});
        return content;
      } else {
        return 'ERROR';
      }
    } catch (e) {
      return 'ERROR';
    }
  }

  // Future<String> dallEAPI(String prompt) async {
  //   messages.add({'role': 'user', 'content': prompt});
  //   try {
  //     var uri = 'https://api.openai.com/v1/images/generations';
  //     final res = await http.post(Uri.parse(uri),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $openAPIKEY'
  //         },
  //         body: jsonEncode({
  //           "model": "dall-e-3",
  //           "prompt": prompt,
  //           "n": 1,
  //           "size": "1024x1024"
  //         }));
  //     //print(res.body);
  //     if (res.statusCode == 200) {
  //       String imageUrl =
  //           jsonDecode(res.body)['data'][0]['url'];
  //       imageUrl = imageUrl.trim();
  //       messages.add({'role': 'assistant', 'imageUrl': imageUrl});
  //       return imageUrl;
  //     } else {
  //       return 'ERROR';
  //     }
  //   } catch (e) {
  //     return 'ERROR';
  //   }
  // }
}
