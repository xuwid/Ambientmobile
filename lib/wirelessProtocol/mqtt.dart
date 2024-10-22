import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MQTTService {
  final String broker = 'broker.emqx.io'; // MQTT broker URL
  final int port = 1883; // MQTT broker port
  final String clientId = 'dadsddadsad'; // Unique client ID
  late MqttServerClient client;

  // Function pointer for message handling in the provider
  Function(String, List<int>)? onMessage;

  Future<void> _initializeMQTTClient() async {
    client = MqttServerClient.withPort('broker.emqx.io', clientId, 1883)
      ..logging(on: true)
      ..onConnected = onConnected
      ..onDisconnected = onDisconnected
      ..onSubscribed = onSubscribed;
    // ..onSubscribeFail = onSubscribeFail;

    try {
      final connMess = MqttConnectMessage()
          .withClientIdentifier('flutter_client')
          .startClean() // Non persistent session for testing
          .withWillTopic('willtopic')
          .withWillMessage('My Will message')
          .withWillQos(MqttQos.atMostOnce);
      client.connectionMessage = connMess;

      // Connect to the broker
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId)
      ..port = port
      ..logging(on: true)
      ..keepAlivePeriod = 60
      ..onDisconnected = onDisconnected
      ..onConnected = onConnected
      ..onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean() // Clean session
        .withWillTopic('willtopic') // Set last will topic
        .withWillMessage('Client Disconnected') // Will message
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      print('Connecting to broker $broker...');
      await client.connect();
    } on NoConnectionException catch (e) {
      print('MQTT connection failed: $e');
      disconnect();
    } catch (e) {
      print('Connection error: $e');
      disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Connected to $broker');
    } else {
      print('Connection failed - Status: ${client.connectionStatus?.state}');
      disconnect();
    }

    // Listen for incoming messages
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final MqttPublishMessage recMessage =
          event[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      print('Message received on topic ${event[0].topic}: $payload');

      // Call the provider's onMessage function if available
      if (onMessage != null) {
        onMessage!(event[0].topic, recMessage.payload.message);
      }
    });
  }

  void subscribeToTopic(String topic) {
    print('Subscribing to topic $topic...');
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  void publishJsonToTopic(String topic, Map<String, dynamic> json) async {
    // Check if the client is connected
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      // If connected, proceed to publish the JSON message
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(json));
      print('Publishing JSON to topic $topic: $json');
      client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    } else {
      // If not connected, log an error message
      print('Failed to publish JSON to topic $topic: Client is not connected.');

      try {
        // Attempt to reconnect
        print('Attempting to reconnect to broker $broker...');
        await client.connect();

        // Check if the reconnection was successful
        if (client.connectionStatus?.state == MqttConnectionState.connected) {
          print('Reconnected to $broker');

          // Now, attempt to publish the JSON message
          final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
          builder.addString(jsonEncode(json));
          print('Publishing JSON to topic $topic after reconnect: $json');
          client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
        } else {
          print(
              'Reconnection failed - Status: ${client.connectionStatus?.state}');
        }
      } catch (e) {
        // Handle any errors that occur during the reconnect attempt
        print('Reconnection error: $e');
      }
    }
  }

  void publishToTopic(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print('Publishing message "$message" to topic $topic...');
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  void disconnect() {
    print('Disconnecting from broker...');
    client.disconnect();
  }

  void onDisconnected() {
    print('Client disconnected');
  }

  void onConnected() {
    print('Client connected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic $topic');
  }
}
