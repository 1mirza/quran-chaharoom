// splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // برای انیمیشن‌های جذاب
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // تایمر ۵ ثانیه‌ای برای تجربه‌ی کامل بصری اسپلش
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استفاده از یک گرادینت آبی روشن و شاداب اختصاصی برای کلاس چهارم
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0288D1), // آبی روشن و شاد
              Color(0xFF01579B), // آبی تیره‌تر اقیانوسی
            ],
          ),
        ),
        child: Stack(
          children: [
            // ۱. ذرات معلق تزئینی در پس‌زمینه برای ایجاد عمق
            ..._buildBackgroundDecorations(),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // آیکون کتاب/قرآن با افکت زوم
                  ZoomIn(
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white30, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // عنوان اپلیکیشن (تغییر نام به قرآن چهارم)
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      'آموزش قرآن چهارم',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // نمایش نسخه با طراحی شیک طلایی (نسخه 1.0)
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300), // زرد/طلایی کهربایی
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'نسخه ۱.۰',
                        style: GoogleFonts.vazirmatn(
                          color: const Color(
                              0xFF01579B), // متن آبی تیره روی پس‌زمینه طلایی
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // بخش لودینگ در پایین صفحه
            Positioned(
              bottom: 60,
              left: 50,
              right: 50,
              child: FadeInUp(
                delay: const Duration(milliseconds: 1200),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'در حال آماده‌سازی محتوای کلاس چهارم...',
                      style: GoogleFonts.vazirmatn(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ساخت ذرات معلق شیشه‌ای در پس‌زمینه
  List<Widget> _buildBackgroundDecorations() {
    return [
      _positionParticle(top: 100, left: 50, size: 80, opacity: 0.08),
      _positionParticle(top: 400, right: -30, size: 150, opacity: 0.05),
      _positionParticle(bottom: 150, left: -20, size: 100, opacity: 0.06),
      _positionParticle(top: 200, right: 100, size: 40, opacity: 0.1),
    ];
  }

  Widget _positionParticle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}
