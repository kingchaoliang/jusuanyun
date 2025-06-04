import 'package:flutter/material.dart';
import 'dart:math' as math;

class TechTheme {
  // 颜色定义
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color primaryBlue = Color(0xFF0080FF);
  static const Color primaryGreen = Color(0xFF00FF80);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color borderColor = Color(0xFF333333);
  
  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryGreen],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
  );
  
  // 阴影效果
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryBlue.withOpacity(0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];
  
  // 按钮样式
  static BoxDecoration get buttonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: glowShadow,
  );
  
  // 卡片样式
  static BoxDecoration get cardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
  );
  
  // 文本样式
  static const TextStyle titleStyle = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );
  
  static const TextStyle buttonStyle = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

// 科技感粒子效果组件
class TechParticleBackground extends StatefulWidget {
  final Widget child;
  
  const TechParticleBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  State<TechParticleBackground> createState() => _TechParticleBackgroundState();
}

class _TechParticleBackgroundState extends State<TechParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final int _particleCount = 50;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _generateParticles();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.1 + random.nextDouble() * 0.3,
        size: 1 + random.nextDouble() * 3,
        opacity: 0.3 + random.nextDouble() * 0.4,
      ));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 粒子背景
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(_particles, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        // 前景内容
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;
  
  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  
  ParticlePainter(this.particles, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TechTheme.primaryBlue.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      // 更新粒子位置
      particle.y = (particle.y + particle.speed * 0.01) % 1.0;
      
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      
      paint.color = TechTheme.primaryBlue.withOpacity(particle.opacity * 0.6);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}