import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppLayout.dart';

class Properties extends StatefulWidget {
  const Properties({super.key});

  @override
  _PropertiesState createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {
  bool _isAddingNewProperty = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final CollectionReference _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');

  Future<void> _addProperty() async {
    if (_nameController.text.isNotEmpty && _locationController.text.isNotEmpty) {
      try {
        await _propertiesCollection.add({
          'name': _nameController.text,
          'location': _locationController.text,
          'createdAt': Timestamp.now(),
        });

        _nameController.clear();
        _locationController.clear();
        setState(() {
          _isAddingNewProperty = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Property added successfully.'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        print("Error adding property: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add property: $e'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out both fields.')),
      );
    }
  }

  Future<void> _deleteProperty(String docId) async {
    try {
      await _propertiesCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Property deleted.'), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("Error deleting property: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete property: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAddingNewProperty = !_isAddingNewProperty;
                });
              },
              child: Text(
                  _isAddingNewProperty ? 'Show Properties' : 'New Property'),
            ),
            const SizedBox(height: 20),
            if (_isAddingNewProperty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Property Name'),
                    ),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addProperty,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _propertiesCollection
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print("Error fetching properties: ${snapshot.error}");
                      return const Center(
                          child: Text('Something went wrong. Check logs.'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No properties found. Add one!'));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name']),
                          subtitle: Text(data['location']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProperty(document.id),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
