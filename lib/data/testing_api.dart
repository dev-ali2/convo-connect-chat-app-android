import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class TestingApi extends StatefulWidget {
  const TestingApi({super.key});

  @override
  State<TestingApi> createState() => _TestingApiState();
}

class _TestingApiState extends State<TestingApi> {
  Future<void> testApi() async {
    log('got here');
    final response = await http.post(
        Uri.parse(
            'https://deep-translate1.p.rapidapi.com/language/translate/v2'),
        headers: {
          'content-type': 'application/json',
          'X-RapidAPI-Key':
              '146cde074bmsh3382e3cfda4d1c8p1ae10ajsn0add90010790',
          'X-RapidAPI-Host': 'deep-translate1.p.rapidapi.com'
        },
        body:
            json.encode({'q': 'How are you?', 'source': 'en', 'target': 'ar'}));
    final data = await json.decode(response.body);
    final data2 = data['data']['translations']['translatedText'];
    log(data2.toString());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: testApi,
          child: Text('Test api'),
        ),
      ),
    );
  }
}
