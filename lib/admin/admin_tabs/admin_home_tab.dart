import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key, required this.theme});

  final bool theme;
  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  final Stream<QuerySnapshot> _donationsStreams =
      FirebaseFirestore.instance.collection('totals').snapshots();
  final Stream<QuerySnapshot> campaignStreams =
      FirebaseFirestore.instance.collection('campaigns').limit(3).snapshots();

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 5.0,
                  width: MediaQuery.of(context).size.width / 1.4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.purple,
                              Colors.blueAccent,
                            ])),
                    child: StreamBuilder(
                      stream: _donationsStreams,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'An error occurred!',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text(
                              'No available data!',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        Map<String, dynamic> data = {};
                        if (snapshot.hasData) {
                          snapshot.data!.docs.map((DocumentSnapshot doc) {
                            data = doc.data()! as Map<String, dynamic>;
                          }).toList();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Center(
                                child: Text(
                                  'Total Donations',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Text(
                                'Ksh ${data['jointTotal'].toString()}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.red[600]),
                        child: StreamBuilder(
                          stream: _donationsStreams,
                          builder: ((context, snapshot) {
                            if (snapshot.hasError) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      content: SizedBox(
                                        height: 130,
                                        child: Center(
                                          child: Text('An error occurred!'),
                                        ),
                                      ),
                                    );
                                  });
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: Text(
                                  "No available data!",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                              );
                            }
                            Map<String, dynamic> data = {};
                            if (snapshot.hasData) {
                              snapshot.data!.docs.map((DocumentSnapshot doc) {
                                data = doc.data()! as Map<String, dynamic>;
                              }).toList();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(top: 35.0),
                                  child: Center(
                                    child: Text(
                                      'Fees \nDonations',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Ksh ${data['feesTotal'].toString()}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.indigo),
                        child: StreamBuilder(
                          stream: _donationsStreams,
                          builder: ((context, snapshot) {
                            if (snapshot.hasError) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      content: SizedBox(
                                        height: 130,
                                        child: Center(
                                          child: Text('An error occurred!'),
                                        ),
                                      ),
                                    );
                                  });
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                child: Text("No available data"),
                              );
                            }
                            Map<String, dynamic> data = {};
                            if (snapshot.hasData) {
                              snapshot.data!.docs.map((DocumentSnapshot doc) {
                                data = doc.data()! as Map<String, dynamic>;
                              }).toList();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(top: 35.0),
                                  child: Center(
                                    child: Text(
                                      'Upkeep\nDonations',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Ksh ${data['upkeepTotal'].toString()}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              StreamBuilder(
                stream: _donationsStreams,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('An error ccurred'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No Data!'),
                    );
                  }
                  Map<String, dynamic> data = {};
                  if (snapshot.hasData) {
                    snapshot.data!.docs.map((DocumentSnapshot doc) {
                      data = doc.data()! as Map<String, dynamic>;
                      chartData.add(ChartData(
                          'Fees', data['feesTotal'], Colors.red.shade900));
                      chartData.add(ChartData(
                          'Upkeep', data['upkeepTotal'], Colors.indigo));
                      int campaignTotal =
                          data['jointTotal'] - data['generalTotal'];
                      chartData.add(
                          ChartData('Campaigns', campaignTotal, Colors.teal));
                      chartData.add(ChartData('AmountSpent', data['totalSpent'],
                          Colors.amber.shade400));
                    }).toList();
                  }
                  return SizedBox(
                    height: 250,
                    width: 300,
                    child: SfCircularChart(
                      legend: Legend(isVisible: true),
                      title: ChartTitle(text: 'Donation Analysis'),
                      margin: const EdgeInsets.all(15),
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                            // enableTooltip: true,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                            dataSource: chartData,
                            pointColorMapper: (ChartData data, _) => data.color,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);

  final String x;
  final int y;
  final Color color;
}
