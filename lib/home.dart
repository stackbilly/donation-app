import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/admin/admin_auth.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/charity_applications.dart';
import 'package:donations_app/tabs/active_campaigns_tab.dart';
import 'package:donations_app/tabs/home_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

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
    Tab(
      text: 'Donations',
    )
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
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
                  actions: [
                    IconButton(
                        onPressed: (() => Navigator.of(context)
                            .pushAndRemoveUntil(
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        HomePage(theme: widget.theme)),
                                (route) => false)),
                        icon: const Icon(Icons.refresh))
                  ],
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
                        Icons.contact_mail,
                      ),
                      title: const Text('Contact us'),
                      onTap: (() => Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) =>
                                  SendEmail(theme: widget.theme)))),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.accessibility_rounded,
                      ),
                      title: const Text('Get Support'),
                      onTap: (() => Navigator.of(context).push(
                          DonationsApp.route(
                              CharityApplication(theme: widget.theme)))),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                      ),
                      title: const Text('About Charity Association'),
                      onTap: (() => Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) => const DonationInfoPage()))),
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
                  RealtimeDonations(theme: widget.theme)
                ],
              ),
            )));
  }
}

class SendEmail extends StatefulWidget {
  const SendEmail({super.key, required this.theme});

  final bool theme;
  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();

    super.dispose();
  }

  Future<void> mailMessage() async {
    final Email email = Email(
      body: messageController.text,
      recipients: [("livingstoneochadia95@gmail.com")],
      subject: subjectController.text,
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Send Email",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: widget.theme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Send Email"),
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: SizedBox(
                height: 400,
                width: 300,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                "Enter email details",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17),
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: TextFormField(
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "subject cannot be empty";
                              } else {
                                return null;
                              }
                            }),
                            controller: subjectController,
                            decoration: InputDecoration(
                                labelText: 'Subject',
                                prefixIcon: const Icon(Icons.title),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: TextFormField(
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "message cannot be empty";
                              } else {
                                return null;
                              }
                            }),
                            controller: messageController,
                            decoration: InputDecoration(
                                labelText: 'Message',
                                prefixIcon: const Icon(Icons.message),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 70.0, top: 20.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 45),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0))),
                            onPressed: (() {
                              if (_formKey.currentState!.validate()) {
                                mailMessage().then((value) => showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: SizedBox.square(
                                          dimension: 80,
                                          child: TextButton(
                                            onPressed: (() => Navigator.of(
                                                    context)
                                                .pushAndRemoveUntil(
                                                    CupertinoPageRoute(
                                                        builder: (context) =>
                                                            HomePage(
                                                                theme: widget
                                                                    .theme)),
                                                    (route) => false)),
                                            child: const Text("OK"),
                                          ),
                                        ),
                                      );
                                    }));
                              }
                            }),
                            icon: const Icon(Icons.email),
                            label: const Text("Send Mail"),
                          ),
                        )
                      ],
                    ),
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

class RealtimeDonations extends StatelessWidget {
  const RealtimeDonations({super.key, required this.theme});

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
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("donations")
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'No new donations',
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
                  height: 300,
                  child: Container(
                      decoration: BoxDecoration(
                          color:
                              theme ? Colors.blueGrey : Colors.blue.shade100),
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
                                  "Donation id: ${data.docs[index].reference.id}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0, left: 2.0),
                            child: ListTile(
                              title: const Text(
                                "Donation of amount",
                              ),
                              leading: const Icon(
                                Icons.monetization_on,
                              ),
                              minLeadingWidth: 10,
                              trailing: Text(
                                "Ksh ${data.docs[index]['amount']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0, left: 2.0),
                            child: ListTile(
                              title: const Text(
                                "Donation is dated",
                              ),
                              leading: const Icon(Icons.calendar_today),
                              minLeadingWidth: 10,
                              trailing: Text(
                                returnDate(data.docs[index]['timestamp'])
                                    .replaceAll('-', '/'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0, left: 2.0),
                            child: ListTile(
                              title: const Text(
                                "Donation made at",
                              ),
                              leading: const Icon(Icons.access_time),
                              minLeadingWidth: 10,
                              trailing: Text(
                                '${returnTime(data.docs[index]['timestamp'])} hrs',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0, left: 2.0),
                            child: ListTile(
                              title: const Text(
                                "Donated by",
                              ),
                              leading: const Icon(Icons.person),
                              minLeadingWidth: 10,
                              trailing: Text(
                                "${data.docs[index]['name']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ))),
            );
          }),
        );
      },
    );
  }
}
