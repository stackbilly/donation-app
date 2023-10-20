import 'package:donations_app/admin/admin_tabs/admin_home_tab.dart';
import 'package:donations_app/admin/admin_tabs/campaign_tab.dart';
import 'package:donations_app/admin/campaign/create_campaign.dart';
import 'package:donations_app/admin/recycle_bin.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key, required this.theme});

  final bool theme;

  static final List<Tab> tabs = <Tab>[
    const Tab(
      text: 'Home',
    ),
    const Tab(
      text: 'Campaign',
    )
  ];

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: MaterialApp(
        title: 'Admin Home',
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.dark(),
        themeMode: (theme) ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Admin Panel'),
            bottom: TabBar(
              tabs: tabs,
              indicatorWeight: 3.0,
              indicatorColor: Colors.white,
            ),
            actions: [
              IconButton(
                onPressed: (() => Navigator.push(
                    context,
                    DonationsApp.route(HomePage(
                      theme: theme,
                    )))),
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Home',
              ),
              IconButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    DonationsApp.route(AdminHome(
                      theme: theme,
                    )),
                    (Route<dynamic> route) => false),
                icon: const Icon(
                  Icons.refresh,
                ),
                tooltip: 'Reload',
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                const SizedBox(
                  height: 60,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                    ),
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Text(
                        'Admin Panel',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Reports'),
                  leading: const Icon(Icons.receipt),
                  onTap: (() => true),
                ),
                ListTile(
                  title: const Text('Expenditures'),
                  leading: const Icon(Icons.money_off_sharp),
                  onTap: (() => Navigator.of(context)
                          .push(DonationsApp.route(Expenditures(
                        theme: theme,
                      )))),
                ),
                ListTile(
                  title: const Text('Recycle Bin'),
                  leading: const Icon(Icons.recycling_sharp),
                  onTap: (() =>
                      Navigator.of(context).push(DonationsApp.route(RecycleBin(
                        theme: theme,
                      )))),
                ),
                ListTile(
                  title: const Text('Closed Campaigns'),
                  leading: const Icon(Icons.auto_delete),
                  onTap: (() => Navigator.of(context)
                      .push(DonationsApp.route(ClosedCampaigns(theme: theme)))),
                ),
                ListTile(
                  title: const Text('Logout'),
                  leading: const Icon(Icons.logout),
                  onTap: (() => _signOut().then((value) => Navigator.of(context)
                      .pushAndRemoveUntil(
                          CupertinoPageRoute(
                              builder: (context) => HomePage(theme: theme)),
                          (route) => false))),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              AdminHomeTab(theme: theme),
              CampaignTab(
                theme: theme,
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (() => Navigator.of(context)
                    .push(DonationsApp.bounceInRoute(CreateCampaign(
                  theme: theme,
                )))),
            tooltip: 'Create Campaign',
            backgroundColor: const Color(0xff6750a4),
            child: const Icon(
              Icons.add,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}

class Expenditures extends StatelessWidget {
  const Expenditures({super.key, required this.theme});

  final bool theme;

  String returnDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    String fdatetime = DateFormat('dd-MM-yyy').format(date);
    return fdatetime;
  }

  String returnTime(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    String time = date.toString().split(' ').last.split('.').first;
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Expenditures",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: theme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Expenditures"),
          leading: InkWell(
            onTap: (() => Navigator.of(context).pop()),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("expenditures")
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No new expenditures',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'An error occurred!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
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
              itemBuilder: ((context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
                  child: SizedBox(
                      height: 350,
                      child: Container(
                          decoration: BoxDecoration(
                              color: theme
                                  ? Colors.blueGrey
                                  : Colors.blue.shade100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, top: 0, right: 0),
                                child: Container(
                                  height: 50,
                                  color: Colors.blue,
                                  child: Center(
                                    child: Text(
                                      "Expenditure id: ${data.docs[index].reference.id}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2.0, left: 2.0),
                                child: ListTile(
                                  title: const Text(
                                    "Amount Spent",
                                  ),
                                  leading: const Icon(
                                    Icons.monetization_on_outlined,
                                  ),
                                  minLeadingWidth: 10,
                                  trailing: Text(
                                    "Ksh ${data.docs[index]['amount']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2.0, left: 2.0),
                                child: ListTile(
                                  title: const Text(
                                    "Date Spent",
                                  ),
                                  leading: const Icon(Icons.calendar_today),
                                  minLeadingWidth: 10,
                                  trailing: Text(
                                    returnDate(data.docs[index]['timestamp'])
                                        .replaceAll('-', '/'),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2.0, left: 2.0),
                                child: ListTile(
                                  title: const Text(
                                    "Time Spent",
                                  ),
                                  leading: const Icon(Icons.access_time),
                                  minLeadingWidth: 10,
                                  trailing: Text(
                                    '${returnTime(data.docs[index]['timestamp'])} hrs',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, left: 2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Reason",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          "${data.docs[index]['reason']}",
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15),
                                        ),
                                      )
                                    ],
                                  )),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5.0, left: 2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Source",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          "${data.docs[index]['category']}",
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15),
                                        ),
                                      )
                                    ],
                                  )),
                            ],
                          ))),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
