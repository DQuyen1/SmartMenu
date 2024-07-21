import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Image>> FetchDeviceDisplay(int deviceId) async {
  final url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Displays/V1/$deviceId/image';
  print('Fetching images from URL: $url');
  final response = await http.get(Uri.parse(url));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    return [Image.memory(response.bodyBytes)];
  } else {
    throw Exception('Failed to load images');
  }
}
