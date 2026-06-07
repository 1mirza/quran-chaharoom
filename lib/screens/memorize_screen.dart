// memorize_screen.dart
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quran_models.dart';
import '../providers/game_state.dart';
import '../widgets/common_widgets.dart';

class MemorizeScreen extends StatefulWidget {
  final Session session;
  const MemorizeScreen({super.key, required this.session});

  @override
  State<MemorizeScreen> createState() => _MemorizeScreenState();
}

class _MemorizeScreenState extends State<MemorizeScreen> {
  // --- تغییرات نسخه ۲.۰: رهگیری کلماتی که کاربر درست حدس زده است ---
  final Set<int> _solvedWordIndices = {};

  GameState? _gameState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameState = Provider.of<GameState>(context, listen: false);
  }

  @override
  void dispose() {
    _gameState?.stopAudio();
    super.dispose();
  }

  // متد کمکی برای پاکسازی علائم نگارشی جهت مقایسه بهتر کلمات
  String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  // --- تغییرات نسخه ۲.۰: نمایش دیالوگ حدس کلمه ---
  void _showGuessDialog(
      String correctWord, int wordIndex, List<String> distractors) {
    // ساخت لیست گزینه‌ها شامل کلمه درست و چند کلمه انحرافی
    List<String> options = [correctWord];

    // اگر کلمات انحرافی در فایل JSON بود، آن‌ها را اضافه می‌کنیم
    if (distractors.isNotEmpty) {
      var shuffledDistractors = List<String>.from(distractors)..shuffle();
      options.addAll(shuffledDistractors.take(3)); // نهایتا ۳ گزینه غلط
    } else {
      // گزینه‌های پیش‌فرض اگر فیلد distractors خالی بود
      options.addAll(['اللَّهِ', 'رَبِّ', 'عَلِيمٌ']);
    }

    // بهم ریختن ترتیب گزینه‌ها
    options = options.take(4).toList()..shuffle();

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor:
              const Color(0xFF0D231D).withOpacity(0.95), // هماهنگ با تم جدید
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: Text(
            'کدام کلمه درست است؟',
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
                color: Colors.amberAccent, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.white30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (option == correctWord) {
                      // پاسخ درست
                      setState(() {
                        _solvedWordIndices.add(wordIndex);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('آفرین! درست حدس زدی 👏',
                              style: GoogleFonts.vazirmatn()),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else {
                      // پاسخ غلط
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('اشتباه بود، دوباره تلاش کن!',
                              style: GoogleFonts.vazirmatn()),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Text(
                    option,
                    style: GoogleFonts.amiri(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.memorizeContent == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('تمرین حفظ',
              style: GoogleFonts.vazirmatn(color: Colors.white)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: AppBackground(
          child: Center(
            child: Text("محتوای حفظ برای این درس یافت نشد",
                style:
                    GoogleFonts.vazirmatn(color: Colors.white, fontSize: 18)),
          ),
        ),
      );
    }

    final content = widget.session.memorizeContent!;
    final hiddenWords = content.hiddenWords;
    final words = content.arabic.split(' ');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('تمرین حفظ',
            style: GoogleFonts.vazirmatn(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
          child: Consumer<GameState>(
            builder: (context, gameState, child) {
              final isMemorized = gameState.isMemorized(content.arabic);

              return Column(
                children: [
                  // کارت راهنما
                  FadeInDown(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.videogame_asset_rounded,
                              color: Colors.amberAccent, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'روی کلمات پنهان شده ضربه بزنید و از بین گزینه‌ها کلمه درست را پیدا کنید.',
                              style: GoogleFonts.vazirmatn(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // باکس اصلی نمایش آیه
                  ZoomIn(
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 15,
                            textDirection: TextDirection.rtl,
                            children: List.generate(words.length, (index) {
                              final word = words[index];

                              bool isHiddenTarget =
                                  hiddenWords.any((h) => word.contains(h));
                              bool isSolved =
                                  _solvedWordIndices.contains(index);

                              // اگر کلمه جزو اهداف مخفی باشد و هنوز حل نشده باشد
                              if (isHiddenTarget && !isSolved) {
                                return GestureDetector(
                                  onTap: () => _showGuessDialog(
                                      word, index, content.distractors),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF13947F)
                                          .withOpacity(0.3), // هماهنگ با تم
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.amberAccent,
                                          width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.help_outline_rounded,
                                            color: Colors.amberAccent,
                                            size: 18),
                                        const SizedBox(width: 5),
                                        ImageFiltered(
                                          imageFilter: ImageFilter.blur(
                                              sigmaX: 4, sigmaY: 4),
                                          child: Text(
                                            word,
                                            style: GoogleFonts.amiri(
                                              fontSize: gameState.fontSize + 4,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                              height: 1.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                // کلمات عادی یا حل شده
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  padding: isSolved
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2)
                                      : EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    color: isSolved
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    word,
                                    style: GoogleFonts.amiri(
                                      fontSize: gameState.fontSize + 4,
                                      fontWeight: FontWeight.bold,
                                      color: isSolved
                                          ? Colors.greenAccent
                                          : Colors.white,
                                      height: 1.8,
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),

                          const SizedBox(height: 25),
                          Divider(color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 10),

                          // دکمه وضعیت حفظ (گیمیفیکیشن دار)
                          InkWell(
                            onTap: () {
                              gameState.toggleMemorized(content.arabic);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isMemorized
                                        ? 'از لیست حفظ شده‌ها حذف شد'
                                        : 'تبریک! ۱۰ امتیاز گرفتی 🌟',
                                    style: GoogleFonts.vazirmatn(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  backgroundColor: isMemorized
                                      ? Colors.redAccent
                                      : Colors.amber.shade700,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMemorized
                                    ? Colors.amber.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isMemorized
                                      ? Colors.amberAccent
                                      : Colors.white30,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isMemorized
                                        ? Icons.emoji_events_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isMemorized
                                        ? Colors.amberAccent
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isMemorized
                                        ? 'حفظ کردم (+۱۰ امتیاز)'
                                        : 'هنوز حفظ نیستم',
                                    style: GoogleFonts.vazirmatn(
                                      color: isMemorized
                                          ? Colors.amberAccent
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // کارت ترجمه فارسی
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      child: Column(
                        children: [
                          Text(
                            'ترجمه',
                            style: GoogleFonts.vazirmatn(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            content.persian,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 18,
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
