import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/template.dart';
import 'package:smart_menu/presentation/screens/template_detail.dart';
import 'package:smart_menu/repository/template_repository.dart';

class TemplateListScreen extends StatefulWidget {
  final int brandId;

  const TemplateListScreen({Key? key, required this.brandId}) : super(key: key);

  @override
  _TemplateListScreenState createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  final TemplateRepository _templateRepository = TemplateRepository();
  late Future<List<Template>> _futureTemplates;

  String _searchQuery = '';
  String _sortOption = 'newest';

  @override
  void initState() {
    _fetchTemplates();
    super.initState();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void _fetchTemplates() async {
    setState(() {
      _futureTemplates =
          _templateRepository.getAll(widget.brandId).then((templates) {
        templates = templates
            .where((template) =>
                template.templateImgPath != null &&
                template.templateImgPath!.isNotEmpty)
            .toList();

        switch (_sortOption) {
          case 'newest':
            templates.sort((a, b) => b.templateId.compareTo(a.templateId));
            break;
          case 'oldest':
            templates.sort((a, b) => a.templateId.compareTo(b.templateId));
            break;
          case 'name_asc':
            templates.sort((a, b) => (a.templateName ?? '')
                .toLowerCase()
                .compareTo((b.templateName ?? '').toLowerCase()));
            break;
          case 'name_desc':
            templates.sort((a, b) => (b.templateName ?? '')
                .toLowerCase()
                .compareTo((a.templateName ?? '').toLowerCase()));
            break;
          default:
            break;
        }
        if (_searchQuery.isNotEmpty) {
          templates = templates
              .where((template) =>
                  template.templateName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false)
              .toList();
        }
        return templates;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: AppBar(
              title: const Text(
                'List of Templates',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.green[100],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            _buildSearchUI(),
            FutureBuilder<List<Template>>(
                future: _futureTemplates,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No templates found'));
                  } else {
                    final templates = snapshot.data!;
                    return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 3 / 1,
                        ),
                        itemCount: templates.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TemplateDetail(
                                      templateId: template.templateId),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ListTile(
                                    title: Text(
                                      template.templateName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      template.templateDescription,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    leading: Image.network(
                                      template.templateImgPath ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }
                }),
          ]),
        ));
  }

  Widget _buildSearchUI() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(right: 16),
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search templates...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _fetchTemplates();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _sortOption,
                  onChanged: (newValue) {
                    setState(() {
                      _sortOption = newValue!;
                      _fetchTemplates();
                    });
                  },
                  items: <String>['newest', 'oldest', 'name_asc', 'name_desc']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_getSortOptionLabel(value)),
                    );
                  }).toList(),
                  hint: const Text('Sort by'),
                  isExpanded: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Filter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSortOptionLabel(String sortOption) {
    switch (sortOption) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      case 'name_asc':
        return 'Name: A-Z';
      case 'name_desc':
        return 'Name: Z-A';
      default:
        return 'Sort by';
    }
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
