import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase/authentication.dart';

bool isLoading = true;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Center(
            child: Image.asset("assets/logo.png",
            height: height*.25,
            width: height*.25,),
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: "Username",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter username";
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
                          return "Please enter Password";
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text("Forgot Password?"),
                        onPressed: () => {},
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(0),
                        child: isLoading
                            ? ElevatedButton(
                          child: const Text('Log in'),
                          onPressed: () async {
                            setState(() {
                              isLoading = false;
                            });
                            if (_formKey.currentState!.validate()) {
                              dynamic results = await context
                                  .read<AuthenticationService>()
                                  .signIn(
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
                                      title: Text('Error'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(results),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Done'),
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
                              isLoading = true;
                            });
                          },
                        )
                            : Center(child: CircularProgressIndicator())
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    Text("Not a member yet?"),
                    TextButton(
                      child: Text("Register now"),
                      onPressed: () => {
                        {Navigator.pushNamed(context, '/signup')},
                      },
                    ),
                  ],
                ),
              ))
        ]),
      ),
    );
  }
}
