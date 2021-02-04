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

  @override
  void dispose() {
    dsPrint('dispose');
    super.dispose();
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
    dsPrint('isLoggedIn => $isLoggedIn');
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
    dsPrint('handleSignIn signInWith $signInWith');

    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    firebaseAuth.authStateChanges().listen((User user) async {
      if (user != null) {
        dsPrint('authStateChanges().listen/User is signed in!');
        dsPrint(user.toString());
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
        // Fluttertoast.showToast(msg: "Sign in success");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              currentUserId: user.uid,
            ),
          ),
        );
      } else {
        dsPrint('authStateChanges().listen/User is currently signed out!');
        // Fluttertoast.showToast(msg: "Sign in fail");
      }
    });

    firebaseAuth.idTokenChanges().listen((User user) {
      if (user == null) {
        dsPrint('idTokenChanges().listen/Token changed/User is null');
      } else {
        dsPrint('idTokenChanges().listen/Token changed');
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
              dsPrint('The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              dsPrint('The account already exists for that email.');
            }
          } catch (e) {
            dsPrint(e);
          }
        }
        break;
      case SignInWith.anonymous:
        {
          try {
            UserCredential userCredential =
                await firebaseAuth.signInAnonymously();
          } on FirebaseAuthException catch (e) {
            dsPrint('Failed with error code: ${e.code}');
            dsPrint(e.message);
          }
        }
        break;
      default:
        {}
        break;
    }
    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    dsPrint('run');
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
