import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/admin/admin_home.dart';
import 'package:donations_app/admin/campaign/campaign.dart';
import 'package:donations_app/app.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key, required this.campaign, required this.theme})
      : super(key: key);

  final bool theme;
  final Campaign campaign;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController? titleController;
  TextEditingController? campaignDescription;
  TextEditingController? targetAmountController;
  TextEditingController? daysController;
  TextEditingController? imageController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.campaign.title);
    campaignDescription =
        TextEditingController(text: widget.campaign.description);
    targetAmountController =
        TextEditingController(text: widget.campaign.targetAmount.toString());
    daysController =
        TextEditingController(text: widget.campaign.days.toString());
    imageController = TextEditingController(text: widget.campaign.imageUrl);
  }

  @override
  void dispose() {
    titleController!.dispose();
    campaignDescription!.dispose();
    targetAmountController!.dispose();
    daysController!.dispose();

    super.dispose();
  }

  Future<void> pickCampaignImage(String title) async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 75);

    String imgName = title.split(' ').toString().trim().toLowerCase();
    Reference ref = FirebaseStorage.instance.ref().child('$imgName.jpg');

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageController!.text = value;
      });
    });
  }

  Future<void> updateCampaign() {
//add snapshot.get();;;
    DocumentReference olddocumentReference = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(widget.campaign.title.trim());
    DocumentReference newdocumentReference = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(titleController!.text.trim());
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      widget.campaign.title = titleController!.text;
      widget.campaign.description = campaignDescription!.text;
      widget.campaign.targetAmount =
          int.tryParse(targetAmountController!.text)!;
      widget.campaign.days = int.tryParse(daysController!.text)!;
      widget.campaign.imageUrl = imageController!.text;

      transaction.delete(olddocumentReference);

      transaction.set(newdocumentReference, {
        'title': titleController!.text,
        'description': campaignDescription!.text,
        'targetAmount': int.tryParse(targetAmountController!.text),
        'days': int.tryParse(daysController!.text),
        'imageUrl': imageController!.text,
        'total': widget.campaign.total,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: const [
              Text('Edit Campaign'),
              Icon(Icons.edit),
            ],
          ),
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
              height: MediaQuery.of(context).size.height / 1.4,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: Text(
                          widget.campaign.title,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextField(
                        controller: titleController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextField(
                        controller: campaignDescription,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextField(
                        controller: targetAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Target amount',
                            prefixIcon: Icon(Icons.attach_money_rounded)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: TextField(
                        controller: daysController,
                        decoration: const InputDecoration(
                            labelText: 'Days',
                            prefixIcon: Icon(Icons.calendar_today)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: TextField(
                        readOnly: true,
                        controller: imageController,
                        decoration: const InputDecoration(
                            labelText: 'Select an image',
                            prefixIcon: Icon(Icons.image)),
                        onTap: (() => pickCampaignImage(titleController!.text)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: (() {
                          updateCampaign()
                              .then((_) => Navigator.pushAndRemoveUntil(
                                  context,
                                  DonationsApp.route(AdminHome(
                                    theme: widget.theme,
                                  )),
                                  (Route<dynamic> route) => false));
                        }),
                        //check how to disable button
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width / 3.5, 50),
                            backgroundColor: Colors.red[600]),
                        child: const Text('Update'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
