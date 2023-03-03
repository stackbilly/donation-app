import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donations_app/admin/campaign/campaign.dart';
import 'package:donations_app/admin/campaign/edit_campaign.dart';
import 'package:donations_app/app.dart';
import 'package:donations_app/fields/donation_distribute.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CampaignTab extends StatefulWidget {
  const CampaignTab({super.key, required this.theme});

  final bool theme;
  @override
  State<CampaignTab> createState() => _CampaignTabState();
}

class _CampaignTabState extends State<CampaignTab> {
  CollectionReference history =
      FirebaseFirestore.instance.collection('campaignHistory');

  Future<void> adjustCampaignState(
      CampaignState state, String campaignId) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("campaigns").doc(campaignId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(documentReference, {'state': state.name});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> campaignStreams = FirebaseFirestore.instance
        .collection('campaigns')
        .where('state', isEqualTo: CampaignState.active.name)
        .snapshots();
    Campaign campaign = Campaign('', '', '', 0, 0, '', 0, 0);
    return StreamBuilder<QuerySnapshot>(
      stream: campaignStreams,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                errorBuilder: ((context, error, stackTrace) {
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
                                              topLeft: Radius.circular(15.0),
                                              topRight: Radius.circular(15.0))),
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
                                                  fontWeight: FontWeight.w500),
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
                              bottom: 10.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  TextButton(
                                    onPressed: (() {
                                      campaign.id =
                                          data.docs[index].reference.id;
                                      campaign.title =
                                          data.docs[index]['title'];
                                      campaign.description =
                                          data.docs[index]['description'];
                                      campaign.targetAmount =
                                          data.docs[index]['targetAmount'];
                                      campaign.days = data.docs[index]['days'];
                                      campaign.imageUrl =
                                          data.docs[index]['imageUrl'];
                                      campaign.total =
                                          data.docs[index]['total'];
                                      campaign.totalSpent =
                                          data.docs[index]['totalSpent'];
                                      Navigator.push(
                                          context,
                                          DonationsApp.bounceInRoute(EditScreen(
                                            campaign: campaign,
                                            theme: widget.theme,
                                          )));
                                    }),
                                    child: const Text('Edit'),
                                  ),
                                  TextButton(
                                    onPressed: (() {
                                      final TextEditingController
                                          titleController =
                                          TextEditingController(
                                              text: data.docs[index]['title']);
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                content: SizedBox(
                                              width: 200,
                                              height: 150,
                                              child: Center(
                                                child: Form(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 5.0,
                                                                horizontal:
                                                                    16.0),
                                                        child: TextFormField(
                                                          controller:
                                                              titleController,
                                                          readOnly: true,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0)),
                                                              labelText:
                                                                  'Campaign title to delete'),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 5.0,
                                                                horizontal:
                                                                    16.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            //rem to add func to delete campaign
                                                            TextButton(
                                                              onPressed: () {
                                                                adjustCampaignState(
                                                                    CampaignState
                                                                        .deleted,
                                                                    data
                                                                        .docs[
                                                                            index]
                                                                        .reference
                                                                        .id);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                          });
                                    }),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (() {
                                      if (data.docs[index]['total'] <= 100) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: SizedBox(
                                                  height: 100,
                                                  child: Center(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            'Request Denied! Campaign total of ${data.docs[index]['total']} is inadequate'),
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'OK'))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      } else {
                                        Navigator.of(context).push(
                                            DonationsApp.bounceInRoute(
                                                DistributeDonation(
                                          title: data.docs[index]['title'],
                                          id: data.docs[index].reference.id,
                                          total: data.docs[index]['total'],
                                          theme: widget.theme,
                                        )));
                                      }
                                    }),
                                    child: Text(
                                      'Distribute',
                                      style:
                                          TextStyle(color: Colors.green[700]),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (() {
                                      adjustCampaignState(CampaignState.closed,
                                          data.docs[index].reference.id);
                                    }),
                                    child: const Text('Close'),
                                  ),
                                ],
                              )),
                          Positioned(
                              right: 14.0,
                              bottom: 60.0,
                              child: Text(
                                '${data.docs[index]['state']}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green,
                                ),
                              ))
                        ],
                      )),
                ));
          },
        );
      },
    );
  }
}
