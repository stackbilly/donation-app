import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DistributeDonation extends StatefulWidget {
  const DistributeDonation(
      {super.key, required this.category, required this.total});

  final String category;
  final int total;

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

    titleController = TextEditingController(text: widget.category);
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

  Future<void> updateAmountSpent(String campaignName, int amount) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('totals').doc('total_donations');
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      if (campaignName != 'Fees' && campaignName != 'Upkeep') {
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection('campaigns')
            .doc(campaignName.trim());
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        Map<String, dynamic> doc = snapshot.data()! as Map<String, dynamic>;
        int newTotalSpent = doc['totalSpent'] + amount;
        transaction.update(documentReference, {'totalSpent': newTotalSpent});
      }

      DocumentSnapshot totalSnapshot = await transaction.get(documentReference);
      Map<String, dynamic> totalDoc =
          totalSnapshot.data()! as Map<String, dynamic>;
      int newDocTotalSpent = totalDoc['totalSpent'] + amount;
      transaction.update(documentReference, {'totalSpent': newDocTotalSpent});

      if (campaignName == 'Fees') {
        int newFeesTotal = totalDoc['feesTotal'] - amount;
        int newGeneralTotal = totalDoc['generalTotal'] - amount;
        int newJointTotal = totalDoc['jointTotal'] - amount;
        transaction.update(documentReference, {
          'feesTotal': newFeesTotal,
          'generalTotal': newGeneralTotal,
          'jointTotal': newJointTotal
        });
      }
      if (campaignName == 'Upkeep') {
        int newUpkeepTotal = totalDoc['upkeepTotal'] - amount;
        int newGeneralTotal = totalDoc['generalTotal'] - amount;
        int newJointTotal = totalDoc['jointTotal'] - amount;
        transaction.update(documentReference, {
          'upkeepTotal': newUpkeepTotal,
          'generalTotal': newGeneralTotal,
          'jointTotal': newJointTotal
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation Distribution Page',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
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
                                  updateAmountSpent(titleController!.text,
                                      int.tryParse(amountController!.text)!);
                                  Navigator.pop(context);
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
