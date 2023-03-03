import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/admin/campaign/campaign.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class RecycleBin extends StatelessWidget {
  const RecycleBin({super.key, required this.theme});

  final bool theme;

  Future<void> restoreCampaign(CampaignState state, String campaignId) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("campaigns").doc(campaignId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(documentReference, {'state': state.name});
    });
  }

  Future<void> deleteCampaign(String id, String imgUrl) {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection("campaigns");

    return FirebaseStorage.instance
        .refFromURL(imgUrl)
        .delete()
        .then((value) => collRef.doc(id).delete());
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> binStreams = FirebaseFirestore.instance
        .collection("campaigns")
        .where('state', isEqualTo: CampaignState.deleted.name)
        .snapshots();
    return MaterialApp(
      title: "Recycle Bin",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: theme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Recycle Bin"),
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: StreamBuilder(
          stream: binStreams,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No active campaigns',
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
              itemBuilder: (context, index) {
                return Container(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 300,
                      width: 312,
                      child: Card(
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
                                    height: 180,
                                    errorBuilder:
                                        ((context, error, stackTrace) {
                                      return ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15.0),
                                          topRight: Radius.circular(15.0),
                                        ),
                                        child: Container(
                                          height: 180,
                                          decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(15.0),
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
                                                      fontStyle:
                                                          FontStyle.italic,
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
                                  bottom: 130,
                                  left: 10.0,
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
                                bottom: 80,
                                left: 10.0,
                                child: LinearPercentIndicator(
                                  width: 170.0,
                                  animation: true,
                                  animationDuration: 1000,
                                  lineHeight: 20.0,
                                  leading: Text(
                                    data.docs[index]['total'].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red),
                                  ),
                                  trailing: Text(
                                    data.docs[index]['targetAmount'].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue),
                                  ),
                                  center: Text(
                                    '${((data.docs[index]['total'] / data.docs[index]['targetAmount']) * 100).toInt()}%',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  progressColor: Colors.red,
                                  backgroundColor: Colors.blue,
                                  percent: (data.docs[index]['total'] <=
                                          data.docs[index]['targetAmount'])
                                      ? (data.docs[index]['total'] /
                                          data.docs[index]['targetAmount'])
                                      : 1.0,
                                ),
                              ),
                              Positioned(
                                  bottom: 15.0,
                                  left: 50.0,
                                  child: TextButton.icon(
                                      onPressed: () => restoreCampaign(
                                          CampaignState.active,
                                          data.docs[index].reference.id),
                                      icon: const Icon(
                                        Icons.restore_from_trash,
                                        color: Colors.green,
                                      ),
                                      label: const Text(
                                        "Restore",
                                        style: TextStyle(color: Colors.green),
                                      ))),
                              Positioned(
                                  right: 14.0,
                                  bottom: 60.0,
                                  child: Text(
                                    '${data.docs[index]['state']}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.green,
                                    ),
                                  )),
                              Positioned(
                                  bottom: 15.0,
                                  right: 50.0,
                                  child: TextButton.icon(
                                      onPressed: () => deleteCampaign(
                                          data.docs[index].reference.id,
                                          data.docs[index]['imageUrl']),
                                      icon: const Icon(
                                        Icons.restore_from_trash,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ))),
                            ],
                          )),
                    ));
              },
            );
          },
        ),
      ),
    );
  }
}

class ClosedCampaigns extends StatelessWidget {
  const ClosedCampaigns({super.key, required this.theme});

  final bool theme;

  Future<void> restoreCampaign(CampaignState state, String campaignId) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("campaigns").doc(campaignId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(documentReference, {'state': state.name});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> binStreams = FirebaseFirestore.instance
        .collection("campaigns")
        .where('state', isEqualTo: CampaignState.closed.name)
        .snapshots();
    return MaterialApp(
      title: "Closed Campaigns",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData.dark(),
      themeMode: theme ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Closed Campaigns"),
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: StreamBuilder(
          stream: binStreams,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No closed campaigns',
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
              itemBuilder: (context, index) {
                return Container(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 300,
                      width: 312,
                      child: Card(
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
                                    height: 180,
                                    errorBuilder:
                                        ((context, error, stackTrace) {
                                      return ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15.0),
                                          topRight: Radius.circular(15.0),
                                        ),
                                        child: Container(
                                          height: 180,
                                          decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(15.0),
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
                                                      fontStyle:
                                                          FontStyle.italic,
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
                                  bottom: 130,
                                  left: 10.0,
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
                                bottom: 80,
                                left: 10.0,
                                child: LinearPercentIndicator(
                                  width: 170.0,
                                  animation: true,
                                  animationDuration: 1000,
                                  lineHeight: 20.0,
                                  leading: Text(
                                    data.docs[index]['total'].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red),
                                  ),
                                  trailing: Text(
                                    data.docs[index]['targetAmount'].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue),
                                  ),
                                  center: Text(
                                    '${((data.docs[index]['total'] / data.docs[index]['targetAmount']) * 100).toInt()}%',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  progressColor: Colors.red,
                                  backgroundColor: Colors.blue,
                                  percent: (data.docs[index]['total'] <=
                                          data.docs[index]['targetAmount'])
                                      ? (data.docs[index]['total'] /
                                          data.docs[index]['targetAmount'])
                                      : 1.0,
                                ),
                              ),
                              Positioned(
                                  right: 14.0,
                                  bottom: 60.0,
                                  child: Text(
                                    '${data.docs[index]['state']}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.green,
                                    ),
                                  )),
                              Positioned(
                                  bottom: 15.0,
                                  left: 50.0,
                                  child: TextButton.icon(
                                      onPressed: () => restoreCampaign(
                                          CampaignState.active,
                                          data.docs[index].reference.id),
                                      icon:
                                          const Icon(Icons.restore_from_trash),
                                      label: const Text("Reopen"))),
                            ],
                          )),
                    ));
              },
            );
          },
        ),
      ),
    );
  }
}
