import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/home.dart';
import 'package:flutter/material.dart';

class JoinCharityProgram extends StatefulWidget {
  const JoinCharityProgram({super.key, required this.theme});

  final bool theme;
  @override
  State<JoinCharityProgram> createState() => _JoinCharityProgramState();
}

class _JoinCharityProgramState extends State<JoinCharityProgram> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  final double _vert = 10.0;
  final double _hort = 16.0;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  Future<void> save() async {
    CollectionReference applicants =
        FirebaseFirestore.instance.collection('charityapplicants');
    return applicants.doc(phoneController.text).set({
      'name': nameController.text,
      'phone': phoneController.text,
      'reason': reasonController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: (widget.theme) ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Charity Program'),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width / 1.2,
              child: Card(
                shadowColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: _hort),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Name cannot be empty';
                            } else {
                              return null;
                            }
                          }),
                          controller: nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              labelText: 'Your name',
                              prefixIcon: const Icon(Icons.person)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _vert, horizontal: _hort),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone no cannot be empty';
                            } else {
                              return null;
                            }
                          }),
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              labelText: 'Your phone no',
                              prefixIcon: const Icon(Icons.call)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _vert, horizontal: _hort),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Reason to join cannot be empty';
                            } else {
                              return null;
                            }
                          }),
                          controller: reasonController,
                          maxLines: 4,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              labelText: 'Why do you want to join',
                              prefixIcon: const Icon(Icons.description)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _vert, horizontal: _hort),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            minimumSize: const Size(160, 45),
                          ),
                          onPressed: (() {
                            if (_formKey.currentState!.validate()) {
                              save();
                              showDialog(
                                  barrierDismissible: false,
                                  useSafeArea: true,
                                  barrierColor: Colors.indigo,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        content: SizedBox(
                                          height: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text('Information Sent!'),
                                                TextButton.icon(
                                                    onPressed: () => Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        HomePage(
                                                                          theme:
                                                                              widget.theme,
                                                                        )),
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false),
                                                    icon:
                                                        const Icon(Icons.done),
                                                    label: const Text('Leave'))
                                              ],
                                            ),
                                          ),
                                        ));
                                  });
                            }
                          }),
                          child: const Text('Send'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}
