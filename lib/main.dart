import 'package:apod_viewer/src/content_body.dart';
import 'package:apod_viewer/src/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() => runApp(new MyApp());

// final NASAApi nasaApi;
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: new MyHomePage(title: 'NASA APOD Viewer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static DateTime _selectedDate = DateTime.now();
  String _picDate = _selectedDate.toLocal().toString().substring(0, 10);
  var _shake = false;
  final DateTime _minDate = DateTime(1995, 6, 20);

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() >= 3.0 && !_shake) {
        setState(() {
          // TODO: handle multiple times of shacking
          _picDate = getRandomDate();
          _shake = true;
        });
      }
    }).onDone(null);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: ListView(children: <Widget>[
        ContentBody(picDate: _picDate),
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.date_range),
        onPressed: () {
          showDatePicker(
                  context: context,
                  firstDate: _minDate,
                  lastDate: DateTime.now().toLocal(),
                  initialDate: _selectedDate,
              ).then((DateTime value) {
                _selectedDate = value;
            setState(() {
              _picDate = value.toString().substring(0,10);
            });
          });
        },
      ),
    );
  }
}
