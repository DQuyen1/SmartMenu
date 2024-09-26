import 'package:flutter/material.dart';
import 'package:smart_menu/models/template.dart';
import 'package:smart_menu/repository/template_repository.dart';

class TemplateFetchingDebug extends StatefulWidget {
  final int brandId;

  const TemplateFetchingDebug({Key? key, required this.brandId})
      : super(key: key);

  @override
  _TemplateFetchingDebugState createState() => _TemplateFetchingDebugState();
}

class _TemplateFetchingDebugState extends State<TemplateFetchingDebug> {
  final TemplateRepository _templateRepository = TemplateRepository();
  List<Template>? _templateList;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    try {
      List<Template> allTemplates =
          await _templateRepository.getAll(widget.brandId);

      setState(() {
        _debugInfo += 'All templates count: ${allTemplates.length}\n';
      });

      List<Template> filteredTemplates = allTemplates
          .where((template) =>
              template.templateImgPath != null &&
              template.templateImgPath!.isNotEmpty)
          .toList();

      setState(() {
        _templateList = filteredTemplates;
        _debugInfo += 'Filtered templates count: ${filteredTemplates.length}\n';

        for (var template in filteredTemplates) {
          _debugInfo +=
              'Template ID: ${template.templateId}, Name: ${template.templateName}, ImagePath: ${template.templateImgPath}\n';
        }
      });
    } catch (e) {
      setState(() {
        _debugInfo += 'Error fetching templates: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Template Fetching Debug')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Debug Information:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(_debugInfo),
              SizedBox(height: 16),
              Text('Filtered Templates:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _templateList == null
                  ? CircularProgressIndicator()
                  : Column(
                      children: _templateList!
                          .map((template) => ListTile(
                                title: Text(template.templateName),
                                subtitle: Text('ID: ${template.templateId}'),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
