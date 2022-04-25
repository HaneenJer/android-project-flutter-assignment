import 'package:flutter/material.dart';
import 'package:hello_me/Authentican.dart';
import 'package:hello_me/randomWords.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController doubleCheckPassController =
      TextEditingController();
  bool _isLoading = false;

  void _startLoading() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  void logIn() async {
    final signedIn = await AuthRepository.instance()
        .signIn(emailController.text, passwordController.text);
    if (signedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RandomWords()),
          (route) => false);
    } else {
      const snackBar = SnackBar(
        content: Text('There was an error logging in the app'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Column(
          children: [
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: const Text(
                  'Welcome to Startup Names Generator, please log in below',
                  style: TextStyle(fontSize: 15),
                )),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : TextButton(
                      onPressed: _isLoading ? _startLoading : () => logIn(),
                      child: const Text("Log in"),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom +
                                30),
                        child: Wrap(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 5),
                              child: const Text(
                                  "Please confirm your password below: "),
                            ),
                            const Divider(
                              height: 10,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.black,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 5),
                              child: TextField(
                                obscureText: true,
                                controller: doubleCheckPassController,
                                decoration: const InputDecoration(
                                  labelText: 'password',
                                  labelStyle: TextStyle(
                                      color: const Color(0xFF424242)),
                                ),
                              ),
                            ),
                            const Divider(
                              height: 10,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.black,
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                  height: 40,
                                  width: 90,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: const Text("Confirm",
                                        style: TextStyle(
                                          fontSize: 13,
                                        )),
                                    onPressed: () async {
                                      if (passwordController.text
                                              .toString() ==
                                          doubleCheckPassController.text
                                              .toString()) {
                                        await AuthRepository.instance()
                                            .signUp(emailController.text, passwordController.text);
                                        logIn();
                                      } else {
                                        const snackBar = SnackBar(
                                          content: Text('Passwords must match'),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    },
                                  )),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text("New user? Click to sign up"),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ));
  }
}
