import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/admin/admin_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DistributeDonation extends StatefulWidget {
  const DistributeDonation(
      {super.key,
      required this.id,
      required this.title,
      required this.total,
      required this.theme});

  final String id;
  final String title;
  final int total;
  final bool theme;

  @override
  State<DistributeDonation> createState() => _DistributeDonationState();
}

class _DistributeDonationState extends State<DistributeDonation> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController? titleController;
  TextEditingController? amountController;
  TextEditingController? descriptionController;
  final double vert = 8.0;
  final double hort = 16.0;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.title);
    amountController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController!.dispose();
    amountController!.dispose();
    descriptionController!.dispose();

    super.dispose();
  }

  Future<DocumentReference<Object?>> saveExpenditureInfo() async {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection("expenditures");
    return collRef.add({
      "category": titleController!.text,
      "amount": amountController!.text,
      "reason": descriptionController!.text,
      "timestamp": Timestamp.now()
    });
  }

  Future<void> updateCampaignAmountSpent(int amount) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("campaigns").doc(widget.id);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
      int newTotalAmountSpent = data['totalSpent'] + amount;
      transaction
          .update(documentReference, {'totalSpent': newTotalAmountSpent});
    });
  }

  Future<void> updateGeneralTotal(int amount) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("totals").doc("total_donations");

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;

      int newTotalSpent = data['totalSpent'] + amount;
      int newJointTotal = data['jointTotal'] - amount;

      transaction.update(documentReference,
          {'totalSpent': newTotalSpent, 'jointTotal': newJointTotal});
    });
  }

  Future<void> updateGeneralAmountSpent(int amount) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("totals").doc("total_donations");

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;

      if (widget.title == 'Fees') {
        int newFeesTotal = data['feesTotal'] - amount;
        int newGeneralTotal = data['generalTotal'] - amount;
        int newJointTotal = data['jointTotal'] - amount;
        int newDocTotalSpent = data['totalSpent'] + amount;
        transaction.update(documentReference, {
          'feesTotal': newFeesTotal,
          'generalTotal': newGeneralTotal,
          'jointTotal': newJointTotal,
          'totalSpent': newDocTotalSpent,
        });
      }
      if (widget.title == 'Upkeep') {
        int newUpkeepTotal = data['upkeepTotal'] - amount;
        int newGeneralTotal = data['generalTotal'] - amount;
        int newJointTotal = data['jointTotal'] - amount;
        int newDocTotalSpent = data['totalSpent'] + amount;
        transaction.update(documentReference, {
          'upkeepTotal': newUpkeepTotal,
          'generalTotal': newGeneralTotal,
          'jointTotal': newJointTotal,
          'totalSpent': newDocTotalSpent
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation Distribution',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: widget.theme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Distribute Donation'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: vert, horizontal: hort),
                        child: TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            labelText: 'Campaign name or category',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: vert, horizontal: hort),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Amount cannot be empty';
                            } else {
                              return null;
                            }
                          }),
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            labelText: 'Amount to spent',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: vert, horizontal: hort),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Description cannot be empty';
                            } else {
                              return null;
                            }
                          }),
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            labelText: 'How are you spending the donation',
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: vert, horizontal: hort),
                          child: ElevatedButton(
                            onPressed: (() {
                              if (_formKey.currentState!.validate()) {
                                if (int.tryParse(amountController!.text)! >
                                    widget.total) {
                                  showDialog(
                                      context: context,
                                      builder: ((context) {
                                        return AlertDialog(
                                          content: SizedBox(
                                            height: 120,
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  const Text(
                                                    'Request Denied! Amount entered is higher than funds available!',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  TextButton(
                                                      onPressed: (() =>
                                                          Navigator.pop(
                                                              context)),
                                                      child: const Text('OK'))
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        if (widget.title != 'Fees' &&
                                            widget.title != 'Upkeep') {
                                          saveExpenditureInfo()
                                              .then((value) =>
                                                  updateCampaignAmountSpent(
                                                      int.tryParse(
                                                          amountController!
                                                              .text)!))
                                              .then((value) => updateGeneralTotal(
                                                  int.tryParse(
                                                      amountController!.text)!))
                                              .then((value) => Navigator.of(context)
                                                  .push(CupertinoPageRoute(
                                                      builder: (context) =>
                                                          AdminHome(theme: widget.theme))));
                                        }
                                        if (widget.title == 'Fees' ||
                                            widget.title == 'Upkeep') {
                                          updateGeneralAmountSpent(int.tryParse(
                                                  amountController!.text)!)
                                              .then((value) => Navigator.of(
                                                      context)
                                                  .push(CupertinoPageRoute(
                                                      builder: (context) =>
                                                          AdminHome(
                                                              theme: widget
                                                                  .theme))));
                                        }
                                        return const AlertDialog(
                                          content: SizedBox.square(
                                            dimension: 70,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        );
                                      },
                                      barrierDismissible: false);
                                }
                              }
                            }),
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(160, 45)),
                            child: const Text('Submit'),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
