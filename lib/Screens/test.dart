import 'package:dialogs/dialogs.dart';
import 'package:flutter/material.dart';

class MessageDialogExample extends StatefulWidget {
  static const routeName = '/MessageDialogExample';

  MessageDialogExample({Key key}) : super(key: key);

  @override
  _MessageDialogExampleState createState() => _MessageDialogExampleState();
}

class _MessageDialogExampleState extends State<MessageDialogExample> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dialogs'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.blue,
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  // ChoiceDialog().show(context,
                  //     barrierColor: Colors.black, barrierDismissible: true);
                },
                child: Text('Show Choice Dialog')),
            TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.blue,
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  MessageDialog messageDialog = MessageDialog(
                      dialogBackgroundColor: Colors.white,
                      buttonOkColor: Colors.red,
                      title: 'Dialog Title',
                      titleColor: Colors.black,
                      message: 'Dialog Message',
                      messageColor: Colors.black,
                      buttonOkText: 'Ok',
                      dialogRadius: 15.0,
                      buttonRadius: 18.0,
                      iconButtonOk: Icon(Icons.one_k));
                  messageDialog.show(context, barrierColor: Colors.white);
                },
                child: Text(
                  'Show Message Dialog',
                )),

//////////////////////////////////////////////////////////////

            TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.blue,
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  ProgressDialog progressDialog = ProgressDialog(
                    context: context,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                  );

                  progressDialog.show();
                  Future.delayed(Duration(seconds: 3))
                      .then((value) => progressDialog.dismiss());
                },
                child: Text(
                  'Show Progress Dialog',
                )),
          ],
        ),
      ),
    );
  }
}

// import 'package:dotted_line/dotted_line.dart';
// import 'package:flutter/material.dart';

// const String _TITLE = 'DottedLine Demo';

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     final space = SizedBox(height: 50);
//     return Scaffold(
//       appBar: AppBar(title: Text(_TITLE)),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             space,
//             Text("Default"),
//             DottedLine(),
//             space,
//             Text("Dash length changed"),
//             DottedLine(dashLength: 40),
//             space,
//             Text("Dash gap length changed"),
//             DottedLine(dashLength: 30, dashGapLength: 30),
//             space,
//             Text("Line thickness changed"),
//             DottedLine(
//               dashLength: 30,
//               dashGapLength: 30,
//               lineThickness: 30,
//             ),
//             space,
//             Text("Dash radius changed"),
//             DottedLine(
//               dashLength: 30,
//               dashGapLength: 30,
//               lineThickness: 30,
//               dashRadius: 16,
//             ),
//             space,
//             Text("Dash and dash gap color changed"),
//             DottedLine(
//               dashLength: 30,
//               dashGapLength: 30,
//               lineThickness: 30,
//               dashColor: Colors.blue,
//               dashGapColor: Colors.red,
//             ),
//             space,
//             Text("Line direction and line length changed"),
//             DottedLine(
//               dashLength: 30,
//               dashGapLength: 30,
//               lineThickness: 30,
//               dashColor: Colors.blue,
//               dashGapColor: Colors.red,
//               direction: Axis.vertical,
//               lineLength: 150,
//             ),
//             space,
//             Text("Dash gradient changed"),
//             DottedLine(
//               dashGradient: [
//                 Colors.red,
//                 Colors.blue,
//               ],
//               dashLength: 10,
//               lineThickness: 30,
//             ),
//             space,
//             Text("Dash gradient and dash gap gradient changed"),
//             DottedLine(
//               dashGradient: [
//                 Colors.red,
//                 Colors.red.withAlpha(0),
//               ],
//               dashGapGradient: [
//                 Colors.blue,
//                 Colors.blue.withAlpha(0),
//               ],
//               dashLength: 10,
//               dashGapLength: 10,
//               lineThickness: 30,
//             ),
//             space,
//           ],
//         ),
//       ),
//     );
//   }
// }
