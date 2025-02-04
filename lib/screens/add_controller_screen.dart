import 'dart:developer';

import 'package:ambient/screens/controller_configure.dart';
import 'package:ambient/screens/controller_port.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:ambient/widgets/loading_indicator.dart'; // Your circular loading indicator widget
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // flutter_blue for BLE scanning
import 'package:permission_handler/permission_handler.dart'; // permission_handler for requesting Bluetooth permissions
import 'dart:convert';
import 'package:ambient/models/state_models.dart'; // Your model
import 'package:provider/provider.dart';

class AddControllerScreen extends StatefulWidget {
  const AddControllerScreen({Key? key}) : super(key: key);

  @override
  _AddControllerScreenState createState() => _AddControllerScreenState();
}

class _AddControllerScreenState extends State<AddControllerScreen> {
  List<Controller> controllerList = [];
  List<BluetoothDevice> devicesList = [];
  bool isScanning = false;
  final String SERVICE_UUID = "01920e8a-4248-7de9-b2f8-af5040efa778";
  final String DATA_CHAR_UUID = "01920e8a-4248-7564-a1df-a57dde0b7e79";
  final String KEY = "01920e8a-4248-7bf3-9a78-e63b31ee2b5b";

  @override
  void initState() {
    super.initState();
    requestPermissionsAndStartScan();
  }

  //dispose method
  @override
  void dispose() {
    //  stopScan();
    super.dispose();
  }

  Future<void> requestPermissionsAndStartScan() async {
    // Request Bluetooth permissions
    if (await Permission.bluetooth.request().isGranted &&
        await Permission.location.request().isGranted) {
      startScan(); // Start scanning if permissions are granted
    } else {
      // Handle permission denial
      print('Bluetooth or Location permission denied');
    }
  }

  void startScan() {
    setState(() {
      devicesList.clear();
      controllerList.clear();
      isScanning = true; // Keep scanning state true until scan is complete
    });

    // Start scanning for nearby BLE devices
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      withServices: [Guid(SERVICE_UUID)],
    ).then((_) async {
      await Future.delayed(const Duration(seconds: 4));
      setState(() {
        isScanning = false;
      });
    });

    // Listen for scan results

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          if (result.device.name.isNotEmpty) {
            setState(() {
              print('Device: ${result.device.name}');
              devicesList.add(result.device);
              controllerList.add(Controller(
                  name: result.device.advName, device: result.device));
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 66, 64, 64).withOpacity(0.9),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              title: Text(
                'Add Controller',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: startScan,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Make sure the controller is plugged in and your lights are connected to the controller',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: isScanning
                    ? CircularLoadingIndicator() // Display the loading indicator during scan
                    : controllerList.isEmpty
                        ? const Text(
                            'No devices found',
                            style: TextStyle(color: Colors.white),
                          )
                        : ListView.builder(
                            //Make the contrllerList equal to the devicesList

                            itemCount: controllerList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Card(
                                  color: const Color.fromARGB(255, 66, 64, 64)
                                      .withOpacity(0.9),
                                  child: ListTile(
                                    title: controllerList[index].device != null
                                        ? Text(
                                            controllerList[index]
                                                    .device!
                                                    .advName
                                                    .isNotEmpty
                                                ? controllerList[index]
                                                    .device!
                                                    .advName
                                                : 'Unknown Device',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )
                                        : Text(
                                            controllerList[index].name,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                    subtitle:
                                        controllerList[index].device != null
                                            ? Text(
                                                controllerList[index]
                                                    .device!
                                                    .remoteId
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey[400]),
                                              )
                                            : null,
                                    onTap: () {
                                      print(
                                          'Selected controller: ${controllerList[index].name}');
                                      Provider.of<HomeState>(context,
                                              listen: false)
                                          .setCurrentController(
                                              controllerList[index]);
                                      print(
                                          'Selected controller: ${controllerList[index].name}');
                                      if (controllerList[index].device != null)
                                        connectToDevice(
                                            controllerList[index].device!);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ControllerConfigScreen(
                                            device: Provider.of<HomeState>(
                                                    context,
                                                    listen: false)
                                                .currentController,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      if (device.isConnected) {
        print("Connected to device: ${device.name}");
      }
      await updateMTU(device);
      await afterConnectionSendData(device);
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  Future<void> updateMTU(BluetoothDevice device) async {
    try {
      int mtu = await device.requestMtu(512);
      print("MTU: $mtu");
    } catch (e) {
      print("Error requesting MTU: $e");
    }
  }

  Future<void> afterConnectionSendData(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? targetCharacteristic;

      for (BluetoothService service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() == DATA_CHAR_UUID) {
              targetCharacteristic = characteristic;
              break;
            }
          }
        }
        if (targetCharacteristic != null) break;
      }

      if (targetCharacteristic == null) {
        print("Characteristic not found!");
        return;
      }

      await targetCharacteristic.setNotifyValue(true);
      final subscription = targetCharacteristic.onValueReceived.listen((value) {
        String receivedData = utf8.decode(value);

        try {
          print("Received data: sdk $receivedData");

          Map<String, dynamic> jsonResponse = jsonDecode(receivedData);
          if (jsonResponse.containsKey("a") && jsonResponse["a"] == "mac") {
            String macAddress = jsonResponse["mac"];
            Provider.of<HomeState>(context, listen: false)
                .setCurrentControllerID(macAddress);

            print("MAC Address: $macAddress");
          }
        } catch (e) {
          print("Error parsing JSON: $e");
        }
      });

      Future<void> sendData(Map<String, String> commandData) async {
        String jsonData = jsonEncode(commandData);
        List<int> bytesToSend = utf8.encode(jsonData);
        await targetCharacteristic!.write(bytesToSend, withoutResponse: false);
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await sendData({"a": "key", "key": KEY});
      await Future.delayed(const Duration(milliseconds: 300));
      await sendData({"a": "gm"});
      device.cancelWhenDisconnected(subscription);
    } catch (e) {
      print("Error during Bluetooth communication: $e");
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeState(),
      child: const MaterialApp(
        home: AddControllerScreen(),
      ),
    ),
  );
}
