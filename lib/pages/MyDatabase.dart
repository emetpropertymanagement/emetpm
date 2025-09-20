import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emet/pages/PaymentForm.dart';
import 'AppLayout.dart';
import 'NewClientForm.dart'; // Using the refactored form

class MyDatabase extends StatefulWidget {
  const MyDatabase({super.key});

  @override
  _DatabaseState createState() => _DatabaseState();
}

class _DatabaseState extends State<MyDatabase> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('clients');

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Icon(Icons.people),
                  SizedBox(width: 8),
                  Text(
                    'CLIENTS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _clientsCollection.orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data()! as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final phone =
                        (data['phone'] ?? '').toString().toLowerCase();
                    return _searchQuery.isEmpty ||
                        name.contains(_searchQuery) ||
                        phone.contains(_searchQuery);
                  }).toList();
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No clients found. Add one!',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = docs[index];
                      Map<String, dynamic> clientData =
                          doc.data()! as Map<String, dynamic>;
                      return _buildClientListItem(
                          doc.id, clientData, index + 1);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ClientForm(), // Navigate to the new form to add
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 3, 115, 171),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildClientListItem(
      String docId, Map<String, dynamic> data, int itemNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 248, 205),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$itemNumber. ${data['name'] ?? 'N/A'}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  data['propertyName'] ?? 'No Property Assigned',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ClientForm(clientId: docId), // Pass docId to edit
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.receipt,
                    color: Color.fromARGB(255, 53, 53, 53)),
                onPressed: () {
                  // Prepare client details for PaymentForm
                  final clientDetails = {
                    'id': docId,
                    'name': data['name'] ?? '',
                    'propertyId': data['propertyId'] ?? '',
                    'propertyName': data['propertyName'] ?? '',
                    'phone': data['phone'] ?? '',
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PaymentForm(clientDetails: clientDetails),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // void _navigateToPaymentForm(
  //     String docId, Map<String, dynamic> clientDetails) async {
  //   // This function needs to be refactored to work with Firestore data
  //   // For now, it is commented out.

  //   // Map<String, dynamic> paymentDetails = {
  //   //   'clientId': docId,
  //   //   'name': clientDetails['name'],
  //   //   'apartment': clientDetails['propertyName'],
  //   //   'phone': clientDetails['phone'],
  //   // };

  //   // Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(
  //   //     builder: (context) => PaymentForm(paymentDetails: paymentDetails),
  //   //   ),
  //   // );
  // }
}
