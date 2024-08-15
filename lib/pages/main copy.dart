import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color.fromARGB(255, 197, 28, 16)),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _count = 0;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CHRIST-S HEART CHILDRENS APP'),
        backgroundColor: Color.fromARGB(255, 197, 28, 16),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 50),
              child: Column(children: <Widget>[
                Text(
                  "Claire's App",
                  style: TextStyle(
                      color: Color.fromARGB(255, 176, 176, 176), fontSize: 20),
                ),
                Container(
                  color: Color.fromARGB(255, 97, 199, 13),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    "Just Counting numbers",
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20),
                  ),
                ),
              ])),
          Container(
              margin: EdgeInsets.only(bottom: 50),
              child: Icon(Icons.apple,
                  size: 150, color: Color.fromARGB(255, 85, 85, 85))),
          Text(
            ' $_count ',
            style: TextStyle(
                color: Color.fromARGB(255, 197, 28, 16), fontSize: 50),
          ),
        ],
      )),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _count++;
        }),
        tooltip: 'Increment Counter',
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 197, 28, 16),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
                    accountName: Text("CHRIST'S HEART KIDS",
                        style: TextStyle(color: Colors.amber)),
                    accountEmail: Text("chcchildrenschurch@gmail.com"),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.network(
                          'https://w7.pngwing.com/pngs/708/311/png-transparent-icon-logo-twitter-logo-twitter-logo-blue-social-media-area-thumbnail.png',
                          fit: BoxFit.contain,
                          width: 50.0, // Adjust the width as needed
                          height: 50.0, // Adjust the height as needed
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              // Image is loaded
                              return child;
                            } else {
                              // Image is still loading, you can show a placeholder
                              return CircularProgressIndicator();
                            }
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            // Handle image loading errors
                            return Icon(Icons.error,
                                color: Colors.red); // Placeholder for error
                          },
                        ),
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
                    title: new Text("Created By Alfred"),
                    leading: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Icon(Icons.copyright))),
              ],
            )),
      ),
    );
  }
}
