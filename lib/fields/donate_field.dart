import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/donation.dart';
import 'package:donations_app/home.dart';
import 'package:donations_app/payment_verification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

class DonationField extends StatefulWidget {
  const DonationField({
    Key? key,
    required this.category,
    required this.theme,
  }) : super(key: key);

  final String category;
  final bool theme;

  @override
  State<DonationField> createState() => _DonationFieldState();
}

class _DonationFieldState extends State<DonationField> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String merchantRequestID = '';

  @override
  void initState() {
    super.initState();

    MpesaFlutterPlugin.setConsumerSecret("czl5VN5glTam9ryZ");
    MpesaFlutterPlugin.setConsumerKey("1G3DYo9jhGBK5UyqKsMt3Di1txkd9NwT");
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();

    super.dispose();
  }

  Future saveDonation() async {
    CollectionReference donations =
        FirebaseFirestore.instance.collection('donations');
    return donations.add({
      'name': nameController.text,
      'phoneNo': phoneController.text,
      'amount': int.tryParse(amountController.text),
      'category': widget.category,
      'timestamp': Timestamp.now(),
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
        // ignore: use_build_context_synchronously
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

  Future<void> donateByLipaNaMpesa() async {
    dynamic transactionInitialization;
    double? amount = double.tryParse(amountController.text);
    try {
      transactionInitialization = await MpesaFlutterPlugin.initializeMpesaSTKPush(
          businessShortCode: '174379',
          transactionType: TransactionType.CustomerPayBillOnline,
          amount: amount!,
          partyA: phoneController.text,
          partyB: '174379',
          callBackURL: Uri(
              scheme: 'https',
              host: "fa76-105-61-143-234.eu.ngrok.io",
              path: '/mpesa'),
          accountReference: '8006090',
          phoneNumber: phoneController.text,
          baseUri: Uri(scheme: 'https', host: "sandbox.safaricom.co.ke"),
          transactionDesc: 'Donate for ${widget.category}',
          passKey:
              "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919");
      merchantRequestID = transactionInitialization['MerchantRequestID'];
      debugPrint(transactionInitialization.toString());
      return transactionInitialization;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Donation donation = Donation('', '', 0, '', '');
    return MaterialApp(
      title: 'Donations Field Page',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Thank you for your support'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  child: Image(
                    fit: BoxFit.fill,
                    height: 80,
                    width: 200,
                    image: AssetImage('assets/mpesa.jpeg'),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: Text(
                                  'Payment Details',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 16.0),
                              child: TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  labelText: 'Your name',
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 16.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length != 12) {
                                    return 'Enter valid phone no start with 254';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  labelText: 'Your phone no',
                                  prefixIcon: const Icon(Icons.call),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter valid amount';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    labelText: 'Amount to donate',
                                    prefixText: 'Ksh '),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    donation.name = nameController.text;
                                    donation.amount =
                                        int.tryParse(amountController.text)!;
                                    donation.category = widget.category;
                                    donation.date = DateTime.now()
                                        .toString()
                                        .split(' ')
                                        .first;
                                    donateByLipaNaMpesa().then((_) async {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: SizedBox(
                                                height: 120,
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Your donation request of ${amountController.text} has been accepted. And will be processed shortly.',
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator
                                                              .pushAndRemoveUntil(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              PaymentVerification(
                                                                                merchantRequestID: merchantRequestID,
                                                                                donation: donation,
                                                                                category: widget.category,
                                                                                theme: widget.theme,
                                                                              )),
                                                                  (Route<dynamic>
                                                                          route) =>
                                                                      false);
                                                        },
                                                        child: const Text(
                                                            'Proceed'),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    backgroundColor: Colors.red[600],
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width / 1.7,
                                        45)),
                                child: const Text('Donate'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextButton(
                                onPressed: (() => Navigator.of(context).push(
                                    CupertinoPageRoute(
                                        builder: (context) => TestDonation(
                                            category: widget.category,
                                            theme: widget.theme)))),
                                child: const Text("Test Donation"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          )),
        ),
      ),
    );
  }
}

class TestDonation extends StatefulWidget {
  const TestDonation({
    Key? key,
    required this.category,
    required this.theme,
  }) : super(key: key);

  final String category;
  final bool theme;

  @override
  State<TestDonation> createState() => _TestDonationState();
}

class _TestDonationState extends State<TestDonation> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();

    super.dispose();
  }

  Future saveDonation() async {
    CollectionReference donations =
        FirebaseFirestore.instance.collection('donations');
    return donations.add({
      'name': nameController.text,
      'phoneNo': phoneController.text,
      'amount': int.tryParse(amountController.text),
      'category': widget.category,
      'timestamp': Timestamp.now(),
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
        // ignore: use_build_context_synchronously
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donations Field Page',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Thank you for your support'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  child: Image(
                    fit: BoxFit.fill,
                    height: 80,
                    width: 200,
                    image: AssetImage('assets/mpesa.jpeg'),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: Text(
                                  'Payment Details',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 16.0),
                              child: TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  labelText: 'Your name',
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 16.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length != 12) {
                                    return 'Enter valid phone no start with 254';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  labelText: 'Your phone no',
                                  prefixIcon: const Icon(Icons.call),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter valid amount';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    labelText: 'Amount to donate',
                                    prefixText: 'Ksh '),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          if (widget.category == 'Fees' ||
                                              widget.category == 'Upkeep') {
                                            saveDonation()
                                                .then((value) =>
                                                    updateCategoryTotal(
                                                        int.tryParse(
                                                            amountController
                                                                .text)!))
                                                .then((value) {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(
                                                  CupertinoPageRoute(
                                                      builder: ((context) =>
                                                          HomePage(
                                                              theme: widget
                                                                  .theme))));
                                            });
                                          }
                                          if (widget.category != 'Fees' &&
                                              widget.category != 'Upkeep') {
                                            saveDonation()
                                                .then((value) =>
                                                    updateCampaignTotal(
                                                        widget.category,
                                                        int.tryParse(
                                                            amountController
                                                                .text)!))
                                                .then((value) {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(
                                                  CupertinoPageRoute(
                                                      builder: ((context) =>
                                                          HomePage(
                                                              theme: widget
                                                                  .theme))));
                                            });
                                          }
                                          return AlertDialog(
                                            content: SizedBox.square(
                                                dimension: 70,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors
                                                              .red.shade800),
                                                )),
                                          );
                                        },
                                        barrierDismissible: false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    backgroundColor: Colors.blue[800],
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width / 1.7,
                                        45)),
                                child: const Text('Donate'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          )),
        ),
      ),
    );
  }
}
