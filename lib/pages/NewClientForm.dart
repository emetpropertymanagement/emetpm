import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppLayout.dart';

class ClientForm extends StatefulWidget {
  final String? clientId;

  const ClientForm({super.key, this.clientId});

  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  Future<void> _pickContact() async {
    if (!await FlutterContacts.requestPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts permission denied.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final Contact? contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        setState(() {
          nameController.text = contact.displayName;
          if (contact.phones.isNotEmpty) {
            phoneController.text = contact.phones.first.number;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  String? _selectedPropertyId;
  String? _selectedPropertyName;
  bool _isLoading = false;

  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('clients');
  final CollectionReference _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      _loadClientData();
    }
  }

  Future<void> _loadClientData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot clientDoc =
          await _clientsCollection.doc(widget.clientId).get();
      if (clientDoc.exists) {
        Map<String, dynamic> clientData =
            clientDoc.data() as Map<String, dynamic>;
        nameController.text = clientData['name'];
        phoneController.text = clientData['phone'];
        roomController.text = clientData['room'];
        setState(() {
          _selectedPropertyId = clientData['propertyId'];
          _selectedPropertyName = clientData['propertyName'];
        });
      }
    } catch (e) {
      print("Error loading client data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load client data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a property.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> clientData = {
      'name': nameController.text,
      'phone': phoneController.text,
      'room': roomController.text,
      'propertyId': _selectedPropertyId,
      'propertyName': _selectedPropertyName,
      'updatedAt': Timestamp.now(),
    };

    try {
      if (widget.clientId == null) {
        clientData['createdAt'] = Timestamp.now();
        await _clientsCollection.add(clientData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Client added successfully!'),
              backgroundColor: Colors.green),
        );
      } else {
        await _clientsCollection.doc(widget.clientId).update(clientData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Client updated successfully!'),
              backgroundColor: Colors.green),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      print("Error saving client: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to save client: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteClient() async {
    if (widget.clientId == null) return;

    bool confirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this client?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _clientsCollection.doc(widget.clientId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Client deleted.'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print("Error deleting client: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete client: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(30.0),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.clientId == null
                            ? 'Add New Client'
                            : 'Edit Client',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _pickContact,
                          icon: const Icon(Icons.person_add,
                              size: 32,
                              color: Color.fromARGB(255, 0, 103, 181)),
                          tooltip: 'Pick from Contacts',
                        ),
                      ),
                      TextFormField(
                        controller: nameController,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                        decoration:
                            const InputDecoration(labelText: "Client's Name"),
                      ),
                      TextFormField(
                        controller: phoneController,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a phone number'
                            : null,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _propertiesCollection.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(
                                "Error fetching properties for dropdown: ${snapshot.error}");
                            return const Text('Error loading properties');
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          var properties = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            value: _selectedPropertyId,
                            hint: const Text('Select Property'),
                            items: properties.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text(doc['name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              var selectedDoc = properties
                                  .firstWhere((doc) => doc.id == value);
                              setState(() {
                                _selectedPropertyId = value;
                                _selectedPropertyName = selectedDoc['name'];
                              });
                            },
                            validator: (value) => value == null
                                ? 'Please select a property'
                                : null,
                            decoration:
                                const InputDecoration(labelText: 'Apartment'),
                          );
                        },
                      ),
                      TextFormField(
                        controller: roomController,
                        decoration:
                            const InputDecoration(labelText: 'Room number'),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.clientId != null)
                            ElevatedButton.icon(
                              onPressed: _deleteClient,
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                          ElevatedButton.icon(
                            onPressed: _saveClient,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Client'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
