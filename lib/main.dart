import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Scan Device Bluetooth'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  late final List<BluetoothDevice> listDeviceResults = [];

  @override
  void initState() {
    scanBluetooth();
    super.initState();
  }

  void scanBluetooth() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        if ((r.device.name).isNotEmpty) {
          //if (listDeviceResults.contains(r.device)) {
          setState(() {
            listDeviceResults.add(r.device);
          });
          //   }
        }
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
  }

  void connectDevice(device) async {
    //Connect to the device
    await device.connect();

    List<BluetoothService> services = await device.discoverServices();

    services.forEach((service) async {
      // Reads all characteristics

      var characteristics = service.characteristics;

      for (BluetoothCharacteristic characteristic in characteristics) {
        List<BluetoothDescriptor> descriptors =
            await characteristic.descriptors;
        // Reads all descriptors
        // print('=====---descriptors----======');
        // print(descriptors.length);
        for (BluetoothDescriptor descriptor in descriptors) {
          print('----descriptor---');
          print(descriptor.value);
          descriptor.value.listen((value) {
            print('----value---');
            print(value.length);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: listDeviceResults.isNotEmpty
                ? ListView.builder(
                    itemCount: 50,
                    itemBuilder: (BuildContext context, int index) => ListTile(
                      title: Text(listDeviceResults[index].name),
                      onTap: () => {connectDevice(listDeviceResults[index])},
                    ),
                  )
                : const Center(
                    child: Text('No Found Device'),
                  ),
          ),
        ],
      ),
    );
  }
}
