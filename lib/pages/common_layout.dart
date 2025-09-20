import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget body;

  const CommonLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NAKITTO SARAH APARTMENTS',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      ),
      body: Expanded(child: body),
      drawer: Drawer(
        elevation: 20.0,
        child: Container(
            color: const Color.fromARGB(255, 56, 118, 19),
            child: Column(
              children: <Widget>[
                Container(
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 50, 50, 50),
                    ),
                    accountName: const Text(
                      "EXODUS LLC",
                      style: TextStyle(color: Colors.amber),
                    ),
                    accountEmail: const Text("timexodusapts@gmail.com"),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset('name'),
                      ),
                    ),
                  ),
                ),
                ListTile(
                    title: const Text("Inbox",
                        style: TextStyle(color: Colors.white)),
                    leading: Container(
                      child: const Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                    )),
                const Divider(
                  height: 0.1,
                ),
                ListTile(
                    title: const Text("Primary",
                        style: TextStyle(color: Colors.white)),
                    leading: Container(
                      child: const Icon(
                        Icons.inbox,
                        color: Colors.white,
                      ),
                    )),
                ListTile(
                    title: const Text("Social",
                        style: TextStyle(color: Colors.white)),
                    leading: Container(
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                      ),
                    )),
                ListTile(
                  title: const Text("Promotions",
                      style: TextStyle(color: Colors.white)),
                  leading: Container(
                    child: const Icon(
                      Icons.local_offer,
                      color: Colors.white,
                    ),
                  ),
                ),
                ListTile(
                    title: const Text(
                      "Created By Alfred",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    leading: Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: const Icon(
                          Icons.copyright,
                          color: Colors.white,
                        ))),
              ],
            )),
      ),
    );
  }
}
