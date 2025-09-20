import 'package:flutter/material.dart';

class MTNContacts extends StatelessWidget {
  const MTNContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MTN Contacts'),
      ),
      body: const Center(
        // Display MTN contacts or relevant content
        child: Text('MTN Contacts Page Content'),
      ),
    );
  }
}
