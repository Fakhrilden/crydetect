import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:crydetect/screens/predict_voice_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController retypepasswordcontroller = TextEditingController();


  final _formkey = GlobalKey<FormState>();

  registration() async {
    if (password != null &&
        namecontroller.text != "" &&
        emailcontroller.text != "") {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Get the unique user ID generated by Firebase
        String userId = userCredential.user!.uid;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Registration Successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PredictVoice(userId: userId)));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password provided is too weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
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
      appBar: AppBar(
        title: Text(
          'Create Your Parent Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
            fontFamily: 'IndieFlower',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink[400],
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
                    return 'Please enter name';
                  }
                  return null;
                },
                controller: namecontroller,
                decoration: InputDecoration(
                  enabledBorder: _border,
                  focusedBorder: _border,
                  labelText: 'Username',
                  fillColor: Color.fromRGBO(255, 250, 183, 0.3),
                  filled: true,
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Email';
                  }
                  return null;
                },
                controller: emailcontroller,
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
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please re-enter Password';
                  }
                  if (value != passwordcontroller.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                controller: retypepasswordcontroller,
                decoration: InputDecoration(
                  enabledBorder: _border,
                  focusedBorder: _border,
                  labelText: 'Confirm Password',
                  fillColor: Color.fromRGBO(255, 250, 183, 0.3),
                  filled: true,
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      email = emailcontroller.text;
                      name = namecontroller.text;
                      password = passwordcontroller.text;
                    });
                    registration();
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(
                    vertical: 13.0,
                    horizontal: 30.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF273671),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed("/login");
                    },
                    child: Text('Already have an account? Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}