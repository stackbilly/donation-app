import 'package:donations_app/donation.dart';
import 'package:donations_app/payment_verification.dart';
import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DonationField extends StatefulWidget {
  const DonationField({Key? key, required this.category, required this.theme})
      : super(key: key);

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
    loadENV().then((_) {
      MpesaFlutterPlugin.setConsumerSecret(dotenv.get('CONSUMER_SECRET'));
      MpesaFlutterPlugin.setConsumerKey(dotenv.get('CONSUMER_KEY'));
    });
  }

  Future<void> loadENV() async {
    await dotenv.load(fileName: ".env");
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();

    super.dispose();
  }

  Future<void> donateByLipaNaMpesa() async {
    dynamic transactionInitialization;
    double? amount = double.tryParse(amountController.text);
    try {
      transactionInitialization =
          await MpesaFlutterPlugin.initializeMpesaSTKPush(
              businessShortCode: dotenv.get('BUSINESS_SHORT_CODE'),
              transactionType: TransactionType.CustomerPayBillOnline,
              amount: amount!,
              partyA: phoneController.text,
              partyB: dotenv.get('BUSINESS_SHORT_CODE'),
              callBackURL: Uri(
                  scheme: 'https', host: dotenv.env['HOST'], path: '/mpesa'),
              accountReference: nameController.text,
              phoneNumber: phoneController.text,
              baseUri: Uri(scheme: 'https', host: "sandbox.safaricom.co.ke"),
              transactionDesc: 'Donate for ${widget.category}',
              passKey: dotenv.get('ACCESS_TOKEN'));
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
