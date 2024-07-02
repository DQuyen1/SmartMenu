class Template {
  final int templateId;
  final int brandId;
  final String templateName;
  final String templateDescription;
  final int templateWidth;
  final int templateHeight;
  final String templateImgPath;
  final List<dynamic>? layers; // Adjust type according to actual data type
  final bool isDeleted;

  Template({
    required this.templateId,
    required this.brandId,
    required this.templateName,
    required this.templateDescription,
    required this.templateWidth,
    required this.templateHeight,
    required this.templateImgPath,
    required this.layers,
    required this.isDeleted,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      templateId: json['templateId'],
      brandId: json['brandId'],
      templateName: json['templateName'],
      templateDescription: json['templateDescription'],
      templateWidth: json['templateWidth'],
      templateHeight: json['templateHeight'],
      templateImgPath: json['templateImgPath'],
      layers: json['layers'], // Adjust type according to actual data type
      isDeleted: json['isDeleted'],
    );
  }
}
