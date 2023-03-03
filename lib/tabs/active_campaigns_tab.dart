import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/fields/donate_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';

import '../admin/campaign/campaign.dart';

class CampaignsTab extends StatefulWidget {
  const CampaignsTab({super.key, required this.darkTheme});

  final bool darkTheme;
  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> {
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectionSubscription;

  final Stream<QuerySnapshot> _campaignStreams =
      FirebaseFirestore.instance.collection('campaigns').snapshots();

  @override
  void initState() {
    super.initState();

    initConnectivity();
    _connectionSubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();

    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status $e');
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
    Campaign campaign = Campaign('', '', '', 0, 0, '', 0, 0);
    return Scaffold(
        body: StreamBuilder(
      stream: _campaignStreams,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No active campaigns!'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error has occurred'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final data = snapshot.requireData;
        return ListView.builder(
          itemCount: data.size,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 400,
                  width: 312,
                  child: InkWell(
                    onTap: (() {
                      campaign.title = data.docs[index]['title'];
                      campaign.description = data.docs[index]['description'];
                      campaign.targetAmount = data.docs[index]['targetAmount'];
                      campaign.total = data.docs[index]['total'];
                      campaign.days = data.docs[index]['days'];
                      campaign.imageUrl = data.docs[index]['imageUrl'];
                      Navigator.of(context).push(DonationsApp.route(
                          ViewCampaign(
                              campaign: campaign, theme: widget.darkTheme)));
                    }),
                    child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Stack(
                          children: [
                            Positioned(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0)),
                                child: Image.network(
                                  data.docs[index]['imageUrl'],
                                  fit: BoxFit.fill,
                                  width: 312,
                                  height: 270,
                                  errorBuilder: ((context, error, stackTrace) {
                                    return ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        topRight: Radius.circular(15.0),
                                      ),
                                      child: Container(
                                        height: 270,
                                        decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                topRight:
                                                    Radius.circular(15.0))),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: const [
                                              Icon(
                                                Icons.error,
                                                size: 50,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                'Error while loading image!\nCheck your network',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 140,
                                left: 20.0,
                                child: SizedBox(
                                  width: 312,
                                  child: Text(
                                    data.docs[index]['title'],
                                    maxLines: 3,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                )),
                            Positioned(
                              bottom: 90,
                              left: 20.0,
                              child: LinearPercentIndicator(
                                width: 200.0,
                                animation: true,
                                animateFromLastPercent: true,
                                animationDuration: 1000,
                                lineHeight: 18.0,
                                leading: Text(
                                  data.docs[index]['total'].toString(),
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500),
                                ),
                                trailing: Text(
                                  data.docs[index]['targetAmount'].toString(),
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500),
                                ),
                                center: Text(
                                  '${((data.docs[index]['total'] / data.docs[index]['targetAmount']) * 100).toInt()}%',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                progressColor: Colors.red,
                                backgroundColor: Colors.blue,
                                percent: (data.docs[index]['total'] <=
                                        data.docs[index]['targetAmount'])
                                    ? data.docs[index]['total'] /
                                        data.docs[index]['targetAmount']
                                    : 1.0,
                              ),
                            ),
                            Positioned(
                              bottom: 73.0,
                              right: 12.0,
                              child: Text(
                                '${data.docs[index]['state']}',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                            Positioned(
                                bottom: 10.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (connectionStatus ==
                                              ConnectivityResult.wifi ||
                                          connectionStatus ==
                                              ConnectivityResult.mobile) {
                                        Navigator.of(context).push(
                                            DonationsApp.bounceInRoute(
                                                DonationField(
                                          category:
                                              data.docs[index].reference.id,
                                          theme: widget.darkTheme,
                                        )));
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
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Text(
                                                          'You need an active internet connection to proceed'),
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child:
                                                              const Text('OK'))
                                                    ],
                                                  )),
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.amberAccent[700],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0)),
                                        minimumSize: const Size(290, 50)),
                                    child: const Text(
                                      "Donate now",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )),
                            Positioned(
                              right: 5.0,
                              top: 10.0,
                              child: IconButton(
                                onPressed: (() {
                                  Share.share(
                                      'Support the campaign ${data.docs[index]['title']} by donating right now on https://www.google.com',
                                      subject: '${data.docs[index]['title']}');
                                }),
                                icon: const Icon(
                                  Icons.share,
                                  size: 24,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Share',
                              ),
                            ),
                            Positioned(
                              left: 5.0,
                              top: 10.0,
                              child: IconButton(
                                onPressed: () {
                                  campaign.title = data.docs[index]['title'];
                                  campaign.description =
                                      data.docs[index]['description'];
                                  campaign.targetAmount =
                                      data.docs[index]['targetAmount'];
                                  campaign.total = data.docs[index]['total'];
                                  campaign.days = data.docs[index]['days'];
                                  campaign.imageUrl =
                                      data.docs[index]['imageUrl'];
                                  Navigator.of(context).push(DonationsApp.route(
                                      ViewCampaign(
                                          campaign: campaign,
                                          theme: widget.darkTheme)));
                                },
                                icon: const Icon(
                                  Icons.more_horiz_sharp,
                                  size: 30,
                                  color: Colors.blue,
                                ),
                                tooltip: 'More',
                              ),
                            )
                          ],
                        )),
                  ),
                ));
          },
        );
      },
    ));
  }
}

class ViewCampaign extends StatelessWidget {
  const ViewCampaign({Key? key, required this.campaign, required this.theme})
      : super(key: key);

  final bool theme;
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: campaign.title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: (theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Campaign Information'),
          leading: InkWell(
              child: const Icon(Icons.arrow_back),
              onTap: () => Navigator.pop(context)),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.0,
            height: MediaQuery.of(context).size.height / 1.4,
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: CircleAvatar(
                            backgroundImage: NetworkImage(campaign.imageUrl)),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Title',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[400]),
                      ),
                      subtitle: Text(
                        campaign.title,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Description',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[400]),
                      ),
                      subtitle: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            campaign.description,
                            overflow: TextOverflow.clip,
                          )),
                    ),
                    ListTile(
                      title: Text(
                        'Target Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[400]),
                      ),
                      subtitle: Text(
                        campaign.targetAmount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Contributed so far',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[400]),
                      ),
                      subtitle: Text(
                        campaign.total.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'This campaign will run for',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[400]),
                      ),
                      subtitle: Text(
                        '${campaign.days.toString()} days',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                )),
          ),
        )),
      ),
    );
  }
}
