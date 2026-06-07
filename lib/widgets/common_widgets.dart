import 'dart:ui';
import 'package:flutter/material.dart';

// ویجت پس‌زمینه گرادینت برای کل صفحات (نسخه ۲.۰ - تم سبز یشمی و فیروزه‌ای مدرن)
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D231D), // سبز یشمی عمیق و معنوی (جایگزین آبی تیره)
            Color(
                0xFF13947F), // فیروزه‌ای زنده و مدرن (جایگزین فیروزه‌ای روشن سابق)
          ],
        ),
      ),
      child: child,
    );
  }
}

// ویجت کارت شیشه‌ای (Glassmorphism) - هماهنگ شده با تم جدید
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12, // کمی تاری بیشتر برای افکت شیشه‌ای عمیق‌تر روی تم جدید
            sigmaY: 12,
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: width,
              height: height,
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.12), // تعادل شفافیت روی پس‌زمینه سبز
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white
                      .withOpacity(0.25), // حاشیه کمی درخشان‌تر برای تفکیک بهتر
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
