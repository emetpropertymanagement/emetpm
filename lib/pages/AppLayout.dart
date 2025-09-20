import 'package:emet/pages/Analytics.dart';
import 'package:emet/pages/NewClientForm.dart';
import 'package:emet/pages/Properties.dart';
import 'package:emet/pages/home.dart';
import 'package:emet/pages/MyDatabase.dart';
import 'package:flutter/material.dart';

import 'Receipt.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const AppLayout({super.key, required this.body, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EMET Property Management',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the color of the menu icon here
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
            icon: const Icon(Icons.logout),
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 29, 29, 1),
        elevation: 20,
      ),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 6, 130, 31),
              ),
              child: Column(children: <Widget>[
                Image(
                  image: AssetImage("assets/bigezow.png"),
                  width: 100,
                ),
              ])),
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: const Text('New Contact',
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ClientForm()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title:
                const Text('Database', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyDatabase()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title:
                const Text('Analytics', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Analytics()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Receipt Number',
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Receipt()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title:
                const Text('Properties', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Properties()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Handle Logout click
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
          ),
        ],
      ),
    );
  }
}
