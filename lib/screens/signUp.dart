import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase/authentication.dart';

bool isLoading1= true;

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: Image.asset("assets/logo.png",
                height: height*.2,
                width: height*.2,),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "FullName",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: "Email",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your Email";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          hintText: "Password",
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter password";
                          }
                          return null;
                        },
                      ),
                      Padding(
                          padding: const EdgeInsets.all(0),
                          child: isLoading1
                              ? ElevatedButton(
                              child: const Text("Register"),
                              onPressed: () async
                              {
                                setState(() {
                                  isLoading1 = false;
                                });

                                if (_formKey.currentState!.validate()) {
                                  dynamic results = await context.read<
                                      AuthenticationService>().signUp(
                                    name: nameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  if (results != null) {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: false,
                                      // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Alert'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text(results),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Done'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                                setState(() {
                                  isLoading1 = true;
                                });

                              }
                          ): const Center(child: CircularProgressIndicator())
                      ),
                      TextButton(
                        child: const Text("Go to login"),
                        onPressed: () => {Navigator.pop(context)},
                      ),
                    ],
                  ),
                ))
          ]),
        ));
  }
}
