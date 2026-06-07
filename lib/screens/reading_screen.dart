// reading_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quran_models.dart';
import '../providers/game_state.dart';
import '../widgets/common_widgets.dart';

class ReadingScreen extends StatefulWidget {
  final Session session;
  const ReadingScreen({super.key, required this.session});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ScrollController _scrollController = ScrollController();

  // --- تغییرات نسخه ۲.۰: متغیرهای مربوط به ضبط صدا و گیمیفیکیشن ---
  int? _recordingVerseIndex;
  bool _isLessonCompleted = false;

  // مدیریت دکمه بازگشت (Back)
  Future<bool> _onWillPop() async {
    final gameState = Provider.of<GameState>(context, listen: false);

    if (gameState.isPlaying) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (ctx) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor:
                const Color(0xFF0D231D).withOpacity(0.95), // تم یشمی
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.2))),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.amberAccent),
                const SizedBox(width: 10),
                Text('توقف پخش',
                    style: GoogleFonts.vazirmatn(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'آیا می‌خواهید پخش صوت را متوقف کنید و خارج شوید؟',
              style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('ادامه پخش',
                    style: GoogleFonts.vazirmatn(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('بله، خروج',
                    style: GoogleFonts.vazirmatn(color: Colors.white)),
              ),
            ],
          ),
        ),
      );

      if (shouldExit == true) {
        await gameState.stopAudio();
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    try {
      Provider.of<GameState>(context, listen: false).stopAudio();
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verses = widget.session.verses!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.session.title,
              style: GoogleFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        body: AppBackground(
          child: Column(
            children: [
              Expanded(
                child: Consumer<GameState>(
                  builder: (context, gameState, child) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 120),
                      // به علاوه ۱ کردیم تا دکمه پایان درس در انتها اضافه شود
                      itemCount: verses.length + 1,
                      itemBuilder: (context, index) {
                        // --- تغییرات نسخه ۲.۰: دکمه گیمیفیکیشن پایان خواندن ---
                        if (index == verses.length) {
                          return _buildFinishReadingButton(gameState);
                        }

                        final verse = verses[index];
                        final isPlaying =
                            gameState.currentPlayingVerseIndex == index;
                        final isRecordingThis = _recordingVerseIndex == index;

                        return FadeInUp(
                          delay: Duration(milliseconds: index * 50),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isPlaying || isRecordingThis
                                    ? [
                                        BoxShadow(
                                            color: isRecordingThis
                                                ? Colors.redAccent
                                                    .withOpacity(0.3)
                                                : Colors.amber.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 2)
                                      ]
                                    : [],
                                border: isPlaying
                                    ? Border.all(
                                        color:
                                            Colors.amberAccent.withOpacity(0.8),
                                        width: 2)
                                    : isRecordingThis
                                        ? Border.all(
                                            color: Colors.redAccent
                                                .withOpacity(0.8),
                                            width: 2)
                                        : Border.all(
                                            color: Colors.white10, width: 1),
                              ),
                              child: GlassCard(
                                margin: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        // شماره آیه
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: isPlaying
                                                ? Colors.amber
                                                : Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            verse.id,
                                            style: TextStyle(
                                              color: isPlaying
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                        // پیام در حال ضبط
                                        if (isRecordingThis) ...[
                                          const SizedBox(width: 10),
                                          FadeIn(
                                            child: Text(
                                              "در حال ضبط...",
                                              style: GoogleFonts.vazirmatn(
                                                  color: Colors.redAccent,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],

                                        const Spacer(),

                                        // --- تغییرات نسخه ۲.۰: دکمه ضبط صدا ---
                                        GestureDetector(
                                          onLongPressDown: (_) {
                                            gameState
                                                .stopAudio(); // قطع صدای قاری
                                            setState(() {
                                              _recordingVerseIndex = index;
                                            });
                                          },
                                          onLongPressUp: () {
                                            setState(() {
                                              _recordingVerseIndex = null;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'صدای شما ضبط شد! حالا با صدای قاری مقایسه کنید.',
                                                    style: GoogleFonts
                                                        .vazirmatn()),
                                                backgroundColor: Colors.green,
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          onLongPressCancel: () {
                                            setState(() {
                                              _recordingVerseIndex = null;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isRecordingThis
                                                  ? Colors.redAccent
                                                      .withOpacity(0.2)
                                                  : Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isRecordingThis
                                                  ? Icons.mic_rounded
                                                  : Icons.mic_none_rounded,
                                              color: isRecordingThis
                                                  ? Colors.redAccent
                                                  : Colors.white54,
                                              size: 26,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // دکمه پخش صدای قاری
                                        InkWell(
                                          onTap: () => gameState.playVerse(
                                              verse.audioUrl, index),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.volume_up_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: isPlaying
                                                  ? Colors.amberAccent
                                                  : Colors.cyanAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),

                                    // متن عربی
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        verse.textArabic,
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.amiri(
                                          fontSize: gameState.fontSize + 4,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 2.4,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Divider(
                                        color: Colors.white.withOpacity(0.2)),
                                    const SizedBox(height: 10),

                                    // ترجمه فارسی
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        verse.textPersian,
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: gameState.fontSize * 0.7,
                                          color: Colors.white.withOpacity(0.95),
                                          height: 1.8,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildGlassAudioControls(context),
      ),
    );
  }

  // --- تغییرات نسخه ۲.۰: ویجت دکمه دریافت امتیاز پس از خواندن ---
  Widget _buildFinishReadingButton(GameState gameState) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 30),
        child: ElevatedButton(
          onPressed: _isLessonCompleted
              ? null
              : () {
                  setState(() {
                    _isLessonCompleted = true;
                  });
                  gameState.addScore(20); // 20 امتیاز برای پایان روخوانی
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'آفرین! ۲۰ امتیاز برای روخوانی این درس گرفتی 🌟',
                          style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.amber.shade700,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLessonCompleted
                ? Colors.green.withOpacity(0.5)
                : Colors.amberAccent,
            foregroundColor: const Color(0xFF0D231D),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: _isLessonCompleted ? 0 : 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isLessonCompleted
                  ? Icons.check_circle_rounded
                  : Icons.menu_book_rounded),
              const SizedBox(width: 10),
              Text(
                _isLessonCompleted
                    ? 'درس کامل شد'
                    : 'اتمام روخوانی (+۲۰ امتیاز)',
                style: GoogleFonts.vazirmatn(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAudioControls(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: BoxDecoration(
            color:
                const Color(0xFF0D231D).withOpacity(0.85), // هماهنگ با تم یشمی
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ],
          ),
          child: Consumer<GameState>(
            builder: (context, gameState, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlBtn(
                    icon: Icons.repeat_rounded,
                    isActive: gameState.isLooping,
                    onTap: gameState.toggleLoop,
                    activeColor: Colors.cyanAccent,
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop_circle_rounded,
                        color: Colors.redAccent, size: 36),
                    onPressed: gameState.stopAudio,
                  ),
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.amberAccent, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2)
                      ],
                    ),
                    child: IconButton(
                      iconSize: 32,
                      color: const Color(
                          0xFF0D231D), // رنگ آیکون تیره برای تضاد بهتر
                      icon: Icon(gameState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      onPressed: () {
                        if (gameState.isPlaying) {
                          gameState.pauseAudio();
                        } else if (gameState.currentPlayingVerseIndex != null) {
                          gameState.playVerse(
                              widget
                                  .session
                                  .verses![gameState.currentPlayingVerseIndex!]
                                  .audioUrl,
                              gameState.currentPlayingVerseIndex!);
                        } else if (widget.session.verses!.isNotEmpty) {
                          gameState.playVerse(
                              widget.session.verses![0].audioUrl, 0);
                        }
                      },
                    ),
                  ),
                  PopupMenuButton<double>(
                    offset: const Offset(0, -120),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: const Color(0xFF0D231D).withOpacity(0.95), // تم یشمی
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text('${gameState.playbackSpeed}x',
                              style: GoogleFonts.vazirmatn(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    onSelected: gameState.setSpeed,
                    itemBuilder: (context) => [
                      _speedItem(0.75, 'کند'),
                      _speedItem(1.0, 'عادی'),
                      _speedItem(1.25, 'تند'),
                      _speedItem(1.5, 'خیلی تند'),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn(
      {required IconData icon,
      required VoidCallback onTap,
      bool isActive = false,
      Color activeColor = Colors.blue}) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
              color: activeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12))
          : null,
      child: IconButton(
          icon: Icon(icon),
          color: isActive ? activeColor : Colors.white70,
          iconSize: 28,
          onPressed: onTap),
    );
  }

  PopupMenuItem<double> _speedItem(double value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$value x',
            style: GoogleFonts.vazirmatn(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}
