// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/donation.dart';
import 'package:donations_app/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PaymentVerification extends StatefulWidget {
  const PaymentVerification(
      {Key? key,
      required this.merchantRequestID,
      required this.donation,
      required this.category,
      required this.theme})
      : super(key: key);

  final bool theme;
  final String merchantRequestID;
  final Donation donation;
  final String category;

  @override
  State<PaymentVerification> createState() => _PaymentVerificationState();
}

class _PaymentVerificationState extends State<PaymentVerification> {
  final Stream<QuerySnapshot> paymentStream =
      FirebaseFirestore.instance.collection('transaction').snapshots();

  Future save() async {
    CollectionReference donations =
        FirebaseFirestore.instance.collection('donations');
    return donations.doc(widget.donation.phoneNo.trim()).set({
      'name': widget.donation.name,
      'phoneNo': widget.donation.phoneNo,
      'amount': widget.donation.amount,
      'category': widget.category,
      'date': DateTime.now().toString().split(' ').first
    }).catchError((error) {
      debugPrint('Error Occurred $error');
    });
  }

  Future<void> updateCategoryTotal(int amount) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('totals').doc('total_donations');
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);

      Map<String, dynamic> doc = snapshot.data()! as Map<String, dynamic>;

      int newFeesValue = doc['feesTotal'] + amount;
      int newUpkeepValue = doc['upkeepTotal'] + amount;
      int jointNewValue = doc['jointTotal'] + amount;
      int newGeneralValue = doc['generalTotal'] + amount;

      if (widget.category == 'Fees') {
        transaction.update(documentReference, {
          'feesTotal': newFeesValue,
          'jointTotal': jointNewValue,
          'generalTotal': newGeneralValue
        });
      }
      if (widget.category == 'Upkeep') {
        transaction.update(documentReference, {
          'upkeepTotal': newUpkeepValue,
          'jointTotal': jointNewValue,
          'generalTotal': newGeneralValue
        });
      }
    });
  }

  Future<void> updateCampaignTotal(String campaignName, int amount) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(campaignName.trim());
    DocumentReference jointTotalReference =
        FirebaseFirestore.instance.collection('totals').doc('total_donations');
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      DocumentSnapshot jointTotalSnapshot =
          await transaction.get(jointTotalReference);
      if (!snapshot.exists || !jointTotalSnapshot.exists) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: SizedBox(
                  height: 120,
                  child: Center(
                    child: Text('An error occurred'),
                  ),
                ),
              );
            });
      }
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> jointTotalDoc =
          jointTotalSnapshot.data() as Map<String, dynamic>;

      int newTotal = doc['total'] + amount;
      transaction.update(documentReference, {'total': newTotal});

      int newJointTotal = jointTotalDoc['jointTotal'] + amount;
      transaction.update(jointTotalReference, {'jointTotal': newJointTotal});
    });
  }

  Future<void> verifyPayments(BuildContext context) async {
    var collection = FirebaseFirestore.instance.collection('transaction');
    var snapshot = await collection.doc(widget.merchantRequestID).get();
    Map<String, dynamic> doc = {};
    if (snapshot.exists) {
      doc = snapshot.data()!;
    }
    if (doc['ResultDesc'] == 'The service request is processed successfully.') {
      if (widget.category == 'Fees' || widget.category == 'Upkeep') {
        save().then((_) => updateCategoryTotal(widget.donation.amount));
      }
      if (widget.category != 'Fees' && widget.category != 'Upkeep') {
        save().then((_) =>
            updateCampaignTotal(widget.category, widget.donation.amount));
      }
      Navigator.of(context).pushAndRemoveUntil(
          DonationsApp.route(PaymentSuccessPage(
            amount: doc['amount'],
            theme: widget.theme,
          )),
          (Route<dynamic> route) => false);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SizedBox(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                        'Your donation could not be processed at the moment!'),
                    TextButton(
                        onPressed: () {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          theme: widget.theme,
                                        )));
                          });
                        },
                        child: const Text('Try Again Later'))
                  ],
                ),
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Payment Verification'),
          ),
          body: Center(
            child: ElevatedButton(
              onPressed: (() => verifyPayments(context)),
              child: const Text('Verify & Complete'),
            ),
          )),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage(
      {super.key, required this.amount, required this.theme});
  final double amount;
  final bool theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 80.0, horizontal: 16.0),
                child: CircularPercentIndicator(
                  radius: 75,
                  animationDuration: 2000,
                  lineWidth: 10,
                  progressColor: Colors.green,
                  animation: true,
                  percent: 1.0,
                  center: const Icon(
                    Icons.done,
                    size: 70,
                    color: Colors.indigo,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  child: Container(
                      padding: const EdgeInsets.only(
                        bottom: 5,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                          width: 1.0,
                        )),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Text(
                          'CASH DONATED',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 27,
                              color: Colors.green),
                        ),
                      ))),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                child: Text(
                  'KES $amount',
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w400),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                  'Your donation has been received, please wait for M-pesa confirmation message. Thank you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: (() => Navigator.of(context).pushAndRemoveUntil(
                      DonationsApp.route(HomePage(
                        theme: theme,
                      )),
                      (Route<dynamic> route) => false)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize:
                          Size(MediaQuery.of(context).size.width / 1.2, 45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  child: const Text(
                    'OKAY WELCOME',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
