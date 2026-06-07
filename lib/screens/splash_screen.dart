// splash_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // برای انیمیشن‌های جذاب
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_widgets.dart';
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
      body: AppBackground(
        child: Stack(
          children: [
            // ۱. ذرات معلق تزئینی در پس‌زمینه برای ایجاد عمق
            ..._buildBackgroundDecorations(),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ۲. بخش آیکون درخشان
                  _buildGlowingIcon(),

                  const SizedBox(height: 50),

                  // ۳. عبارت بسم الله با انیمیشن ظهور نرم
                  FadeInDown(
                    duration: const Duration(seconds: 2),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                      style: GoogleFonts.amiri(
                        fontSize: 26,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              color: Colors.amberAccent.withOpacity(0.5),
                              blurRadius: 15)
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ۴. عنوان اصلی برنامه
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      'آموزش قرآن ششم',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: const [
                          Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 5),
                              blurRadius: 10),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ۵. زیرعنوان (نسخه ۲.۰)
                  FadeInUp(
                    delay: const Duration(milliseconds: 1200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.amberAccent.withOpacity(0.5)),
                      ),
                      child: Text(
                        'ویژه  1405 - نسخه ۲.۰',
                        style: GoogleFonts.vazirmatn(
                          color: Colors.amberAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // ۶. لودینگ شیشه‌ای و مدرن
                  _buildModernLoader(),
                ],
              ),
            ),

            // نام سازنده در پایین صفحه
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeInUp(
                delay: const Duration(seconds: 2),
                child: Text(
                  'طراحی و توسعه: حمیدرضا علی میرزائی',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white38,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ویجت آیکون درخشان با انیمیشن ضربان
  Widget _buildGlowingIcon() {
    return Pulse(
      infinite: true,
      duration: const Duration(seconds: 3),
      child: ZoomIn(
        duration: const Duration(seconds: 2),
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amberAccent.withOpacity(0.2),
                blurRadius: 50,
                spreadRadius: 20,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // رینگ‌های تزئینی دور آیکون
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 2),
                ),
              ),
              // آیکون اصلی
              GlassCard(
                padding: const EdgeInsets.all(30),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // لودینگ خطی مدرن
  Widget _buildModernLoader() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'در حال آماده‌سازی محتوا...',
            style: GoogleFonts.vazirmatn(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ساخت ذرات معلق در پس‌زمینه
  List<Widget> _buildBackgroundDecorations() {
    return [
      _positionParticle(top: 100, left: 50, size: 80, opacity: 0.05),
      _positionParticle(top: 400, right: -30, size: 150, opacity: 0.03),
      _positionParticle(bottom: 100, left: -20, size: 100, opacity: 0.04),
      _positionParticle(top: 200, right: 100, size: 40, opacity: 0.06),
    ];
  }

  Widget _positionParticle(
      {double? top,
      double? left,
      double? right,
      double? bottom,
      required double size,
      required double opacity}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: FadeIn(
        duration: const Duration(seconds: 3),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}
