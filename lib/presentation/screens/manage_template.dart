import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/template.dart';
import 'package:smart_menu/repository/template_repository.dart';

class TemplateListScreen extends StatefulWidget {
  final int brandId;

  const TemplateListScreen({Key? key, required this.brandId}) : super(key: key);

  @override
  _TemplateListScreenState createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  final TemplateRepository _templateRepository = TemplateRepository();
  late Future<List<Template>> templates;

  @override
  void initState() {
    templates = fetchData();
    super.initState();
    HttpOverrides.global = _DevHttpOverrides();
  }

  Future<List<Template>> fetchData() async {
    try {
      return await _templateRepository.getAll(widget.brandId);
    } catch (error) {
      log('Error fetching templates: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Of Templates'),
      ),
      body: FutureBuilder<List<Template>>(
        future: templates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No templates found'));
          } else {
            final templates = snapshot.data!;
            return ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return ListTile(
                  title: Text(template.templateName),
                  subtitle: Text(template.templateDescription),
                  leading: Image.network(
                    template.templateImgPath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {},
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
