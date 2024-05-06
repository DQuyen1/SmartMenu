import 'dart:developer';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlaylistScreen> {
  bool loading = true;

  final playList = [
    {
      'image': '',
      'title': 'KFC template',
      'subtitle': 'John Doe',
    }
  ];

  void toggleLoading() {
    setState(() {
      loading = !loading;
    });
    log(loading.toString());
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5), () => toggleLoading());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: Row(
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Image border
                    child: SizedBox.fromSize(
                      child:
                          // Shimmer.fromColors(
                          //       child: Image.asset('assets/images/template.png',
                          //           fit: BoxFit.cover),
                          //       baseColor: Colors.grey,
                          //       highlightColor: Colors.white),
                          //   size: Size(100, 70),
                          // ),
                          // size: Size.fromRadius(35), // Image radius
                          Image.asset('assets/images/template.png',
                              fit: BoxFit.cover),
                      size: Size(100, 70),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    loading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey,
                            highlightColor: Colors.white,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              color: Colors.white,
                              width: 100,
                              height: 10,
                            ))
                        : Text(
                            'Title',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                    SizedBox(
                      height: 25,
                    ),
                    loading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey,
                            highlightColor: Colors.white,
                            child: Container(
                              margin: EdgeInsets.only(
                                right: 20,
                              ),
                              color: Colors.white,
                              width: 100,
                              height: 10,
                            ))
                        : Text(
                            'Subtitle',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            loading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white,
                    child: Container(
                      margin: EdgeInsets.only(top: 25),
                      color: Colors.white,
                      width: 50,
                      height: 10,
                    ))
                : TextButton(
                    onPressed: () {
                      log('pressed');
                    },
                    child: Icon(
                      Icons.more_horiz,
                      color: Color.fromARGB(255, 189, 188, 188),
                      size: 30,
                    ),
                  ),
          ],
        )
      ],
    );
  }
}
