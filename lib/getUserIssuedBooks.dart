import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loginapp/adminPanel.dart';
import 'package:loginapp/index.dart';
import 'package:loginapp/main.dart';
import 'package:loginapp/temp.dart';
import 'package:loginapp/userProfile.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'models/books.dart';
import 'animation/FadeAnimation.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GetUserIssuedBooks extends StatefulWidget {
  @override
  State<GetUserIssuedBooks> createState() => _GetUserIssuedBooksState();
}

class _GetUserIssuedBooksState extends State<GetUserIssuedBooks> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime now = DateTime.now();

  List<Service> _services = [];
  int selectedService = -1;
  int _currentIndex = 0;

  // const GetUserIssuedBooks({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final username = user.displayName;
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('IssuedBooks')
        .where('issuedBy', isEqualTo: _auth.currentUser.displayName)
        .snapshots(includeMetadataChanges: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Center(
              child: Text(
                'Books Issued by You',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(
                  "Book Name : " + data['bookName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text("Date : " +
                    DateFormat.yMMMd()
                        .format(data['issuedTime'].toDate())
                        .toString()),
                trailing: FlatButton(
                  onPressed: () {
                    showAlertDialog2(
                        context, data['bookName'], data['bookDetails']);
                    // print(data['bookDetails']);
                    // FirebaseFirestore.instance
                    //     .collection('IssuedBooks')
                    //     .doc(data['bookDetails'])
                    //     .update({'description': FieldValue.delete()})
                    //     .then((value) => {
                    //           print("User Updated"),
                    //           // showAlertDialog2(context),
                    //         })
                    //     .catchError(
                    //         (error) => print("Failed to update user: $error"));
                  },
                  child: Icon(Icons.assignment_return_rounded),
                  // child: FutureBuilder(
                  //   future: controller?.getCameraInfo(),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.data != null) {
                  //       return Text(
                  //           'Camera facing ${describeEnum(snapshot.data!)}');
                  //     } else {
                  //       return const Text('loading');
                  //     }
                  //   },
                  // ),
                ),
                // trailing: Text(data['age'].toString()),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Index()));
            } else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompleteProfileScreen()));
            } else if (index == 2) {
              FirebaseFirestore.instance
                  .collection('librarian')
                  .where('email',
                      isEqualTo: FirebaseAuth.instance.currentUser.email)
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  // print(doc['entryTime'].toDate().toString());
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserTab()));
                  // var x = Service(doc["full_name"],
                  //     'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png');
                  // _services.insert(i, x);
                  // print(_services);
                });
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => UserTab()));
              });
            }
            if (index == 3) {
              showAlertDialog(context);
            }
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),
          // SalomonBottomBarItem(
          //     icon: Icon(Icons.favorite_border),
          //     title: Text("Likes"),
          //     selectedColor: Colors.pink),
          // SalomonBottomBarItem(
          //   icon: Icon(Icons.search),
          //   title: Text("Search"),
          //   selectedColor: Colors.orange,
          // ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.teal,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.admin_panel_settings),
            title: Text("Admin"),
            selectedColor: Colors.redAccent,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.logout),
            title: Text("LogOut"),
            selectedColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    // Widget logOutButton = SalomonBottomBarItem(
    //   icon: Icon(Icons.logout),
    //   title: Text("LogOut"),
    //   selectedColor: Colors.redAccent,
    // );
    Widget okButton = TextButton(
      child: Text("Logout"),
      onPressed: () {
        _auth.signOut();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout Alert!!"),
      content: Text("Are You Sure You Want To LogOut?"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog2(BuildContext context, String bookName, String bookId) {
    // set up the button
    // Widget logOutButton = SalomonBottomBarItem(
    //   icon: Icon(Icons.logout),
    //   title: Text("LogOut"),
    //   selectedColor: Colors.redAccent,
    // );
    Widget okButton = TextButton(
      child: Text("Return Book"),
      onPressed: () {
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
        sendMail(
            _auth.currentUser.email, _auth.currentUser.displayName, bookName);
        FirebaseFirestore.instance
            .collection('Books')
            .doc(bookId)
            .update({'bookIssued': false})
            .then((value) => {
                  print("User Updated"),
                })
            .catchError((error) => print("Failed to update user: $error"));
        FirebaseFirestore.instance
            .collection('IssuedBooks')
            .where("bookDetails", isEqualTo: bookId)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Index()), (route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Book Return"),
      content: Text("Are you sure you want to return the book?"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void sendMail(String email, String personName, String bookName) async {
    String username = 'goswamipranav11@gmail.com';
    String password = 'Pranav@2002';

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(username, username.toString())
      ..recipients.add(email)
      // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Book Return @Library IITJ::  ${DateTime.now()}'
      ..text = 'Heyy ' +
          personName +
          '!' +
          '\nYou have to submit ' +
          bookName +
          ' on by E.O.D' +
          // '\nYou will have to return the book within 7 working days else you will be penalised!!' +
          '\nRegards.';
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    // DONE

    // Let's send another message using a slightly different syntax:
    //
    // Addresses without a name part can be set directly.
    // For instance `..recipients.add('destination@example.com')`
    // If you want to display a name part you have to create an
    // Address object: `new Address('destination@example.com', 'Display name part')`
    // Creating and adding an Address object without a name part
    // `new Address('destination@example.com')` is equivalent to
    // adding the mail address as `String`.

    // final equivalentMessage = Message()
    //   ..from = Address(username, 'Your name 😀')
    //   ..recipients.add(Address('goswamipranav11@gmail.com'))
    //   // ..ccRecipients
    //   //     .addAll([Address('destCc1@example.com'), 'destCc2@example.com'])
    //   // ..bccRecipients.add('bccAddress@example.com')
    //   ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
    //   ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    //   ..html =
    //       '<h1>Test</h1>\n<p>Hey! Here is some HTML content</p><img src="cid:myimg@3.141"/>'
    //   ..attachments = [
    //     // FileAttachment(File('exploits_of_a_mom.png'))
    //     //   ..location = Location.inline
    //     //   ..cid = '<myimg@3.141>'
    //   ];

    final sendReport2 = await send(message, smtpServer);

    // Sending multiple messages with the same connection
    //
    // Create a smtp client that will persist the connection
    var connection = PersistentConnection(smtpServer);

    // Send the first message
    await connection.send(message);

    // send the equivalent message
    // await connection.send(equivalentMessage);

    // close the connection
    await connection.close();
  }
}
