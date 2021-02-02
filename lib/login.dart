import 'package:chat_demo/home.dart';
import 'package:chat_demo/utils.dart';
import 'package:chat_demo/widget/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final String title;

  LoginScreen({Key key, this.title}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum SignInWith { anonymous, email, google }

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  bool isLoggedIn = false;
  User currentUser;

  SharedPreferences prefs;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    await Future.delayed(
      Duration(seconds: 5),
      () => {
        this.setState(() {
          isLoading = false;
        })
      },
    );

    prefs = await SharedPreferences.getInstance();

    isLoggedIn = await googleSignIn.isSignedIn();
    dtPrint('login', 'isLoggedIn => $isLoggedIn');
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            currentUserId: prefs.getString('id'),
          ),
        ),
      );
    }

    this.setState(() {
      isLoading = false;
    });
  }

  Future<void> handleSignIn(SignInWith signInWith) async {
    dtPrint('login', 'handleSignIn signInWith $signInWith');
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    firebaseAuth.authStateChanges().listen((User user) async {
      if (user != null) {
        dtPrint('login', 'User is signed in!');
        dtPrint('login', user.toString());
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'nickname': user.displayName,
            'photoUrl': user.photoURL,
            'id': user.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'chattingWith': null
          });

          currentUser = user;
          await prefs.setString('id', currentUser.uid);
          await prefs.setString('nickname', currentUser.displayName);
          await prefs.setString('photoUrl', currentUser.photoURL);
        } else {
          await prefs.setString('id', documents[0].data()['id']);
          await prefs.setString('nickname', documents[0].data()['nickname']);
          await prefs.setString('photoUrl', documents[0].data()['photoUrl']);
          await prefs.setString('aboutMe', documents[0].data()['aboutMe']);
        }
        Fluttertoast.showToast(msg: "Sign in success");
        this.setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              currentUserId: user.uid,
            ),
          ),
        );
      } else {
        dtPrint('login', 'User is currently signed out!');
        // Fluttertoast.showToast(msg: "Sign in fail");
        this.setState(() {
          isLoading = false;
        });
      }
    });

    firebaseAuth.idTokenChanges().listen((User user) {
      if (user == null) {
        dtPrint('login', 'User token refreshed / user is null');
      } else {
        dtPrint('login', 'User token refreshed');
      }
    });

    switch (signInWith) {
      case SignInWith.google:
        {
          GoogleSignInAccount googleUser = await googleSignIn.signIn();
          GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          User u = (await firebaseAuth.signInWithCredential(credential)).user;
        }
        break;
      case SignInWith.email:
        {
          try {
            UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: "barry.allen@example.com",
                    password: "SuperSecretPassword!");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              dtPrint('login', 'The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              dtPrint('login', 'The account already exists for that email.');
            }
          } catch (e) {
            dtPrint('login', e);
          }
        }
        break;
      case SignInWith.anonymous:
        {
          testPrint();
          try {
            UserCredential userCredential =
                await firebaseAuth.signInAnonymously();
          } on FirebaseAuthException catch (e) {
            dtPrint('login', 'Failed with error code: ${e.code}');
            dtPrint('login', e.message);
          }
        }
        break;
      default:
        {}
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    dtPrint('login', 'build');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'SIGN IN WITH GOOGLE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () => handleSignIn(SignInWith.google),
                  color: Color(0xffdd4b39),
                  highlightColor: Color(0xffff7f7f),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                ),
                SizedBox(
                  height: 16.0,
                ),
                FlatButton(
                  child: Text(
                    'SIGN IN WITH EMAIL',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () => handleSignIn(SignInWith.email),
                  color: Colors.amber,
                  highlightColor: Colors.amberAccent,
                  splashColor: Colors.cyanAccent,
                  textColor: Colors.black87,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                ),
                SizedBox(
                  height: 16.0,
                ),
                FlatButton(
                  child: Text(
                    'SIGN IN ANONYMOUS',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () => handleSignIn(SignInWith.anonymous),
                  color: Colors.green,
                  highlightColor: Colors.greenAccent,
                  splashColor: Colors.cyanAccent,
                  textColor: Colors.black87,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                ),
                SizedBox(
                  height: 16.0,
                ),
                FlatButton(
                  child: Text(
                    'SIGN OUT',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: firebaseAuth.signOut,
                  color: Colors.red,
                  highlightColor: Colors.redAccent,
                  splashColor: Colors.cyanAccent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                ),
              ],
            ),
          ),
          Positioned(
            child: isLoading ? const Loading() : Container(),
          )
        ],
      ),
    );
  }
}
