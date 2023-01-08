import 'package:donations_app/admin/admin_auth.dart';
import 'package:donations_app/tabs/active_campaigns_tab.dart';
import 'package:donations_app/tabs/home_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.theme}) : super(key: key);

  bool theme;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  static const List<Tab> _tabs = <Tab>[
    Tab(
      text: 'Home',
    ),
    Tab(
      text: 'Campaigns',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.indigo,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                  bottom: const TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 2,
                    tabs: _tabs,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/trial.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          'Charity Association',
                        ),
                      )
                    ],
                  )),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: 100,
                      child: DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                        ),
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage: AssetImage('assets/trial.png'),
                                radius: 15,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: InkWell(
                                    onLongPress: (() => Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                            builder: (context) => AdminLogin(
                                                theme: widget.theme)))),
                                    child: const Text(
                                      'Charity Association',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))
                            ],
                          ),
                        )),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.person_rounded,
                      ),
                      title: const Text('Account'),
                      onTap: (() => true),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.contact_support,
                      ),
                      title: const Text('Contact us'),
                      onTap: (() => true),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                      ),
                      title: const Text('About us'),
                      onTap: (() => true),
                    ),
                    ListTile(
                      leading: (widget.theme)
                          ? const Icon(
                              Icons.light_mode,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.dark_mode,
                            ),
                      title:
                          Text((widget.theme) ? "Light Theme" : "Dark Theme"),
                      onTap: (() => setState(() {
                            widget.theme = !widget.theme;
                          })),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  HomePageTab(theme: widget.theme),
                  CampaignsTab(darkTheme: widget.theme),
                ],
              ),
            )));
  }
}
