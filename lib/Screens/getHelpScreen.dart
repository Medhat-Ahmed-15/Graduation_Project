// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GetHelpScreen extends StatefulWidget {
  static const routeName = '/GetHelpScreen';

  @override
  State<GetHelpScreen> createState() => _GetHelpScreenState();
}

class _GetHelpScreenState extends State<GetHelpScreen> {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  ColorProvider colorProviderObj;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('GoPark Customer  Servive'),
    );

    return Scaffold(
      backgroundColor: colorProviderObj.generalCardColor,
      appBar: appBar,
      drawer: MainDrawer(),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Container()),
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset('assets/images/help.png'),
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              'How can we help you ?',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: colorProviderObj.textColor),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'It looks like you are experiencing problems with our service. We are here to help so please get in touch with us',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colorProviderObj.textColor),
            ),
            const SizedBox(
              height: 82,
            ),
            FlatButton(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 50,
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Call Us 📞',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              onPressed: () async {
                try {
                  var url = Uri.parse("tel:9776765434");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                } catch (error) {
                  Fluttertoast.showToast(
                      msg: 'An error occurred,Please try again later',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 5,
                      backgroundColor: Colors.grey[500],
                      textColor: Colors.black,
                      fontSize: 16.0);
                }
              },
            ),
            const SizedBox(
              height: 7,
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
