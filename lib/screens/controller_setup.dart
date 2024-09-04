import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

class ControllerSetup extends StatefulWidget {
  @override
  _ControllerSetupState createState() => _ControllerSetupState();
}

class _ControllerSetupState extends State<ControllerSetup>
    with TickerProviderStateMixin {
  String selectedOption = 'Type of IC Setting';
  bool isOpen = false;

  final List<String> networkOptions = [
    'Common',
    'SM16703P',
    'WS2812E',
    'UC1903B',
    'UCS2904',
    'Common RGBW'
  ];

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
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 80,
                flexibleSpace: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.0),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const Icon(
                          Icons.alarm,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Controller Setup',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Color(0x40000000),
                      borderRadius: BorderRadius.circular(15),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // Dropdown for IC settings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedOption,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isOpen = !isOpen;
                                  });
                                },
                                child: Icon(
                                  isOpen
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Visibility(
                              visible: isOpen,
                              child: Column(
                                children: List.generate(networkOptions.length,
                                    (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedOption =
                                              networkOptions[index];
                                          isOpen = false;
                                        });
                                      },
                                      child: Text(
                                        networkOptions[index],
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Network settings section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedNetwork.isEmpty
                                    ? 'Select WiFi Network'
                                    : _selectedNetwork,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh, color: Colors.white),
                                onPressed: _scanNetworks,
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _networks.length,
                              itemBuilder: (context, index) {
                                final network = _networks[index];
                                return ListTile(
                                  title: Text(
                                    network.ssid!,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedNetwork = network.ssid!;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _selectedNetwork.isEmpty
                                ? null
                                : () async {
                                    // Connect to the selected network
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
