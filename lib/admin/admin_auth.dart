import 'dart:math';

import 'package:donations_app/admin/admin_home.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key, required this.theme});

  final bool theme;
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int? code;

  bool isUser = false;

  int generateCode() {
    var random = Random();

    int code = random.nextInt(900000) + 100000;
    return code;
  }

  @override
  void initState() {
    super.initState();

    code = generateCode();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> mailCode(int code) async {
    final Email email = Email(
      body: 'Verifiication code: $code',
      recipients: [(emailController.text)],
      subject: 'Verification code for login @ ${DateTime.now()}',
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }

  Future<bool> authenticate() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());
      if (userCredential.user != null) {
        setState(() {
          isUser = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-Found') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: SizedBox(
                  height: 80,
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Request Denied!'),
                        TextButton(
                            onPressed: (() => Navigator.of(context)
                                    .push(DonationsApp.route(HomePage(
                                  theme: widget.theme,
                                )))),
                            child: const Text('OK'))
                      ],
                    ),
                  ),
                ),
              );
            });
      }
      if (e.code == 'wrong-password') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Request Denied!'),
                        TextButton(
                            onPressed: (() => Navigator.of(context)
                                    .push(DonationsApp.route(HomePage(
                                  theme: widget.theme,
                                )))),
                            child: const Text('OK'))
                      ],
                    ),
                  ),
                ),
              );
            });
      }
    }
    return isUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Only!'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2.0,
              width: 300,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 16.0),
                          child: CircleAvatar(
                            child: Icon(Icons.admin_panel_settings),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter valid e-email to proceed';
                            } else {
                              return null;
                            }
                          }),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: 'E-mail',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              prefixIcon: const Icon(Icons.email)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter valid password to proceed';
                            } else {
                              return null;
                            }
                          }),
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: (() {
                            if (_formKey.currentState!.validate()) {
                              authenticate().then((value) {
                                if (value) {
                                  mailCode(code!).then((value) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: SizedBox(
                                              height: 120,
                                              width: 300,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    "To verify it is you we've sent you the verification code, check your email",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0),
                                                    child: TextButton(
                                                        onPressed: (() => Navigator
                                                                .of(context)
                                                            .pushAndRemoveUntil(
                                                                DonationsApp.route(
                                                                    UserVerification(
                                                                        code:
                                                                            code!,
                                                                        theme: widget
                                                                            .theme)),
                                                                (Route<dynamic>
                                                                        route) =>
                                                                    false)),
                                                        child:
                                                            const Text("OK")),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        barrierDismissible: false);
                                  });
                                }
                              });
                            }
                          }),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width / 2.5, 50),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
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
    );
  }
}

class UserVerification extends StatefulWidget {
  const UserVerification({super.key, required this.code, required this.theme});

  final int code;
  final bool theme;

  @override
  State<UserVerification> createState() => _UserVerificationState();
}

class _UserVerificationState extends State<UserVerification> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "User verification",
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: widget.theme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("User Veification"),
        ),
        body: Center(
          child: SizedBox(
            width: 250,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return "This field cannot be empty";
                      } else {
                        return null;
                      }
                    }),
                    controller: codeController,
                    decoration: InputDecoration(
                        labelText: 'Verification Code',
                        prefixIcon: const Icon(Icons.code),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                        onPressed: (() {
                          if (_formKey.currentState!.validate()) {
                            if (int.tryParse(codeController.text) ==
                                widget.code) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  DonationsApp.route(
                                      AdminHome(theme: widget.theme)),
                                  (route) => false);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Invalid Code!",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: SizedBox(
                                          height: 100,
                                          child: Center(
                                            child: TextButton(
                                                onPressed: (() =>
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                            DonationsApp.route(
                                                                AdminLogin(
                                                              theme:
                                                                  widget.theme,
                                                            )),
                                                            (route) => false)),
                                                child: const Text("Back")),
                                          )),
                                    );
                                  },
                                  barrierDismissible: false);
                            }
                          }
                        }),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            minimumSize: const Size(150, 45)),
                        child: const Text("Verify")),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
