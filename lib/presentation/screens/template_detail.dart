import 'package:flutter/material.dart';
import 'package:smart_menu/models/template.dart';
import 'package:smart_menu/repository/template_repository.dart';

class TemplateDetail extends StatefulWidget {
  final int templateId;

  const TemplateDetail({Key? key, required this.templateId}) : super(key: key);

  @override
  _TemplateDetailState createState() => _TemplateDetailState();
}

class _TemplateDetailState extends State<TemplateDetail> {
  late Future<Template> _futureTemplate;
  final TemplateRepository _templateRepository = TemplateRepository();

  @override
  void initState() {
    super.initState();
    _fetchTemplate();
  }

  void _fetchTemplate() {
    setState(() {
      _futureTemplate = _templateRepository.getTemplateById(widget.templateId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Template Detail'),
      ),
      body: FutureBuilder<Template>(
        future: _futureTemplate,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Template not found'));
          } else {
            final template = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (template.templateImgPath != null &&
                      template.templateImgPath!.isNotEmpty)
                    Image.network(
                      template.templateImgPath!,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, size: 100),
                        );
                      },
                    )
                  else
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 100),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          template.templateName,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          template.templateDescription,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Width:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${template.templateWidth}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Height:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${template.templateHeight}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
