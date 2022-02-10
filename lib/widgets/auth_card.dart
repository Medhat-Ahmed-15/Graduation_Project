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
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        height: isKeyboard
            ? 670
            : 530, //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.1)
        decoration: BoxDecoration(
          color: const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 5.0,
              spreadRadius: 5,
              offset: Offset(0.7, 0.7),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _authMode == AuthMode.Signin ? 'Welcome Back' : 'Get Started',
                  style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            _authMode == AuthMode.Signin
                ?
                //SigIn....................................................................................................
                Container(
                    margin: EdgeInsets.all(12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'E-mail/Username',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                    ),
                  )
                : //SignUp........................................................................................................
                Container(
                    margin: EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //General Information title>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Text(
                            'General Information',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //First Name>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'First Name',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: 'Last Name',
                                hintStyle: TextStyle(color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white)),
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
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Address',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            height: 50,
                          ),

                          //Billing Information title>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Text(
                            'Billing Information',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          //Card Holder>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Card Holder',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Security Code',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Credit Card Number',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Expiration Date',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
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
                        ],

                        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                      ),
                    ),
                  ),

            const SizedBox(
              height: 20,
            ),
            //Signin/Signup text and button ...............................................................
            Container(
              margin: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Signin/Signup text>>>>>>>>>>>>>>>>
                  Text(
                    _authMode == AuthMode.Signin ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),

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
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color.fromRGBO(23, 32, 42, 1)
                                    .withOpacity(1),
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(0),
              child: Row(children: [
                //The underlined Signup or Signin text

                FlatButton(
                  child: Text(
                    _authMode == AuthMode.Signin ? 'Sign Up' : 'Sign In',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontSize: 17),
                  ),
                  onPressed: _switchAuthMode,
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
            ),
          ]),
        ),
      ),
    );
  }
}
