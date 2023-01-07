import 'package:donations_app/admin/admin_tabs/admin_home_tab.dart';
import 'package:donations_app/admin/admin_tabs/campaign_tab.dart';
import 'package:donations_app/admin/campaign/create_campaign.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                  title: const Text('Donations'),
                  leading: const Icon(Icons.list_alt),
                  onTap: (() => Navigator.of(context)
                          .push(DonationsApp.route(ContributionList(
                        theme: theme,
                      )))),
                ),
                ListTile(
                  title: const Text('Closed Campaigns'),
                  leading: const Icon(Icons.history),
                  onTap: (() => Navigator.of(context)
                          .push(DonationsApp.route(ClosedCampaigns(
                        theme: theme,
                      )))),
                ),
                ListTile(
                  title: const Text('Charity Program Applicants'),
                  leading: const Icon(Icons.recent_actors),
                  onTap: (() => Navigator.of(context)
                          .push(DonationsApp.route(CharityApplicantsPage(
                        theme: theme,
                      )))),
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

class ContributionList extends StatefulWidget {
  const ContributionList({super.key, required this.theme});

  final bool theme;
  @override
  State<ContributionList> createState() => _ContributionListState();
}

class _ContributionListState extends State<ContributionList> {
  final Stream<QuerySnapshot> contributionStream =
      FirebaseFirestore.instance.collection('donations').snapshots();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Contribution List'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder(
          stream: contributionStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('An error occurred!');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.requireData;
            return ListView.builder(
                itemCount: data.size,
                itemBuilder: ((context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        data.docs[index]['category']
                            .toString()[0]
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                        '${data.docs[index]['name']}, Tel: ${data.docs[index]['phoneNo']}'),
                    subtitle: Text(
                        'Donated ${data.docs[index]['amount']} for ${data.docs[index]['category']} on ${data.docs[index]['date']}'),
                  );
                }));
          },
        ),
      ),
    );
  }
}

class ClosedCampaigns extends StatefulWidget {
  const ClosedCampaigns({super.key, required this.theme});

  final bool theme;
  @override
  State<ClosedCampaigns> createState() => _ClosedCampaignsState();
}

class _ClosedCampaignsState extends State<ClosedCampaigns> {
  final Stream<QuerySnapshot> history =
      FirebaseFirestore.instance.collection('campaignHistory').snapshots();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Closed Campaigns'),
          leading: InkWell(
            onTap: (() => Navigator.pop(context)),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: StreamBuilder(
          stream: history,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Text('No Availabe Data');
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
                return ListTile(
                  onTap: (() => true),
                  title: Text(data.docs[index]['title']),
                  subtitle: Text('Closed on: ${data.docs[index]['date']}'),
                  trailing: IconButton(
                    onPressed: (() => true),
                    icon: const Icon(Icons.arrow_forward_ios),
                    tooltip: 'View More',
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
