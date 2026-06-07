// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_state.dart';
import '../widgets/common_widgets.dart';
import 'dart:ui';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('تنظیمات',
            style: GoogleFonts.vazirmatn(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: AppBackground(
        child: Consumer<GameState>(
          builder: (context, gameState, child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
              children: [
                // 1. تنظیمات فونت
                FadeInDown(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.format_size_rounded,
                                color: Colors.amberAccent),
                            const SizedBox(width: 10),
                            Text("اندازه متن آیات",
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text("کوچک",
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.white70)),
                            Expanded(
                              child: Slider(
                                value: gameState.fontSize,
                                min: 18.0,
                                max: 40.0,
                                divisions: 11,
                                activeColor: Colors.amberAccent,
                                inactiveColor: Colors.white24,
                                label: gameState.fontSize.round().toString(),
                                onChanged: (val) => gameState.setFontSize(val),
                              ),
                            ),
                            Text("بزرگ",
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // پیش‌نمایش متن
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13947F)
                                .withOpacity(0.2), // رنگ فیروزه‌ای تم جدید
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.amberAccent.withOpacity(0.5)),
                          ),
                          child: Text(
                            "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              fontSize: gameState.fontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. انتخاب قاری
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.record_voice_over_rounded,
                                color: Colors.cyanAccent),
                            const SizedBox(width: 10),
                            Text("انتخاب قاری",
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: gameState.currentReciterName,
                              dropdownColor: const Color(0xFF0D231D)
                                  .withOpacity(0.95), // هماهنگ با تم یشمی
                              style: GoogleFonts.vazirmatn(
                                  color: Colors.white, fontSize: 16),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_rounded,
                                  color: Colors.amberAccent),
                              items: gameState.availableReciters.keys
                                  .map((String key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child:
                                      Text(key, style: GoogleFonts.vazirmatn()),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  gameState.changeReciter(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. دانلود یکجا (آفلاین سازی)
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: GlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.download_for_offline_rounded,
                                color: Colors.greenAccent),
                            const SizedBox(width: 10),
                            Text("دانلود فایل‌های صوتی",
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "با زدن این دکمه، تمام صوت‌های قاری انتخاب شده دانلود شده و برنامه برای همیشه آفلاین می‌شود. (در صورت انتخاب «قاری آفلاین»، نیازی به این کار نیست).",
                          style: GoogleFonts.vazirmatn(
                              color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        if (gameState.isDownloadingAll) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: gameState.downloadProgress,
                              backgroundColor: Colors.white12,
                              color: Colors.greenAccent,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            gameState.downloadStatusText,
                            style: GoogleFonts.vazirmatn(
                                color: Colors.white, fontSize: 14),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.download_rounded),
                              label: Text("شروع دانلود",
                                  style: GoogleFonts.vazirmatn(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                _showDownloadDialog(context, gameState);
                              },
                            ),
                          ),
                          if (gameState.downloadStatusText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                gameState.downloadStatusText,
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.amberAccent, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. درباره سازنده
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: GlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            Text("درباره سازنده",
                                style: GoogleFonts.vazirmatn(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "این برنامه توسط حمیدرضا علی میرزائی طراحی و ساخته شده است.",
                          style: GoogleFonts.vazirmatn(
                              color: Colors.white, fontSize: 16, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 10),
                        Text(
                          "برای بازخورد و بهبود به ایمیل زیر پیام دهید:",
                          style: GoogleFonts.vazirmatn(
                              color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        const SelectableText(
                          "alimirzaei.hr@gmail.com", // ایمیل خودتان را اینجا وارد کنید
                          style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
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
    );
  }

  void _showDownloadDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0D231D).withOpacity(0.95), // تم یشمی
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2))),
          title: Text("هشدار مصرف اینترنت",
              style: GoogleFonts.vazirmatn(
                  color: Colors.amberAccent, fontWeight: FontWeight.bold)),
          content: Text(
            "حجم کل فایل‌های صوتی حدود ۵۰ تا ۱۰۰ مگابایت است. آیا مایل به ادامه هستید؟",
            style: GoogleFonts.vazirmatn(color: Colors.white, height: 1.5),
          ),
          actions: [
            TextButton(
              child: Text("خیر",
                  style: GoogleFonts.vazirmatn(color: Colors.white70)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text("بله، دانلود کن",
                  style: GoogleFonts.vazirmatn(color: Colors.white)),
              onPressed: () {
                Navigator.pop(ctx);
                gameState.downloadAllAudio();
              },
            ),
          ],
        ),
      ),
    );
  }
}
