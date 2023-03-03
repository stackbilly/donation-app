import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CharityApplication extends StatefulWidget {
  const CharityApplication({super.key, required this.theme});

  final bool theme;
  @override
  State<CharityApplication> createState() => _CharityApplicationState();
}

class _CharityApplicationState extends State<CharityApplication> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final CollectionReference applicationRef =
      FirebaseFirestore.instance.collection("charityapplicants");

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController letterController = TextEditingController();
  TextEditingController statementController = TextEditingController();
  TextEditingController arrearsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    statementController.text = "";
    letterController.text = "";
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    regNoController.dispose();
    phoneNumberController.dispose();
    letterController.dispose();
    statementController.dispose();
    arrearsController.dispose();

    super.dispose();
  }

  Future<void> uploadFile(String type, TextEditingController controller) async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: ['pdf']);
      String fileName = regNoController.text.trim().replaceAll("/", ".") + type;
      Reference ref =
          FirebaseStorage.instance.ref().child("$type/$fileName.pdf");
      if (result != null && result.files.isNotEmpty) {
        var file = File(result.files.single.path!);
        await ref.putFile(file);
        ref.getDownloadURL().then((value) {
          setState(() {
            controller.text = value;
          });
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<DocumentReference<Object?>> saveApplication() async {
    return applicationRef.add({
      "name": nameController.text,
      "email": emailController.text,
      "regNo": regNoController.text,
      "phoneNo": phoneNumberController.text,
      "letter": letterController.text,
      "statement": statementController.text,
      "arrears": int.tryParse(arrearsController.text)
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Charity Application",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: widget.theme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Charity Application'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: Text(
                          'Enter your details',
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextFormField(
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'name field cannot be empty';
                          } else {
                            return null;
                          }
                        }),
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Fullnames',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            prefixIcon: const Icon(Icons.person)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextFormField(
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'reg no cannot be empty';
                          } else {
                            return null;
                          }
                        }),
                        controller: regNoController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Reg No',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            prefixIcon: const Icon(Icons.numbers)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextFormField(
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'email cannot be empty';
                          } else {
                            return null;
                          }
                        }),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Institution email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextFormField(
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'phone no cannot be empty';
                          } else {
                            return null;
                          }
                        }),
                        controller: phoneNumberController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Phone No',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            prefixIcon: const Icon(Icons.call)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextFormField(
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'arrears cannot be empty';
                          } else {
                            return null;
                          }
                        }),
                        controller: arrearsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Outstanding arrears',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            prefixIcon:
                                const Icon(Icons.monetization_on_rounded)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: TextFormField(
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'You must upload your calling letter';
                          } else {
                            return null;
                          }
                        }),
                        readOnly: true,
                        controller: letterController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            labelText: 'Calling letter',
                            prefixIcon: const Icon(Icons.picture_as_pdf)),
                        onTap: (() => uploadFile("letter", letterController)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: TextFormField(
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'You must upload your fee statement';
                          } else {
                            return null;
                          }
                        }),
                        readOnly: true,
                        controller: statementController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            labelText: 'Fee statement',
                            prefixIcon: const Icon(Icons.picture_as_pdf)),
                        onTap: (() =>
                            uploadFile("statement", statementController)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: (() {
                          if (_formKey.currentState!.validate()) {
                            saveApplication().then((value) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: SizedBox.square(
                                        dimension: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Application Submitted!",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(14.0),
                                              child: TextButton(
                                                  onPressed: (() => Navigator
                                                          .of(context)
                                                      .pushAndRemoveUntil(
                                                          CupertinoPageRoute(
                                                              builder: (context) =>
                                                                  HomePage(
                                                                      theme: widget
                                                                          .theme)),
                                                          (route) => false)),
                                                  child: const Text("OK")),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  barrierDismissible: false);
                            });
                          }
                        }),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(150, 45),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            backgroundColor: Colors.red[800]),
                        child: const Text('Submit'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
