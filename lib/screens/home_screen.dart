// home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/game_state.dart';
import '../models/quran_models.dart';
import '../widgets/common_widgets.dart';
import 'reading_screen.dart';
import 'quiz_screen.dart';
import 'memorize_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // برای اینکه پس‌زمینه زیر اپ‌بار برود
      appBar: AppBar(
        title: const Text('فهرست درس‌ها',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // دکمه تنظیمات در سمت چپ
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: AppBackground(
        child: Consumer<GameState>(
          builder: (context, gameState, child) {
            if (gameState.isIndexLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            if (gameState.lessonIndex == null ||
                gameState.lessonIndex!.isEmpty) {
              return const Center(
                  child: Text('درسی یافت نشد',
                      style: TextStyle(color: Colors.white)));
            }

            // تعداد آیتم‌ها = تعداد درس‌ها + ۱ (برای کارت پروفایل در بالای لیست)
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
              itemCount: gameState.lessonIndex!.length + 1,
              itemBuilder: (context, index) {
                // نمایش کارت پروفایل و گیمیفیکیشن در اولین آیتم لیست
                if (index == 0) {
                  return FadeInDown(
                    child: _buildUserProfileCard(gameState),
                  );
                }

                // محاسبه ایندکس واقعی درس‌ها
                final lessonIndex = index - 1;
                final lessonInfo = gameState.lessonIndex![lessonIndex];

                return FadeInUp(
                  delay: Duration(milliseconds: lessonIndex * 100),
                  child: _buildGlassLessonCard(
                      context, lessonInfo, gameState, lessonIndex),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- تغییرات نسخه ۲.۰: کارت پروفایل و نمایش امتیاز کاربر ---
  Widget _buildUserProfileCard(GameState gameState) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // بخش سطح و لقب کاربر
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "سطح شما:",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  gameState.userLevelTitle,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // بخش امتیاز عددی
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Text(
                  "${gameState.totalScore}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassLessonCard(BuildContext context, LessonIndex lessonInfo,
      GameState gameState, int index) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _openLesson(context, lessonInfo, gameState),
      child: Row(
        children: [
          // آیکون شماره درس
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                '${lessonInfo.id}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // عنوان درس
          Expanded(
            child: Text(
              lessonInfo.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // آیکون فلش
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ),
        ],
      ),
    );
  }

  // متد باز کردن درس و نمایش جلسات
  void _openLesson(
      BuildContext context, LessonIndex lessonInfo, GameState gameState) {
    // درخواست دانلود محتوای درس
    gameState.loadLessonContent(lessonInfo.fileName);

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // شفاف برای نمایش افکت شیشه‌ای سفارشی
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                // هماهنگ شده با تم رنگی جدید (سبز یشمی)
                color: const Color(0xFF0D231D).withOpacity(0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: Colors.white24, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Consumer<GameState>(
                builder: (context, state, child) {
                  // حالت لودینگ
                  if (state.isLessonLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 15),
                          Text("در حال دریافت محتوای درس...",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }

                  // حالت خطا یا خالی بودن
                  if (state.currentLessonContent == null) {
                    return const Center(
                        child: Text("خطا در دریافت محتوا",
                            style: TextStyle(color: Colors.white)));
                  }

                  final lesson = state.currentLessonContent!;

                  return Column(
                    children: [
                      // دستگیره بالای شیت
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 10),
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // عنوان درس در هدر
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyanAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const Divider(
                          color: Colors.white12, thickness: 1, height: 1),

                      // لیست جلسات
                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(20),
                          itemCount: lesson.sessions.length,
                          itemBuilder: (context, i) {
                            final session = lesson.sessions[i];
                            return FadeInRight(
                              delay: Duration(milliseconds: i * 100),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  leading: Icon(_getSessionIcon(session.type),
                                      color: Colors.amberAccent, size: 28),
                                  title: Text(
                                    session.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  trailing: const Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: Colors.greenAccent,
                                      size: 32),
                                  onTap: () {
                                    Navigator.pop(ctx); // بستن باتم شیت
                                    _navigateToSession(
                                        context, session); // رفتن به صفحه جلسه
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // انتخاب آیکون مناسب برای هر نوع جلسه
  IconData _getSessionIcon(String type) {
    switch (type) {
      case 'reading':
        return Icons.record_voice_over_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'memorize':
        return Icons.psychology_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  // مسیریابی به صفحات مختلف
  void _navigateToSession(BuildContext context, Session session) {
    if (session.type == 'reading') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ReadingScreen(session: session)));
    } else if (session.type == 'quiz') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => QuizScreen(session: session)));
    } else if (session.type == 'memorize') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => MemorizeScreen(session: session)));
    }
  }
}
