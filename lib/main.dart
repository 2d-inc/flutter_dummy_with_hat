import 'package:dummy_with_hat/lazy_rotation_mounted_gear.dart';

import 'dummy.dart';
import 'mounted_gear.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRunning = false;
  double _speed = 1.0;

  final MountedGear _helmet = LazyRotationMountedGear("assets/Hat_1.flr",
      alignmentNode: "hat_1",
      targetShape: "hat_target",
      lazyNodes: [
        LazyNode("hat_1", laziness:0.9, restitution: 12.0),
      ]);

  final MountedGear _cap = MountedGear("assets/Hat_2.flr",
      alignmentNode: "hat_2", targetShape: "hat_target");

  final MountedGear _stars = LazyRotationMountedGear("assets/Hat_3.flr",
      alignmentNode: "hat_3",
      targetShape: "hat_target",
      lazyNodes: [
        LazyNode("star_hat_center", laziness:0.3, restitution:2.0),
        LazyNode("star_hat_star_right", laziness:3.9, restitution:12.0),
        LazyNode("star_hat_star_left", laziness:3.7, restitution:12.0),
      ]);

  final MountedGear _hair = LazyRotationMountedGear("assets/Hat_4.flr",
      alignmentNode: "hat_4",
      targetShape: "hat_target",
      lazyNodes: [
        LazyNode("root_hair_body", laziness:0.2, restitution: 4.0),
        LazyNode("Bone", laziness:1.3, restitution: 8.0),
      ]);

  MountedGear _selectedMountedGear;

  @override
  void initState() {
    _selectedMountedGear = _helmet;
    super.initState();
  }

  void _toggleRunning(bool isRunning) {
    setState(() {
      _isRunning = isRunning;
    });
  }

  void _changeSpeed(double speed) {
    setState(() {
      _speed = speed;
    });
  }

  void _changeMountedGear(MountedGear gear) {
    setState(() {
      _selectedMountedGear = gear;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: Dummy(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                isRunning: _isRunning,
                speed: _speed,
                mountedItem: _selectedMountedGear,
              ),
            ),
          ),
          Container(
              color: Color.fromRGBO(255, 255, 255, 0.8),
              child: Column(children: [
                CheckboxListTile(
                    title: Text("Running"),
                    value: _isRunning,
                    onChanged: _toggleRunning),
                ListTile(
                  title: Row(
                    children: [
                      Text("Speed"),
                      Expanded(
                        child: Slider(
                            label: "Speed",
                            value: _speed,
                            onChanged: _changeSpeed,
                            min: 0.1,
                            max: 2.0),
                      )
                    ],
                  ),
                ),
                RadioListTile<MountedGear>(
                  title: const Text('Helmet'),
                  value: _helmet,
                  groupValue: _selectedMountedGear,
                  onChanged: _changeMountedGear,
                ),
                RadioListTile<MountedGear>(
                  title: const Text('Hair'),
                  value: _hair,
                  groupValue: _selectedMountedGear,
                  onChanged: _changeMountedGear,
                ),
                RadioListTile<MountedGear>(
                  title: const Text('Stars'),
                  value: _stars,
                  groupValue: _selectedMountedGear,
                  onChanged: _changeMountedGear,
                ),
                RadioListTile<MountedGear>(
                  title: const Text('Cap'),
                  value: _cap,
                  groupValue: _selectedMountedGear,
                  onChanged: _changeMountedGear,
                ),
                SizedBox(height: 50)
              ]))
        ],
      ),
    );
  }
}
