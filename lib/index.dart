import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'main.dart';
import 'temp.dart';
import 'writeFireStore.dart';
import 'readFireStore.dart';

class Index extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  bool isloggedin = false;
  int _current = 0;
  dynamic _selectedIndex = {};

  CarouselController _carouselController = new CarouselController();

  List<dynamic> _products = [
    {
      'title': 'Library Sitting Space Arrangement',
      'image': 'assets/Logo_IITJ.png',
      'description': 'Tap to see available spaces'
    },
    {
      'title': 'Books List',
      // 'image':'https://images.unsplash.com/photo-1582588678413-dbf45f4823e9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2265&q=80',
      'image': 'assets/5836.jpg',
      'description': 'Tap to see Availabe Books'
    },
    {
      'title': 'Our Team',
      // 'image':'https://images.unsplash.com/photo-1589188056053-28910dc61d38?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2264&q=80',
      'image': 'assets/54955.jpg',
      'description': 'Wohoo!!'
    }
  ];

  getUser() async {
    User firebaseUser = _auth.currentUser;
    await firebaseUser.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  void initState() {
    this.getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex.length > 0
          ? Container(
              child: Align(
                // alignment: Alignment(
                //   (0.0 / MediaQuery.of(context).size.width),
                //   (0.0 / (MediaQuery.of(context).size.height)),
                // ),
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    if (_current == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectService()));
                    }
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                  ),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'You are @Library IIT Jodhpur',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: 450.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.70,
                enlargeCenterPage: true,
                pageSnapping: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            items: _products.map((movie) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedIndex == movie) {
                          _selectedIndex = {};
                        } else {
                          _selectedIndex = movie;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedIndex == movie
                              ? Border.all(
                                  color: Colors.blue.shade500, width: 3)
                              : null,
                          boxShadow: _selectedIndex == movie
                              ? [
                                  BoxShadow(
                                      color: Colors.blue.shade100,
                                      blurRadius: 30,
                                      offset: Offset(0, 10))
                                ]
                              : [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: Offset(0, 5))
                                ]),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: 320,
                              margin: EdgeInsets.only(top: 10),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              // child: Image.network(movie['image'],
                              //     fit: BoxFit.cover),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 3,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      movie['image'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              movie['title'],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              movie['description'],
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList()),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 3) {
              _auth.signOut();
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => HomePage()));
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false);
            }

            // else if (index == 0) {
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => SelectService()));
            // }
            else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddUser("Chiku", "TBD", 10)));
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GetUserName()));
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
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.teal,
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
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blue;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width / 2),
        height: size.height,
        width: size.width,
      ),
      3.14,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}