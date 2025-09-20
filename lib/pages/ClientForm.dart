import 'package:emet/database_helper.dart';
import 'package:emet/pages/MyDatabase.dart';
import 'package:flutter/material.dart';
import 'AppLayout.dart';

class ClientForm extends StatefulWidget {
  final Map<String, dynamic>? clientDetails;

  const ClientForm({super.key, this.clientDetails});

  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.clientDetails != null) {
      nameController.text = widget.clientDetails!['name'];
      phoneController.text = widget.clientDetails!['phone'];
      apartmentController.text = widget.clientDetails!['apartment'];
      roomController.text = widget.clientDetails!['room'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
        body: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clientDetails != null
                      ? 'Edit Client'
                      : 'Add New Client',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 103, 181),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the client\'s name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 103, 181),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the client\'s phone number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 103, 181),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                  controller: apartmentController,
                  decoration: const InputDecoration(labelText: 'Name of Apartment'),
                ),
                TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 103, 181),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Room number'),
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    if (widget.clientDetails != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          _deleteClient(context, widget.clientDetails!['id']);
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    const SizedBox(width: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addOrUpdateClient(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyDatabase()));
                        }
                      },
                      icon: Icon(
                          widget.clientDetails != null ? Icons.edit : Icons.add,
                          color: Colors.white),
                      label: Text(
                          widget.clientDetails != null ? 'Update' : 'Add',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 20, 144, 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 46, 46, 46),
                      child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyDatabase()));
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          label: const Text(
                            "Back",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                          )),
                    ),
                    const SizedBox(
                      width: 50.0,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }

  void _addOrUpdateClient(BuildContext context) async {
    Map<String, dynamic> client = {
      'name': nameController.text,
      'phone': phoneController.text,
      'apartment': apartmentController.text,
      'room': roomController.text,
    };

    int clientId;
    if (widget.clientDetails != null) {
      clientId = await DatabaseHelper.instance.updateClient(
        widget.clientDetails!['id'], // Pass the client ID
        client, // Pass the client data
      );
    } else {
      clientId = await DatabaseHelper.instance.insertClient(client);
    }

    if (clientId != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Client updated successfully!',
            style: TextStyle(color: Colors.black, fontSize: 14.0),
          ),
          backgroundColor: Color.fromARGB(255, 131, 230, 126),
        ),
      );

      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add/update client. Please try again.',
              style: TextStyle(color: Colors.black, fontSize: 14.0)),
          backgroundColor: Color.fromARGB(255, 255, 161, 161),
        ),
      );
    }
  }

  void _deleteClient(BuildContext context, int clientId) async {
    // Show a confirmation dialog
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this client?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // User confirmed, proceed with deletion
      int rowsDeleted = await DatabaseHelper.instance.deleteClient(clientId);

      if (rowsDeleted > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client deleted successfully!'),
          ),
        );

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyDatabase()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete client. Please try again.'),
          ),
        );
      }
    }
  }

  void _resetForm() {
    nameController.clear();
    phoneController.clear();
    apartmentController.clear();
    roomController.clear();
  }
}
