import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Start Trial Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrialPage(),
    );
  }
}

class TrialPage extends StatefulWidget {
  @override
  _TrialPageState createState() => _TrialPageState();
}

class _TrialPageState extends State<TrialPage> {
  bool _trialStarted = false;
  DateTime? _trialEndDate;

  void _startTrial() {
    setState(() {
      
    });(() {
      _trialStarted = true;
      _trialEndDate = DateTime.now().add(Duration(days: 4));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Trial'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_trialStarted)
              Text(
                'Trial ends on: ${_trialEndDate!.toLocal()}',
                style: TextStyle(fontSize: 20),
              )
            else
              Text(
                'Start your 7-day free trial',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _trialStarted ? null : _startTrial,
              child: Text(_trialStarted ? 'Trial Started' : 'Start Trial'),
            ),
          ],
        ),
      ),
    );
  }
}