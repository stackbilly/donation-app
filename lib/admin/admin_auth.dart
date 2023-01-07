import 'package:donations_app/admin/admin_home.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  // final user = FirebaseAuth.instance.currentUser;

  // @override
  // void initState() {
  //   super.initState();

  //   if (user != null) {
  //     Navigator.push(
  //       context,
  //       DonationsApp.route(const AdminHome()),
  //     );
  //   }
  // }

  Future<void> authenticate() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
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
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
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
                              // authenticate();
                              Navigator.of(context).pushAndRemoveUntil(
                                  DonationsApp.route(AdminHome(
                                    theme: widget.theme,
                                  )),
                                  (Route<dynamic> route) => false);
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
