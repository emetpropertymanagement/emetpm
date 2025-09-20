import 'package:emet/pages/AppLayout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  int totalClients = 0;
  late final CollectionReference _clientsCollection;

  @override
  void initState() {
    super.initState();
    _clientsCollection = FirebaseFirestore.instance.collection('clients');
    _listenToClientCount();
  }

  void _listenToClientCount() {
    _clientsCollection.snapshots().listen((snapshot) {
      setState(() {
        totalClients = snapshot.size;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.analytics),
                  SizedBox(width: 30.0),
                  Text(
                    'ANALYTICS',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total Clients:',
                style: TextStyle(
                  color: Color.fromARGB(255, 195, 54, 54),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                totalClients.toString(),
                style: const TextStyle(
                  backgroundColor: Color.fromARGB(255, 255, 241, 148),
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
