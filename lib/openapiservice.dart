import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jarvis/api_key.dart';

class OpenAiService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromtAPI(String prompt) async {
    try {
      final res = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $OPENAI_API_KEY"
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "system",
                "content":
                    "Does this message want to generate and AI Picture, image, art or anything similiar? $prompt. Simply answer with a yes or no",
              }
            ]
          }));
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)["choices"][0]["message"]["content"];
        content.trim();
        print(content);
        switch (content) {
          case 'yes':
          case 'YES':
          case 'Yes':
          case 'yes.':
          case 'Yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGptAPI(prompt);
            return res;
        }
      }
      return "Either the Api is Exhausted  or An Error Occured";
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
      return e.toString();
    }
  }

  Future<String> chatGptAPI(String prompt) async {
    messages.add(
      {"role": "user", "content": prompt},
    );
    try {
      final res = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $OPENAI_API_KEY"
          },
          body: jsonEncode({"model": "gpt-3.5-turbo", "messages": messages}));
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)["choices"][0]["message"]["content"];
        content.trim();
        messages.add({
          "role": "assistant",
          "content": content,
        });
        return content;
      }
      return "Either the Api is Exhausted  or An Error Occured";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add(
      {"role": "user", "content": prompt},
    );
    try {
      final res = await http.post(
          Uri.parse("https://api.openai.com/v1/images/generations"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $OPENAI_API_KEY"
          },
          body: jsonEncode({"prompt": prompt}));
      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)["data"][0]["url"];
        imageUrl.trim();
        messages.add({
          "role": "assistant",
          "content": imageUrl,
        });
        return imageUrl;
      }
      return "Either the Api is Exhausted  or An Error Occured";
    } catch (e) {
      SnackBar(content: Text(e.toString()));
      return e.toString();
    }
  }
}
