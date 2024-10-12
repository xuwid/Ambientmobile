import 'package:ambient/widgets/background_widget.dart';
import 'package:ambient/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:ambient/models/model.dart'; // Update to match your actual model import

class ControllerConfigScreen extends StatefulWidget {
  final Controller device;

  ControllerConfigScreen({required this.device});

  @override
  _ControllerConfigScreenState createState() => _ControllerConfigScreenState();
}

class _ControllerConfigScreenState extends State<ControllerConfigScreen> {
  List<String> wifiNetworks = []; // List to store Wi-Fi networks
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Track the loading state
  bool isConnecting = false; // Track the scanning state

  @override
  void initState() {
    super.initState();
    sendScanRequest();
    listenForScanResponse();
    // Send scan request when screen is on
  }

  // Function to scan for available Wi-Fi networks
  Future<void> sendScanRequest() async {
    setState(() {
      isLoading = true;
    });

    try {
      //wait for 1 second
      await Future.delayed(const Duration(seconds: 1));
      await sendData({"a": "scan"}); // Send scan request to BLE device

      // Wait for the scan result to arrive
      final response = await listenForScanResponse();
      if (response != null && response.containsKey("val")) {
        setState(() {
          wifiNetworks = List<String>.from(response["val"]);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error during scan: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to listen for the scan response
  Future<Map<String, dynamic>?> listenForScanResponse() async {
    try {
      // Listen for the response from the device
      // Replace this with your actual code to listen for incoming Bluetooth data
      BluetoothCharacteristic? characteristic = await findCharacteristic();

      if (characteristic == null) return null;

      await characteristic.setNotifyValue(true);
      final subscription = characteristic.onValueReceived.listen((value) {
        String receivedData = utf8.decode(value);
        Map<String, dynamic> jsonResponse = jsonDecode(receivedData);

        final subscription =
            characteristic.onValueReceived.listen((value) async {
          String receivedData = utf8.decode(value);
          Map<String, dynamic> jsonResponse = jsonDecode(receivedData);

          if (jsonResponse["a"] == "scan-res") {
            // Process the scan response here
            // You can use setState or other methods to update the UI or handle the data
            setState(() {
              wifiNetworks = List<String>.from(jsonResponse["val"]);
              print("Wi-Fi networks found: $wifiNetworks");
              isLoading = false;
            });
          }
        });

        // Optionally, you can handle cancellation or cleanup

        return null;
      });

      await Future.delayed(
          Duration(seconds: 5)); // Wait for 5 seconds for response
    } catch (e) {
      print("Error receiving scan response: $e");
    }
    return null;
  }

  // Function to connect to the characteristic and send data
  Future<void> sendData(Map<String, String> commandData) async {
    try {
      String jsonData = jsonEncode(commandData);
      List<int> bytesToSend = utf8.encode(jsonData);
      BluetoothCharacteristic? characteristic = await findCharacteristic();

      if (characteristic != null) {
        await characteristic.write(bytesToSend, withoutResponse: false);
      }
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  // Function to find the target Bluetooth characteristic
  Future<BluetoothCharacteristic?> findCharacteristic() async {
    List<BluetoothService> services =
        await widget.device.device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            "01920e8a-4248-7564-a1df-a57dde0b7e79") {
          return characteristic;
        }
      }
    }
    return null;
  }

  // Function to send Wi-Fi credentials to BLE device
  Future<void> sendWifiCredentials(String ssid, String password) async {
    setState(() {
      isConnecting = true; // Show loading indicator during connection process
    });
    Map<String, String> data = {
      "a": "wc",
      "n": ssid,
      "p": password,
    };
    await sendData(data); // Send the Wi-Fi credentials to the BLE device
    await listenForWifiConnectionStatus(); // Listen for the connection status
  }

  // Function to listen for Wi-Fi connection status
  Future<void> listenForWifiConnectionStatus() async {
    try {
      BluetoothCharacteristic? characteristic = await findCharacteristic();

      if (characteristic == null) return;

      await characteristic.setNotifyValue(true);
      final subscription = characteristic.onValueReceived.listen((value) {
        String receivedData = utf8.decode(value);
        Map<String, dynamic> jsonResponse = jsonDecode(receivedData);
        print("Received data: $jsonResponse");

        if (jsonResponse["a"] == "ws") {
          setState(() {
            isConnecting =
                false; // Hide the loading indicator after receiving status
          });

          if (jsonResponse["s"] == 1) {
            // Success
            _showDialog("Wi-Fi connected successfully");
          } else {
            // Failure
            _showDialog("Wi-Fi connection failed: ${jsonResponse['e']}");
          }
        }
      });

      await Future.delayed(Duration(seconds: 10)); // Wait for status
    } catch (e) {
      print("Error listening for Wi-Fi status: $e");
      setState(() {
        isConnecting = false; // Hide loading if there's an error
      });
    }
  }

  // Function to show a dialog with a message
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Wi-Fi Connection Status'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show the Wi-Fi SSID and password input dialog
  void showWifiDialog(String ssid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Wi-Fi Credentials'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String password = passwordController.text;
                sendWifiCredentials(ssid, password);

                Navigator.pop(context);
              },
              child: Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Column(
          children: [
            const SizedBox(height: 30),
            AppBar(
              backgroundColor: Colors.transparent,
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
              title: Center(
                child: Text(
                  'Select Wifi',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    sendScanRequest();
                  },
                ),
              ],
            ),
            isLoading
                ? Expanded(child: Center(child: CircularLoadingIndicator()))
                : wifiNetworks.isEmpty
                    ? Center(child: Text('No Wi-Fi networks found'))
                    : ListView.builder(
                        itemCount: wifiNetworks.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            color: const Color.fromARGB(255, 66, 64, 64),
                            child: ListTile(
                              title: Text(
                                wifiNetworks[index],
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                showWifiDialog(wifiNetworks[
                                    index]); // Show Wi-Fi dialog on tap
                              },
                            ),
                          );
                        },
                      ),
            if (isConnecting)
              Expanded(
                child: Center(
                  child: CircularLoadingIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
