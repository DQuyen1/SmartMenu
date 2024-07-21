import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Image>> fetchImages(int displayId) async {
  final url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Displays/V2/$displayId/image';
  print('Fetching images from URL: $url'); // Log the URL
  final response = await http.get(Uri.parse(url));
  print('Response status: ${response.statusCode}'); // Log the status code
  print('Response body: ${response.body}'); // Log the response body

  if (response.statusCode == 200) {
    return [Image.memory(response.bodyBytes)];
  } else {
    throw Exception('Failed to load images');
  }
}
