import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VideoCamPage extends StatefulWidget {
  final bool isDark;

  VideoCamPage({Key? key, required this.isDark}) : super(key: key);

  @override
  _VideoCamPageState createState() => _VideoCamPageState();
}

class _VideoCamPageState extends State<VideoCamPage> {
  WebSocketChannel? channel;
  bool connectionError = false;

  @override
  void initState() {
    super.initState();
    initializeWebSocket();
  }

  void initializeWebSocket() {
    channel = IOWebSocketChannel.connect('ws://192.168.127.1:12345');

    channel!.stream.listen(
      (message) {
        // Handle incoming messages
      },
      onDone: () {
        // Handle the connection being closed
        if (!connectionError) {
          setState(() {
            connectionError = true;
          });
        }
      },
      onError: (error) {
        // Handle errors
        setState(() {
          connectionError = true;
        });
      },
    );
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  void startVideoStream() {
    channel?.sink.add('START_STREAM');
  }

  void stopVideoStream() {
    channel?.sink.add('STOP_STREAM');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Camera'),
        backgroundColor: widget.isDark ? Colors.black : Colors.white,
        iconTheme:
            IconThemeData(color: widget.isDark ? Colors.white : Colors.black),
      ),
      body: Center(
        child: connectionError ? buildErrorContent() : buildStreamContent(),
      ),
    );
  }

  Widget buildErrorContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Failed to connect to the server.',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              initializeWebSocket();
            });
          },
          child: const Text('Retry Connection'),
        ),
      ],
    );
  }

  Widget buildStreamContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: startVideoStream,
          child: const Text('Start Stream'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: stopVideoStream,
          child: const Text('Stop Stream'),
        ),
        const SizedBox(height: 20),
        // Placeholder for the video stream.
        // You'll need to replace this with a widget that can display the video stream.
        Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          height: MediaQuery.of(context).size.width *
              0.5, // 50% of screen width for aspect ratio
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Video Stream Placeholder',
              style:
                  TextStyle(color: widget.isDark ? Colors.white : Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
