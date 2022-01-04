import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/models/http_exception.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Signin }

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Signin;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'first_name': '',
    'last_name': '',
    'address': '',
    'credit_card_number': '',
    'security_code': '',
    'expiration_date': '',
    'card_holder': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void showErrorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(errorMessage),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'))
              ],
            ));
  }

//Submit Function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign user in
      if (_authMode == AuthMode.Signin) {
        await Provider.of<AuthProvider>(context, listen: false).signIn(
          _authData['email'],
          _authData['password'],
        );
        // Sign user up
      } else {
        await Provider.of<AuthProvider>(context, listen: false).signUp(
          _authData['email'],
          _authData['password'],
          _authData['first_name'],
          _authData['last_name'],
          _authData['address'],
          _authData['card_holder'],
          _authData['security_code'],
          _authData['credit_card_number'],
          _authData['expiration_date'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

//Switch Authentication Function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  void _switchAuthMode() {
    if (_authMode == AuthMode.Signin) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Signin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Stack(children: [
      Align(
        alignment: Alignment(0.8, -0.8),
        child: Container(
          width: 200,
          height: 200,
          child: Image.asset(
            'assets/images/parking.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      Positioned(
        width: deviceSize.width,
        bottom: -25,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Container(
            height: 625,
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //Title Text>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      _authMode == AuthMode.Signin
                          ? 'Welcome Back'
                          : 'Get Started',
                      style: TextStyle(
                          fontSize: 50,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  _authMode == AuthMode.Signin
                      ?
                      //SigIn....................................................................................................
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'E-mail/Username'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid email !';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // Password>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty || value.length < 5) {
                                    return 'Password  is too short!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['password'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      :
                      //SignUp........................................................................................................
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //General Information title>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              Text(
                                'General Information',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blueGrey[900],
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              //First Name>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'First Name'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['first_name'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              //Last Name>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Last Name'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['last_name'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              //Emaill>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid email !';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // Password>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                obscureText: true,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value.isEmpty || value.length < 5) {
                                    return 'Password  is too short!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['password'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              //Confirm Password>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Confirm Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              //Address>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'Address'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['address'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              //Billing Information title>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              Text(
                                'Billing Information',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blueGrey[900],
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              //Card Holder>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Card Holder'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['card_holder'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              //Security Code>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Security Code'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['security_code'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              //Cerdit card number>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Credit Card Number'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['credit_card_number'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              //Expiration date>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Expiration Date'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['expiration_date'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                            ],
                          ),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Signin/Signup text and button ...............................................................
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Signin/Signup text>>>>>>>>>>>>>>>>
                      Text(
                        _authMode == AuthMode.Signin ? 'Sign In' : 'Sign Up',
                        style: TextStyle(
                            fontSize: 25,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                      // Sign/SignUp  button>>>>>>>>>>>>>>>>>>>
                      GestureDetector(
                        onTap: _submit,
                        child: _isLoading == false
                            ? CircleAvatar(
                                radius: 30.0,
                                backgroundImage:
                                    const AssetImage('assets/images/right.png'),
                                backgroundColor: Theme.of(context).primaryColor,
                              )
                            : CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color.fromRGBO(44, 62, 80, 1),
                                  ),
                                ),
                              ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  Row(children: [
                    //The underlined Signup or Signin text
                    GestureDetector(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          _authMode == AuthMode.Signin ? 'Sign Up' : 'Sign In',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onTap: _switchAuthMode,
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Facebook Image
                        Container(
                            width: 35,
                            height: 35,
                            child: Image.asset('assets/images/facebook.png')),
                        const SizedBox(
                          width: 10,
                        ),
                        // Google Image
                        Container(
                            width: 35,
                            height: 35,
                            child: Image.asset('assets/images/google.png')),
                      ],
                    )
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
