import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const HazeBotApp());
}

class HazeBotApp extends StatelessWidget {
  const HazeBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HazeBot Face',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const RobotFaceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RobotFaceScreen extends StatefulWidget {
  const RobotFaceScreen({super.key});

  @override
  State<RobotFaceScreen> createState() => _RobotFaceScreenState();
}

class _RobotFaceScreenState extends State<RobotFaceScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _blinkController;
  late AnimationController _expressionController;
  late AnimationController _bounceController;

  // Animations
  late Animation<double> _blinkAnimation;
  late Animation<double> _expressionAnimation;
  late Animation<double> _bounceAnimation;

  // State variables
  RobotExpression _currentExpression = RobotExpression.happy;
  Color _eyeColor = Colors.cyan;
  Color _mouthColor = Colors.pink;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _blinkController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _expressionController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _bounceController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    // Initialize animations
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.1).animate(CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut));

    _expressionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _expressionController, curve: Curves.elasticOut));

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    // Start periodic blinking
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  void _onTap() {
    setState(() {
      _isPressed = true;
    });

    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // Cycle through expressions
    _cycleExpression();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  void _cycleExpression() {
    final expressions = RobotExpression.values;
    final currentIndex = expressions.indexOf(_currentExpression);
    final nextIndex = (currentIndex + 1) % expressions.length;

    setState(() {
      _currentExpression = expressions[nextIndex];
    });

    _expressionController.forward().then((_) {
      _expressionController.reverse();
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Colors'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Eye Color'),
            Wrap(
              children: [Colors.cyan, Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.red, Colors.yellow, Colors.pink]
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _eyeColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _eyeColor == color ? Border.all(color: Colors.white, width: 3) : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Mouth Color'),
            Wrap(
              children: [Colors.pink, Colors.red, Colors.orange, Colors.purple, Colors.blue, Colors.green, Colors.yellow, Colors.cyan]
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _mouthColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _mouthColor == color ? Border.all(color: Colors.white, width: 3) : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _expressionController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette, color: Colors.white),
            onPressed: _showColorPicker,
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_blinkAnimation, _expressionAnimation, _bounceAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(color: _isPressed ? Colors.white.withOpacity(0.3) : Colors.transparent, blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Eyes
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildEye(isLeft: true), _buildEye(isLeft: false)]),
                      // Mouth
                      _buildMouth(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEye({required bool isLeft}) {
    return Container(
      width: 80,
      height: 80 * _blinkAnimation.value,
      decoration: BoxDecoration(
        color: _eyeColor,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _eyeColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
      ),
      child: _blinkAnimation.value > 0.5 ? _buildPupil(isLeft: isLeft) : null,
    );
  }

  Widget _buildPupil({required bool isLeft}) {
    double pupilOffset = 0;
    double pupilSize = 30;

    switch (_currentExpression) {
      case RobotExpression.happy:
        pupilSize = 25;
        break;
      case RobotExpression.surprised:
        pupilSize = 35;
        break;
      case RobotExpression.sleepy:
        pupilSize = 20;
        pupilOffset = 5;
        break;
      case RobotExpression.excited:
        pupilSize = 30;
        break;
      case RobotExpression.confused:
        pupilOffset = isLeft ? -8 : 8;
        break;
    }

    return Center(
      child: Transform.translate(
        offset: Offset(pupilOffset, pupilOffset),
        child: Container(
          width: pupilSize,
          height: pupilSize,
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          child: Center(
            child: Container(
              width: pupilSize * 0.3,
              height: pupilSize * 0.3,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMouth() {
    return Container(
      width: 120,
      height: 60,
      child: CustomPaint(
        painter: MouthPainter(expression: _currentExpression, color: _mouthColor, animationValue: _expressionAnimation.value),
      ),
    );
  }
}

enum RobotExpression { happy, surprised, sleepy, excited, confused }

class MouthPainter extends CustomPainter {
  final RobotExpression expression;
  final Color color;
  final double animationValue;

  MouthPainter({required this.expression, required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    switch (expression) {
      case RobotExpression.happy:
        _drawHappyMouth(canvas, size, paint, center);
        break;
      case RobotExpression.surprised:
        _drawSurprisedMouth(canvas, size, paint, center);
        break;
      case RobotExpression.sleepy:
        _drawSleepyMouth(canvas, size, paint, center);
        break;
      case RobotExpression.excited:
        _drawExcitedMouth(canvas, size, paint, center);
        break;
      case RobotExpression.confused:
        _drawConfusedMouth(canvas, size, paint, center);
        break;
    }
  }

  void _drawHappyMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    final path = Path();
    path.moveTo(center.dx - 40, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + 20, center.dx + 40, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawSurprisedMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: center, width: 30, height: 40), paint);
  }

  void _drawSleepyMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    canvas.drawLine(Offset(center.dx - 20, center.dy), Offset(center.dx + 20, center.dy), paint);
  }

  void _drawExcitedMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    paint.style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(center.dx - 30, center.dy - 10);
    path.lineTo(center.dx + 30, center.dy - 10);
    path.lineTo(center.dx + 20, center.dy + 15);
    path.lineTo(center.dx - 20, center.dy + 15);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawConfusedMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    final path = Path();
    path.moveTo(center.dx - 30, center.dy - 5);
    path.quadraticBezierTo(center.dx - 10, center.dy + 10, center.dx + 10, center.dy - 5);
    path.quadraticBezierTo(center.dx + 30, center.dy + 10, center.dx + 30, center.dy - 5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
