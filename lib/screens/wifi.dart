import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

class Network extends StatefulWidget {
  @override
  _NetworkState createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  List<WifiNetwork> _networks = [];
  bool _isScanning = false;
  String _selectedNetwork = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      // Handle permission denied
    }
  }

  Future<void> _scanNetworks() async {
    setState(() {
      _isScanning = true;
    });
    List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _networks = networks;
      _isScanning = false;
    });
  }

  Future<void> _connectToNetwork(String ssid, String password) async {
    await WiFiForIoTPlugin.connect(ssid,
        password: password, security: NetworkSecurity.WPA);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff161616),
              Color(0xffA427CA),
            ],
            stops: [0.6, 1.0],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                child: Text(
                  'Network Password',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                height: 51,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFF606060),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: DropdownButton<String>(
                        value:
                            _selectedNetwork.isEmpty ? null : _selectedNetwork,
                        hint: Text('Select WiFi Network',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        dropdownColor: Color(0xFF606060),
                        items: _networks.map((network) {
                          return DropdownMenuItem<String>(
                            value: network.ssid,
                            child: Text(network.ssid!,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedNetwork = value ?? '';
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.white),
                      onPressed: () {
                        // Handle cancel action
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _selectedNetwork.isEmpty
                    ? null
                    : () async {
                        // Connect to the selected network (replace 'YourPassword' with actual password)
                        await _connectToNetwork(
                            _selectedNetwork, 'YourPassword');
                      },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 51),
                ),
                child: Text(
                  'Connect',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _scanNetworks,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 51),
                ),
                child: Text(
                  'Scan for Networks',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
