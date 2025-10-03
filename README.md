# Ambient

**Ambient** is a Flutter application (iOS & Android) that interfaces with custom LED light strips via **Bluetooth Low Energy (BLE)** and **MQTT**. With a sleek, modern design, Ambient enables real-time control and visualization of your lighting setup powered by Arduino or other microcontrollers.

---

## 🚀 Features

- Cross-platform: works on both **iOS** and **Android**  
- BLE communication to directly control local LED strips  
- MQTT support for remote / cloud-based control  
- Smooth, aesthetic UI for managing lights, colors, animations  
- Device discovery, connectivity status, reconnection logic  
- Support for dynamic scenes, presets, transitions  

---

## 🧩 Architecture & Communication Flow

Here’s how the components interact:

1. **Flutter App (Ambient)**  
   - Scans for BLE devices (your LED controllers)  
   - Connects and exchanges data (e.g. color, mode)  
   - Publishes / subscribes via MQTT to propagate commands remotely  

2. **LED Controller (Arduino / custom hardware)**  
   - Talks over BLE to receive commands  
   - May also subscribe to MQTT topics (via a WiFi module)  
   - Drives the LED strip accordingly  

3. **MQTT Broker / Cloud**  
   - Acts as a message bridge (for remote control, status updates)  
   - The app and hardware can stay synchronized  

Below is a simplified diagram:

