import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AppLayout.dart';

class Receipts extends StatefulWidget {
  const Receipts({super.key});

  @override
  _ReceiptsState createState() => _ReceiptsState();
}

class _ReceiptsState extends State<Receipts> {
  String? _selectedMonth;
  String? _selectedPropertyId;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildFilters(),
            Expanded(child: _buildReceiptsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton<String>(
              hint: const Text('Select Month'),
              value: _selectedMonth,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMonth = newValue;
                });
              },
              items: _months.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('properties').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Error loading properties for filter: ${snapshot.error}");
                  return const Text('Error');
                }
                if (!snapshot.hasData) return const SizedBox.shrink();
                return DropdownButton<String>(
                  hint: const Text('Select Property'),
                  value: _selectedPropertyId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPropertyId = newValue;
                    });
                  },
                  items: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return DropdownMenuItem<String>(
                      value: document.id,
                      child: Text(document['name']),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptsList() {
    Query query = FirebaseFirestore.instance.collection('receipts').orderBy('createdAt', descending: true);

    if (_selectedMonth != null) {
      query = query.where('month', isEqualTo: _months.indexOf(_selectedMonth!) + 1);
    }
    if (_selectedPropertyId != null) {
      query = query.where('propertyId', isEqualTo: _selectedPropertyId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error fetching receipts: ${snapshot.error}");
          return const Center(child: Text('Something went wrong. Check logs.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No receipts found for the selected filters.'));
        }

        return ListView(children: snapshot.data!.docs.map((doc) => _buildReceiptCard(doc)).toList());
      },
    );
  }

  Widget _buildReceiptCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: ListTile(
        title: Text(data['clientName'] ?? 'N/A'),
        subtitle: Text('${data['propertyName']} - Ugx ${data['amount']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.cloud_download, color: Colors.blue),
              onPressed: () async {
                try {
                  final url = Uri.parse(data['receiptPdfUrl']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                } catch (e) {
                  print("Error launching URL: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open receipt: $e")));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteReceipt(doc.id, data['receiptPdfUrl']),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReceipt(String docId, String fileUrl) async {
    bool confirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this receipt? This will also delete the PDF file.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
            ],
          ),
        ) ?? false;

    if (confirmed) {
      try {
        await FirebaseFirestore.instance.collection('receipts').doc(docId).delete();
        await FirebaseStorage.instance.refFromURL(fileUrl).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt deleted successfully.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        print("Error deleting receipt: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete receipt: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}