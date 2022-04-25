import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/services.dart';

class DefaultGrabbing extends StatelessWidget {
  final Color color;
  final bool reverse;

  const DefaultGrabbing(
      {Key? key, this.color = Colors.grey, this.reverse = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // boxShadow: [
        // BoxShadow(
        //   blurRadius: 20,
        //   spreadRadius: 10,
        //   color: Colors.black.withOpacity(0.15),
        // )
        // ],
        color: Colors.blueGrey[100],
      ),
      child: Transform.rotate(
        angle: reverse ? pi : 0,
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0, -0.5),
              child: _WelcomeUser(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeUser extends StatelessWidget {
  User? currUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          child: Text(
            "Welcome back, ${currUser?.email}",
            style: const TextStyle(fontSize: 15),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
        ),
        Container(
          child: const Icon(Icons.keyboard_arrow_up),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20, left: 90),
        ),
      ],
    );
  }
}

class profileContent extends StatefulWidget {
  @override
  State<profileContent> createState() => _profileContentState();
}

class _profileContentState extends State<profileContent> {
  User? currUser = FirebaseAuth.instance.currentUser;



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          FutureBuilder(
              future: downloadAvatarImage(),
              builder:
                  (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 20),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: snapshot.data != null
                        ? NetworkImage(snapshot.data.toString())
                        : null,
                  ),
                );
              }),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 20, top: 15),
                  child: Text(
                    "${currUser?.email}",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10, right: 25),
                  child: SizedBox(
                      height: 30,
                      width: 110,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text("Change avatar",
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.custom,
                                  // allowMultiple: false,
                                  allowedExtensions: [
                                'png',
                                'jpeg',
                                'jpg',
                                'gif'
                              ]);
                          if (result != null) {
                            String? fileName = currUser?.uid;
                            String? filePath = result.files.first.path;
                            await uploadAvatarImage(filePath!, fileName!);
                            setState(() {});
                          } else {
                            const snackBar = SnackBar(
                              content: Text('No file was selected!'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
