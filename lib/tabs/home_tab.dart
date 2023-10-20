import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/fields/donate_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class HomePageTab extends StatefulWidget {
  const HomePageTab({super.key, required this.theme});

  final bool theme;
  @override
  State<HomePageTab> createState() => _HomePageTabState();
}

class _HomePageTabState extends State<HomePageTab> {
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();

    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint("Couldn'\t check connectivity status +$e");
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Hello,',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            child: Text(
              'With just Ksh 100, you can help a comrade in need by donating now',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: (!widget.theme) ? Colors.blueGrey[500] : Colors.white,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Choose where to donate',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 0.2,
                height: 380,
                child: Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                        child: Image(
                          fit: BoxFit.fill,
                          height: 380,
                          width: MediaQuery.of(context).size.width / 0.2,
                          image: const AssetImage('assets/food.jpg'),
                        ),
                      ),
                      const Positioned(
                        left: 10.0,
                        bottom: 90.0,
                        child: Text(
                          'Share food with a \ncomrade',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Positioned(
                        bottom: 10.0,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: ElevatedButton(
                            onPressed: (() {
                              if (connectionStatus == ConnectivityResult.wifi ||
                                  connectionStatus ==
                                      ConnectivityResult.mobile) {
                                Navigator.of(context).push(
                                    DonationsApp.bounceInRoute(DonationField(
                                        category: 'Upkeep',
                                        theme: widget.theme)));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: SizedBox(
                                          height: 100,
                                          child: Center(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                  'You need an active internet connection to proceed'),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('OK'))
                                            ],
                                          )),
                                        ),
                                      );
                                    });
                              }
                            }),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent[700],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                minimumSize: const Size(150, 50)),
                            child: const Text(
                              "Donate now",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 0.2,
              height: 380,
              child: Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0)),
                      child: Image(
                        fit: BoxFit.fill,
                        height: 380,
                        width: MediaQuery.of(context).size.width / 0.2,
                        image: const AssetImage('assets/studies.jpg'),
                      ),
                    ),
                    const Positioned(
                      bottom: 90.0,
                      left: 5.0,
                      child: Text(
                        'Help a comrade sit for \nexams',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Positioned(
                        bottom: 10.0,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: ElevatedButton(
                            onPressed: (() {
                              if (connectionStatus == ConnectivityResult.wifi ||
                                  connectionStatus ==
                                      ConnectivityResult.mobile) {
                                Navigator.of(context).push(
                                    DonationsApp.bounceInRoute(DonationField(
                                        category: 'Fees',
                                        theme: widget.theme)));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: SizedBox(
                                          height: 100,
                                          child: Center(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                  'You need an active internet connection to proceed'),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('OK'))
                                            ],
                                          )),
                                        ),
                                      );
                                    });
                              }
                            }),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent[700],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                minimumSize: const Size(150, 50)),
                            child: const Text(
                              "Donate now",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 170,
              width: MediaQuery.of(context).size.width / 0.5,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.indigo),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: Text(
                          'Invite your friends',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 19),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 16.0),
                        child: Text(
                          "and support one another in helping comrades",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 19),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: (() {
                              Share.share(
                                  'Download Charity Association app on https://www.google.com now and start supporting comrades',
                                  subject: 'Join The Movement');
                            }),
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 45),
                                backgroundColor: Colors.red[700],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            child: const Text(
                              'Invite friends',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Send money donations through',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 0.2,
                height: 230,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                        child: Image(
                          fit: BoxFit.fill,
                          height: 230,
                          width: MediaQuery.of(context).size.width / 0.4,
                          image: const AssetImage('assets/mpesa.jpeg'),
                        ),
                      ),
                      Positioned(
                        left: 75.0,
                        bottom: 15.0,
                        child: ElevatedButton(
                          onPressed: (() => Navigator.of(context)
                                  .push(DonationsApp.route(PaymentInfoPage(
                                darkTheme: widget.theme,
                              )))),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0)),
                              minimumSize: const Size(160, 45)),
                          child: const Text(
                            "Read More",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
          Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 0.2,
                height: 380,
                child: Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                        child: Image(
                          fit: BoxFit.fill,
                          height: 380,
                          width: MediaQuery.of(context).size.width / 0.4,
                          image: const AssetImage('assets/deliver.jpg'),
                        ),
                      ),
                      const Positioned(
                        left: 20.0,
                        top: 20.0,
                        child: Text(
                          'Learn how Charity \nAssociation delivers \nyour donation',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Positioned(
                        left: 20.0,
                        top: 120.0,
                        child: ElevatedButton(
                          onPressed: (() => Navigator.of(context).push(
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      const DonationInfoPage()))),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0)),
                              minimumSize: const Size(160, 45)),
                          child: const Text(
                            "Read More",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class DonationInfoPage extends StatelessWidget {
  const DonationInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "How is donation distributed",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text("Donation Distribution"),
              leading: InkWell(
                onTap: (() => Navigator.of(context).pop()),
                child: const Icon(Icons.arrow_back),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 15.0, top: 10.0, right: 15.0),
                      child: Text(
                        "This is how your donations & shared meals are distributed",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 10.0, right: 10.0),
                      child: Text(
                        "Charity Association is part of the Tharaka University Charity Programme."
                        "It enables students from unfortunate backgrounds and those in need secure"
                        " funding for their university education and upkeep by applying for grants and"
                        " contributions of donations from staffs and students.",
                        style: TextStyle(
                            color: Colors.blueGrey.shade600, fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 15.0),
                      child: Text("Here is how it works.",
                          style: TextStyle(
                              color: Colors.grey.shade900, fontSize: 16)),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0, left: 15.0),
                      child: Text("1. Choose where you want to help.",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, left: 15.0, right: 10.0),
                      child: Text(
                          "There are 2 areas of donations."
                          " Donations for Fees and Upkeep. You can select one area to donate any amount. Your donation will go to fund your selected area."
                          "There are also campaigns, campaigns are essential for emergency events that require "
                          "help through donations. The donations go to a specific campaign selected to fund the campaign goals.",
                          style: TextStyle(
                              color: Colors.blueGrey.shade600, fontSize: 15)),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0, left: 15.0),
                      child: Text(
                          "2. Charity Association delivers your donation to the area of need.",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, left: 15.0, right: 10.0),
                      child: Text(
                          'All donations go to the Charity account. Students in need are '
                          'identified and are allowed to apply for grant. Student in severe '
                          'unfortunate situations are considered most. Meals and tangible donations '
                          'are shared door to door.',
                          style: TextStyle(
                              color: Colors.blueGrey.shade600, fontSize: 15)),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0, left: 15.0),
                      child: Text("3. See the impact of your donation.",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, left: 15.0, right: 10.0),
                      child: Text(
                          'Through this application, Charity Association '
                          'will provide meals, money donations and life saving opportunities to students '
                          'but most importantly be able to build long-term, resilient solutions '
                          'that will help students overcome hunger and poverty.',
                          style: TextStyle(
                              color: Colors.blueGrey.shade600, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class PaymentInfoPage extends StatelessWidget {
  const PaymentInfoPage({super.key, required this.darkTheme});

  final bool darkTheme;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: (darkTheme) ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("M-Pesa Details"),
          leading: InkWell(
            onTap: (() => Navigator.pop(context)),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Send your donation straight via m-pesa",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 180,
                width: 200,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Business no",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      Text(
                        "507900",
                        style: TextStyle(color: Colors.red),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Account no",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      Text(
                        "8006090",
                        style: TextStyle(color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
