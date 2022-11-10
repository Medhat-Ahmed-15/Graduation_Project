import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PolicyDialog extends StatelessWidget {
  final String mdFileName;

  PolicyDialog({@required this.mdFileName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        height: 600,
        child: Column(
          children: [
            Expanded(
                child: FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 150))
                        .then((value) {
                      return DefaultAssetBundle.of(context)
                          .loadString('assets/$mdFileName');
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Markdown(
                          data: snapshot.data,
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    })),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    overlayColor: MaterialStateProperty.all(
                        Theme.of(context).scaffoldBackgroundColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.headline1.color,
                        fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
