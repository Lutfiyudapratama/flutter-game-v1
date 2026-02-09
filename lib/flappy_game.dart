import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class FlappyGame extends FlameGame with TapDetector {
  //bird
  double birdY = 300;
  double velocity = 0;
  final double gravity = 900;
  final double jumpForce = -300;

  //pipe
  double pipeX = 400;
  double pipeGap = 180;
  double pipeHeight = 200;

  int score = 0;
  bool gameOver = false;

  late ui.Image birdImage;
  late ui.Image pipeImage;
  late ui.Image bgImage;
  // late ui.Image pipesv2Image;

  @override
  Future<void> onLoad() async {
    birdImage = await images.load('bird.png');
    pipeImage = await images.load('pipes.png');
    bgImage = await images.load('background.png');
    // pipesv2Image = await images.load('pipesv2.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver) return;

    velocity += gravity * dt;
    birdY += velocity * dt;

    pipeX -= 200 * dt;
    if (pipeX < -80) {
      pipeX = size.x;
      pipeHeight = Random().nextDouble() * 300 + 50;
      score++;
    }
    if (birdY < 0 || birdY > size.y - 40) {
      gameOver = true;
    }

    if (pipeX < 120 && pipeX + 80 > 80) {
      if (birdY < pipeHeight || birdY + 40 > pipeHeight + pipeGap) {
        gameOver = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    //background
    canvas.drawImageRect(
      bgImage,
      Rect.fromLTWH(0, 0, bgImage.width.toDouble(), bgImage.height.toDouble()),
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint(),
    );

    //bird
    canvas.drawImageRect(
      birdImage,
      Rect.fromLTWH(
        0,
        0,
        birdImage.width.toDouble(),
        birdImage.height.toDouble(),
      ),
      Rect.fromLTWH(80, birdY, 40, 40),
      Paint(),
    );
    //pipes atas
    canvas.save();

    canvas.translate(pipeX + 40, pipeHeight);
    canvas.scale(1, -1);

    canvas.drawImageRect(
      pipeImage,
      Rect.fromLTWH(
        0,
        0,
        pipeImage.width.toDouble(),
        pipeImage.height.toDouble(),
      ),
      Rect.fromLTWH(-40, 0, 80, pipeHeight),
      Paint(),
    );

    canvas.restore();

    //pipe bawah
    canvas.drawImageRect(
      pipeImage,
      Rect.fromLTWH(
        0,
        0,
        pipeImage.width.toDouble(),
        pipeImage.height.toDouble(),
      ),
     Rect.fromLTWH(pipeX, pipeHeight + pipeGap, 80, size.y - (pipeHeight + pipeGap),),
      Paint(),
    );

    _drawText(canvas, 'Score: $score', 20, 20);

    if (gameOver) {
      _drawText(canvas, 'Game Over', size.x / 2 - 80, size.y / 2);
      _drawText(canvas, 'Tap to Restart', size.x / 2 - 100, size.y / 2 + 40);
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (gameOver) {
      resetGame();
    } else {
      velocity = jumpForce;
    }
  }

  void resetGame() {
    birdY = 300;
    velocity = 0;
    pipeX = size.x;
    score = 0;
    gameOver = false;
  }

  void _drawText(Canvas canvas, String text, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }
}
