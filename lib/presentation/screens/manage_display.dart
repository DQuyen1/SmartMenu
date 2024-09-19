import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/display.dart';
import 'package:smart_menu/presentation/screens/display_detail.dart';
import 'package:smart_menu/presentation/screens/partner/display_form.dart';
import 'package:smart_menu/repository/display_repository.dart';

class DisplayListScreen extends StatefulWidget {
  final int storeId;
  final int brandId;
  const DisplayListScreen(
      {super.key, required this.storeId, required this.brandId});

  @override
  _DisplayListScreenState createState() => _DisplayListScreenState();
}

class _DisplayListScreenState extends State<DisplayListScreen> {
  late Future<List<Display>> _futureDisplays;
  final DisplayRepository _repository = DisplayRepository();
  String _searchQuery = '';

  void _fetchDisplay() {
    setState(() {
      _futureDisplays = _repository.getAll(widget.storeId).then((displays) {
        displays.sort((a, b) => b.displayId.compareTo(a.displayId));

        return displays;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDisplay();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void _navigateToDisplayForm({Display? display}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayFormScreen(
          display: display,
          storeId: widget.storeId,
          brandId: widget.brandId,
        ),
      ),
    );

    if (result == true) {
      _fetchDisplay();
    }
  }

  void _deleteDisplay(int displayId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Display',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
        content: const Text('Are you sure you want to delete this display?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _repository.deleteDisplay(displayId);
      _fetchDisplay();
      if (success) {
        _showSnackBar('Failed to delete this display', Colors.red);
      } else {
        _showSnackBar('Display deleted successfully', Colors.green);
      }
    }
  }

  Future<void> _updateActiveHour(Display display) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: display.activeHour!.toInt(),
        minute: ((display.activeHour! % 1) * 60).toInt(),
      ),
    );

    if (pickedTime != null) {
      final newActiveHour = pickedTime.hour + (pickedTime.minute / 60);
      final success =
          await _repository.updateActiveHour(display, newActiveHour);

      if (success) {
        _showSnackBar('Active hour updated successfully', Colors.green);
        _fetchDisplay();
      } else {
        _showSnackBar('Failed to update active hour', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  String formatActiveHour(double activeHour) {
    int totalSeconds = (activeHour * 3600).toInt();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<String> _getMenuName(int? menuId) async {
    if (menuId == null) return 'No menu';

    try {
      final menuName = await _repository.getMenuName(menuId);
      return menuName;
    } catch (e) {
      return 'Error fetching menu';
    }
  }

  Future<String> _getCollectionName(int? collectionId) async {
    if (collectionId == null) return 'No collection';

    try {
      final collectionName = await _repository.getCollectionName(collectionId);
      return collectionName;
    } catch (e) {
      return 'Error fetching collection';
    }
  }

  Future<String> _getDeviceName(int? storeDeviceId) async {
    if (storeDeviceId == null) return 'No device';

    try {
      final deviceName = await _repository.getDeviceName(storeDeviceId);
      return deviceName;
    } catch (e) {
      return 'Error fetching device';
    }
  }

  Future<String> _getTemplateName(int? templateId) async {
    if (templateId == null) return 'No template';

    try {
      final templateName = await _repository.getTemplateName(templateId);
      return templateName;
    } catch (e) {
      return 'Error fetching template';
    }
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
              'Displays',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
          ),
        ),
      ),
      body: FutureBuilder<List<Display>>(
        future: _futureDisplays,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No display found'));
          } else {
            final displays = snapshot.data!;
            return ListView.builder(
              itemCount: displays.length,
              itemBuilder: (context, index) {
                final display = displays[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DisplayDetailScreen(display: display),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (display.displayImgPath != null &&
                            Uri.tryParse(display.displayImgPath!)
                                    ?.hasAbsolutePath ==
                                true)
                          Image.network(
                            display.displayImgPath!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        Expanded(
                          child: ListTile(
                            title: FutureBuilder<String>(
                              future: _getDeviceName(display.storeDeviceId),
                              builder: (context, deviceNameSnapshot) {
                                if (deviceNameSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                } else if (deviceNameSnapshot.hasError) {
                                  return Text(
                                    'Error fetching device',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    '${deviceNameSnapshot.data ?? 'No device'}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                }
                              },
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // if (display.menuId != null)
                                //   FutureBuilder<String>(
                                //     future: _getMenuName(display.menuId),
                                //     builder: (context, menuSnapshot) {
                                //       if (menuSnapshot.connectionState ==
                                //           ConnectionState.waiting) {
                                //         return const Text(
                                //           'Loading...',
                                //           style: TextStyle(
                                //             fontSize: 16,
                                //             color: Colors.grey,
                                //           ),
                                //         );
                                //       } else if (menuSnapshot.hasError) {
                                //         return Text(
                                //           'Error fetching menu',
                                //           style: const TextStyle(
                                //             fontSize: 16,
                                //             color: Colors.grey,
                                //           ),
                                //         );
                                //       } else {
                                //         return Text(
                                //           'Menu: ${menuSnapshot.data ?? 'No menu'}',
                                //           style: const TextStyle(
                                //             fontSize: 16,
                                //             color: Colors.grey,
                                //           ),
                                //         );
                                //       }
                                //     },
                                //   ),
                                // if (display.collectionId != null)
                                //   FutureBuilder<String>(
                                //     future: _getCollectionName(
                                //         display.collectionId),
                                //     builder: (context, collectionSnapshot) {
                                //       if (collectionSnapshot.connectionState ==
                                //           ConnectionState.waiting) {
                                //         return const Text(
                                //           'Loading...',
                                //           style: TextStyle(
                                //             fontSize: 16,
                                //             color: Colors.grey,
                                //           ),
                                //         );
                                //       } else if (collectionSnapshot.hasError) {
                                //         return Text(
                                //           'Error fetching collection',
                                //           style: const TextStyle(
                                //             fontSize: 16,
                                //             color: Colors.grey,
                                //           ),
                                //         );
                                //       } else {
                                //         return Text(
                                //           'Collection: ${collectionSnapshot.data ?? 'No collection'}',
                                //           style: const TextStyle(
                                //             fontSize: 16,
                                //             color: Colors.grey,
                                //           ),
                                //         );
                                //       }
                                //     },
                                //   ),
                                if (display.templateId != null)
                                  FutureBuilder<String>(
                                    future:
                                        _getTemplateName(display.templateId),
                                    builder: (context, templateSnapshot) {
                                      if (templateSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text(
                                          'Loading...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        );
                                      } else if (templateSnapshot.hasError) {
                                        return Text(
                                          'Error fetching template',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        );
                                      } else {
                                        return Text(
                                          'Template: ${templateSnapshot.data ?? 'No template'}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.access_time,
                                      color: Colors.orange),
                                  onPressed: () => _updateActiveHour(display),
                                ),
                                // IconButton(
                                //   icon: const Icon(Icons.edit,
                                //       color: Colors.blue),
                                //   onPressed: () =>
                                //       _navigateToDisplayForm(display: display),
                                // ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteDisplay(display.displayId),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDisplayForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
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
