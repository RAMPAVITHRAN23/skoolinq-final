import 'package:flutter/material.dart';
import 'package:skoolinq_project/Account/checkAuth.dart';
import 'Account/intro.dart';

class AnimationScreen extends StatelessWidget {
  const AnimationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleSlideAnimation;
  late Animation<double> _circleSizeAnimation;
  late Animation<double> _circleExpandAnimation;
  late Animation<double> _logoExpandAnimation;
  late Animation<double> _logoOpacityAnimation;

  final Color customBlue = const Color(0xFF176ADA); // Updated blue color
  bool showSecondLogo = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _circleSlideAnimation = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );
    _circleSizeAnimation = Tween<double>(begin: 100, end: 206).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );

    _circleExpandAnimation = Tween<double>(begin: 206, end: 400).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.7)),
    );

    _logoExpandAnimation = Tween<double>(begin: 100, end: 800).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)),
    );

    _logoOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0)),
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showSecondLogo = true;
        });

        // Delayed navigation to allow the second logo to display
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CheckAuth()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!showSecondLogo) ...[
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double circleSize = _controller.value > 0.5
                      ? _circleExpandAnimation.value
                      : _circleSizeAnimation.value;

                  // Adjust circle size for smaller screens
                  final adjustedCircleSize = circleSize *
                      (screenWidth < 400
                          ? 0.8
                          : 1.0); // Scale for smaller widths

                  return Transform.translate(
                    offset: Offset(0, _circleSlideAnimation.value),
                    child: Container(
                      width: adjustedCircleSize,
                      height: adjustedCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: customBlue,
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double logoScale = _controller.value > 0.7
                      ? _logoExpandAnimation.value / 100
                      : 1.0;

                  return Transform.scale(
                    scale: logoScale,
                    child: Opacity(
                      opacity: _controller.value > 0.8
                          ? _logoOpacityAnimation.value
                          : 1.0,
                      child: Image.asset(
                        'assets/skoolinq logo1.png', // Replace with your first logo path
                        width: 100 *
                            (screenWidth < 400 ? 0.8 : 1.0), // Adjust logo size
                        color: Colors.white, // First logo in white
                      ),
                    ),
                  );
                },
              ),
            ],
            if (showSecondLogo)
              Image.asset(
                'assets/skoolinq logo2.png', // Replace with your second logo path
                width: 250 *
                    (screenWidth < 400 ? 0.8 : 1.0), // Adjust second logo size
                height: 250 * (screenWidth < 400 ? 0.8 : 1.0),
              ),
          ],
        ),
      ),
    );
  }
}
