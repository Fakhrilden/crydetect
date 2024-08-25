import 'package:crydetect/screens/auth/forgot_password.dart';
import 'package:crydetect/screens/auth/service/auth.dart';
import 'package:crydetect/screens/predict_voice_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";

  TextEditingController mailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid;

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PredictVoice(userId: userId)));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  static final _border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromRGBO(255, 250, 183, 0.3),
      appBar: AppBar(
        title: Text(
          'Access Your Parent Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
            fontFamily: 'IndieFlower',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),

      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter E-mail';
                  }
                  return null;
                },
                controller: mailcontroller,
                decoration: InputDecoration(
                  enabledBorder: _border,
                  focusedBorder: _border,
                  labelText: 'Email',
                  fillColor: Color.fromRGBO(255, 250, 183, 0.3),
                  filled: true,
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                obscureText: true, // This hides the text being entered
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Password';
                  }
                  return null;
                },
                controller: passwordcontroller,
                decoration: InputDecoration(
                  enabledBorder: _border,
                  focusedBorder: _border,
                  labelText: 'Password',
                  fillColor: Color.fromRGBO(255, 250, 183, 0.3),
                  filled: true,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      email = mailcontroller.text;
                      password = passwordcontroller.text;
                    });
                  }
                  userLogin();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity, 60)),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // forget password screen
                          },
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPassword()));
                              },
                              child: Text('Forget Password?')),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Text(
                      "or LogIn with",
                      style: TextStyle(
                          color: Color(0xFF273671),
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            AuthMethods().signInWithGoogle(context);
                          },
                          child: Image.asset(
                            "assets/google.png",
                            height: 45,
                            width: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            AuthMethods().signInWithApple();
                          },
                          child: Image.asset(
                            "assets/apple1.png",
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacementNamed("/signup");
                          },
                          child: Text('Don\'t have an account? Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
