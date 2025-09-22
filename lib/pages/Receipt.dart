import 'package:emet/pages/AppLayout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt extends StatefulWidget {
  const Receipt({super.key});

  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  int currentReceiptNumber = 0;
  final TextEditingController _receiptNumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentReceiptNumber();
  }

  Future<void> _loadCurrentReceiptNumber() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('receipt_number')
          .get();
      int receiptNumber = 1;
      if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('current')) {
        receiptNumber = doc.data()!['current'] as int;
      } else if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('start')) {
        receiptNumber = doc.data()!['start'] as int;
      }
      setState(() {
        currentReceiptNumber = receiptNumber;
        _receiptNumberController.text = currentReceiptNumber.toString();
      });
    } catch (e) {
      _showDialog('Error', 'Failed to load receipt number: $e');
    }
  }

  Future<void> _resetReceiptNumber() async {
    try {
      int newReceiptNumber = int.parse(_receiptNumberController.text);
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('receipt_number')
          .set({'current': newReceiptNumber}, SetOptions(merge: true));
      await _loadCurrentReceiptNumber();
      _showDialog(
          'Receipt Number Updated', 'New Receipt Number: $newReceiptNumber');
    } catch (e) {
      _showDialog('Error', 'Failed to update receipt number: $e');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Current Receipt Number: $currentReceiptNumber',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Set Receipt Number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _receiptNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter a Receipt Number',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _resetReceiptNumber();
                },
                child: const Text('Make current number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
