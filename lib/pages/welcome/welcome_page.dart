import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE85C53);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Logo EM con diseño de estrella/sol
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: StarBadgePainter(),
                    child: const Center(
                      child: Text(
                        'EM',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Título
              const Center(
                child: Text(
                  'Bienvenido a EventMaster',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Botones
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/sign-up');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.toNamed('/sign-in');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: coral, width: 1.5),
                        foregroundColor: coral,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class StarBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE85C53)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.7;
    final spikes = 16;

    final path = Path();

    for (int i = 0; i < spikes * 2; i++) {
      final angle = (i * 3.14159) / spikes;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * 0.95 * cos(angle - 3.14159 / 2);
      final y = center.dy + radius * 0.95 * sin(angle - 3.14159 / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  double cos(double angle) => _cos(angle);
  double sin(double angle) => _sin(angle);

  double _cos(double angle) {
    // Aproximación de coseno usando serie de Taylor
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -angle * angle / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sin(double angle) {
    // Aproximación de seno usando serie de Taylor
    double result = angle;
    double term = angle;
    for (int i = 1; i <= 10; i++) {
      term *= -angle * angle / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}