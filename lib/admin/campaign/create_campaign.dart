import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/admin/admin_home.dart';
import 'package:donations_app/admin/campaign/campaign.dart';
import 'package:donations_app/app.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateCampaign extends StatefulWidget {
  const CreateCampaign({super.key, required this.theme});

  final bool theme;
  @override
  State<CreateCampaign> createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController campaignTitleController = TextEditingController();
  final TextEditingController campaignDescription = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  TextEditingController daysController = TextEditingController();
  TextEditingController imageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    imageController.text = "";
  }

  @override
  void dispose() {
    campaignTitleController.dispose();
    campaignDescription.dispose();
    targetAmountController.dispose();
    daysController.dispose();

    super.dispose();
  }

  Future<void> pickCampaignImage(String title) async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 75);
    String imgName = title.split('').join().toLowerCase();
    Reference ref = FirebaseStorage.instance.ref().child('$imgName.jpg');

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageController.text = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<DocumentReference<Object?>> saveCampaign() async {
      CollectionReference camapaigns =
          FirebaseFirestore.instance.collection('campaigns');
      return camapaigns.add({
        'title': campaignTitleController.text,
        'description': campaignDescription.text,
        'targetAmount': int.tryParse(targetAmountController.text),
        'days': int.tryParse(daysController.text),
        'imageUrl': imageController.text,
        'total': 0,
        'totalSpent': 0,
        'state': CampaignState.active.name,
      });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create new Campaign'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.1,
              height: MediaQuery.of(context).size.height / 1.2,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 16.0),
                          child: Text(
                            'Enter campaign details',
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'A campaign must have a title';
                            } else {
                              return null;
                            }
                          }),
                          controller: campaignTitleController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: 'Campaign title',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              prefixIcon: const Icon(Icons.title)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: TextFormField(
                          controller: campaignDescription,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: 'Campaign description',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              prefixIcon: const Icon(Icons.description)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Target amount cannot be empty';
                            } else {
                              return null;
                            }
                          }),
                          controller: targetAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Target amount',
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
                              return 'Days cannot be empty';
                            } else {
                              return null;
                            }
                          }),
                          controller: daysController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Days',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              prefixIcon: const Icon(Icons.calendar_today)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'You must upload an image';
                            } else {
                              return null;
                            }
                          }),
                          readOnly: true,
                          controller: imageController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              labelText: 'Select an image',
                              prefixIcon: const Icon(Icons.image)),
                          onTap: (() =>
                              pickCampaignImage(campaignTitleController.text)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: imageController.text == "" ||
                                  imageController.text.isEmpty
                              ? null
                              : (() {
                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          saveCampaign().then((value) =>
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      DonationsApp.route(
                                                          AdminHome(
                                                        theme: widget.theme,
                                                      )),
                                                      (Route<dynamic> route) =>
                                                          false));
                                          return const AlertDialog(
                                            content: SizedBox.square(
                                              dimension: 70,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        barrierDismissible: false);
                                  }
                                }),
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width / 3.5, 50),
                              backgroundColor: Colors.red[600]),
                          child: const Text('Create Campaign'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}
