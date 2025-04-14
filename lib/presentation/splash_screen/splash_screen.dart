import 'package:flutter/material.dart';
import 'package:os_project_unii/core/theme/app_colors.dart';
import 'package:os_project_unii/presentation/process_generator_screen/process_generator_screen.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = "/splash";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 10),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      // Navigator.pushReplacementNamed(context, ProcessGeneratorScreen.routeName);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  const ProcessGeneratorScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.mainColorBg,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColorBg,
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                height: 200,
                width: 200,
                child: Image.asset("assets/logo.png"),
              ),
            ),
            const Spacer(),
            const Text(
              "Created By Seif Mohsen",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Text(
              "© 2025 All rights reserved.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

// class _SplashScreenState extends State<SplashScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 2),() {
//       Navigator.pushReplacementNamed(context, ProcessGeneratorScreen.routeName);
//     },
//     );
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent, // جعل خلفية الـ Status Bar شفافة
//         statusBarIconBrightness: Brightness.dark, // جعل النص والأيقونات سوداء
//         systemNavigationBarColor: AppColors.mainColorBg, // اختيار لون شريط التنقل (اختياري)
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.mainColorBg,
//       body: Center(
//         child: Column(
//           children: [
//             Spacer(),
//             SizedBox(
//               height: 200,
//               width: 200,
//               child: Image.asset("assets/logo.png"),
//             ),
//             Spacer(),
//             Text("Created By Seif Mohsen",style: TextStyle(fontSize: 12,color: Colors.grey),),
//             Text("© 2025 All rights reserved.",style: TextStyle(fontSize: 13,color: Colors.grey),),
//             SizedBox(height: 25,)
//           ],
//         ),
//       ),
//     );
//   }
// }
