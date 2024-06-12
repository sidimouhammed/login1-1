import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:url_launcher/url_launcher.dart';

class UpDate extends StatefulWidget {
  const UpDate({super.key});

  @override
  State<UpDate> createState() => _UpDateState();
}

class _UpDateState extends State<UpDate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text('Contacts'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(Colors.blueAccent),
                  ),
                  onPressed: () {
                    //launchUrl('https://www.google.com' as Uri);
                    //launchUrl('tel:+22231124690' as Uri);
                    // ignore: deprecated_member_use
                    launch('tel:+222 42177047');
                  },
                  child: const Text('Call')),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(Colors.blueAccent),
                  ),
                  onPressed: () {
                    //launchUrl('https://www.google.com' as Uri);
                    //launchUrl('tel:+22231124690' as Uri);
                    // ignore: deprecated_member_use
                    launch(
                        'sms:+22242177047?body=Bonjour Je veut change mon email ou numero de tel');
                  },
                  child: const Text('Send SMS')),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(Colors.blueAccent),
                  ),
                  onPressed: () {
                    //launchUrl('https://www.google.com' as Uri);
                    //launchUrl('tel:+22231124690' as Uri);
                    // ignore: deprecated_member_use
                    launch('mailto:yenjahsidina123@gmail.com?subject=change');
                  },
                  child: const Text('Send email')),
            ]),
          ),
        ));
  }
}
