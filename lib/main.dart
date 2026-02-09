import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/flappy_game.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(GameWidget(game: FlappyGame()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent), 
      ),
      home: const GameScreen(title: 'Game Screen'),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});
  final String title;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebSocketChannel channel;
  Map<String, dynamic> players = {};

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.220.176:8080'),
    );

    channel.stream.listen((data) {
      final msg = jsonDecode(data);
      if (msg['type'] == 'state') {
        print('Players: ${msg['players']}');
        setState(() {
          players = Map<String, dynamic>.from(msg['players']);
        });
      }
    });
  }

  void move(double dx, double dy) {
    channel.sink.add(jsonEncode({
      'type': 'move',
      'dx': dx,
      'dy': dy,
    }));
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Color parseColor (String color) {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: Container(
        color: Colors.white, 
        child: Stack(
          children: players.entries.map((entry) {
            final player = entry.value;
            return Positioned(
             left: (player['x'] as num).toDouble(),
             top: (player['y'] as num).toDouble(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2), 
                ),
              ),
            );
          }).toList(),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () => move(-5, 0),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_drop_up),
                  onPressed: () => move(0, -5),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: () => move(0, 5),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () => move(5, 0),
            ),
          ],
        ),
      ),
    );
  }
}