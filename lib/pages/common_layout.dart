import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget body;

  CommonLayout({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NAKITTO SARAH APARTMENTS',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: Color.fromARGB(255, 32, 32, 32),
      ),
      body: Expanded(child: body),
      drawer: Drawer(
        elevation: 20.0,
        child: Container(
            color: Color.fromARGB(255, 56, 118, 19),
            child: Column(
              children: <Widget>[
                Container(
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 50, 50, 50),
                    ),
                    accountName: Text(
                      "EXODUS LLC",
                      style: TextStyle(color: Colors.amber),
                    ),
                    accountEmail: Text("timexodusapts@gmail.com"),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset('name'),
                      ),
                    ),
                  ),
                ),
                ListTile(
                    title: new Text("Inbox",
                        style: TextStyle(color: Colors.white)),
                    leading: Container(
                      child: Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                    )),
                Divider(
                  height: 0.1,
                ),
                ListTile(
                    title: new Text("Primary",
                        style: TextStyle(color: Colors.white)),
                    leading: Container(
                      child: Icon(
                        Icons.inbox,
                        color: Colors.white,
                      ),
                    )),
                ListTile(
                    title: new Text("Social",
                        style: TextStyle(color: Colors.white)),
                    leading: Container(
                      child: Icon(
                        Icons.people,
                        color: Colors.white,
                      ),
                    )),
                ListTile(
                  title: new Text("Promotions",
                      style: TextStyle(color: Colors.white)),
                  leading: Container(
                    child: Icon(
                      Icons.local_offer,
                      color: Colors.white,
                    ),
                  ),
                ),
                ListTile(
                    title: new Text(
                      "Created By Alfred",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    leading: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Icon(
                          Icons.copyright,
                          color: Colors.white,
                        ))),
              ],
            )),
      ),
    );
  }
}
