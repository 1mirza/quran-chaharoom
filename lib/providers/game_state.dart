// game_state.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart'; // اضافه شده برای نسخه ۲.۰
import '../models/quran_models.dart';

class GameState extends ChangeNotifier {
  // --- داده‌ها ---
  List<LessonIndex>? lessonIndex;
  bool isIndexLoading = true;
  LessonContent? currentLessonContent;
  bool isLessonLoading = false;

  // --- تغییرات نسخه ۲.۰: گیمیفیکیشن و سطح کاربر ---
  int totalScore = 0;

  // محاسبه لقب/سطح کاربر بر اساس امتیاز
  String get userLevelTitle {
    if (totalScore < 50) return "نوآموز قرآنی 🌟";
    if (totalScore < 150) return "قاری خوش‌صدا 🎤";
    if (totalScore < 300) return "حافظ کوچک 🧠";
    if (totalScore < 500) return "قهرمان قرآن 🏆";
    return "ستاره درخشان قرآنی 👑";
  }

  // --- تنظیمات ---
  double fontSize = 24.0;

  // --- لیست جامع قاریان بدون فیلتر و مستقل از EveryAyah ---
  final Map<String, String> availableReciters = {
    "قاری آفلاین (بدون اینترنت)": "offline_mode",

    // شناسه‌ها بر اساس پوشه‌های استاندارد صوت جهانی تنظیم شده‌اند
    "مشاری العفاسی (ترتیل)": "afasy",
    "پرهیزگار (ترتیل شهریار پرهیزگار)": "parhizgar",
    "کریم منصوری (ترتیل)": "mansouri",
    "عبدالباسط (ترتیل اساتید)": "abdulbasit_murattal",
    "عبدالباسط (تحقیق/مجوّد)": "abdulbasit_mujawwad",
    "محمدصدیق منشاوی (ترتیل)": "minshawi_murattal",
    "محمدصدیق منشاوی (تحقیق)": "minshawi_mujawwad",
    "خلیل الحصری (ترتیل)": "husary_murattal",
    "خلیل الحصری (آموزشی/معلم)": "husary_muallim",
    "ماهر المعیقلی (ترتیل)": "maher",
    "سدیس (ترتیل)": "sudais",
  };

  // پیش‌فرض در اولین نصب روی حالت آفلاین تنظیم شد
  String currentReciterName = "قاری آفلاین (بدون اینترنت)";
  late String currentReciterBaseUrl;

  // --- دانلود و پخش ---
  bool isDownloadingAll = false;
  double downloadProgress = 0.0;
  String downloadStatusText = "";

  final AudioPlayer _player = AudioPlayer();
  int? currentPlayingVerseIndex;
  bool isPlaying = false;
  double playbackSpeed = 1.0;
  bool isLooping = false;

  Set<String> memorizedVerses = {};

  GameState() {
    currentReciterBaseUrl = availableReciters[currentReciterName]!;
    _loadSavedUserData(); // فراخوانی دیتای ذخیره شده کاربر
    loadIndex();
    _initAudioListeners();
  }

  // --- تغییرات نسخه ۲.۰: متدهای ذخیره و بازیابی اطلاعات کاربر ---
  Future<void> _loadSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    totalScore = prefs.getInt('totalScore') ?? 0;

    // بازیابی لیست آیات حفظ شده
    final savedMemorized = prefs.getStringList('memorizedVerses');
    if (savedMemorized != null) {
      memorizedVerses = savedMemorized.toSet();
    }

    fontSize = prefs.getDouble('fontSize') ?? 24.0;

    final savedReciter = prefs.getString('currentReciterName');
    if (savedReciter != null && availableReciters.containsKey(savedReciter)) {
      currentReciterName = savedReciter;
      currentReciterBaseUrl = availableReciters[savedReciter]!;
    }
    notifyListeners();
  }

  Future<void> addScore(int points) async {
    totalScore += points;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalScore', totalScore);
  }

  // --- متدهای تنظیمات ---
  Future<void> setFontSize(double size) async {
    fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
  }

  Future<void> changeReciter(String name) async {
    if (availableReciters.containsKey(name)) {
      currentReciterName = name;
      currentReciterBaseUrl = availableReciters[name]!;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentReciterName', name);

      if (isPlaying) stopAudio();
      notifyListeners();
    }
  }

  // ساخت لینک اصلی بر اساس ساختار تنزیل برای متد دانلود یکجا
  String getReciterUrl(String originalUrl) {
    if (currentReciterBaseUrl == "offline_mode") return originalUrl;

    try {
      final uri = Uri.parse(originalUrl);
      final fileName = uri.pathSegments.last; // مثل 078001.mp3
      return "https://tanzil.net/res/audio/$currentReciterBaseUrl/$fileName";
    } catch (e) {
      return originalUrl;
    }
  }

  Future<void> toggleMemorized(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (memorizedVerses.contains(id)) {
      memorizedVerses.remove(id);
      totalScore = (totalScore - 10).clamp(0, double.infinity).toInt();
    } else {
      memorizedVerses.add(id);
      totalScore += 10;
    }
    await prefs.setStringList('memorizedVerses', memorizedVerses.toList());
    await prefs.setInt('totalScore', totalScore);
    notifyListeners();
  }

  bool isMemorized(String id) => memorizedVerses.contains(id);

  // --- متدهای بارگذاری ---
  Future<void> loadIndex() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/index.json');
      final List<dynamic> data = json.decode(response);
      lessonIndex = data.map((e) => LessonIndex.fromJson(e)).toList();
      isIndexLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error loading index: $e");
      isIndexLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLessonContent(String fileName) async {
    isLessonLoading = true;
    currentLessonContent = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final String response =
          await rootBundle.loadString('assets/data/lessons/$fileName');
      final data = json.decode(response);
      currentLessonContent = LessonContent.fromJson(data);
      isLessonLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error loading lesson: $e");
      isLessonLoading = false;
      notifyListeners();
    }
  }

  // --- متدهای صوتی ---
  void _initAudioListeners() {
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (isLooping && currentPlayingVerseIndex != null) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          stopAudio();
        }
      }
      notifyListeners();
    });
  }

  Future<void> playVerse(String originalUrl, int index) async {
    try {
      if (currentPlayingVerseIndex == index && _player.audioSource != null) {
        if (isPlaying) {
          await pauseAudio();
        } else {
          await _player.play();
        }
        return;
      }

      currentPlayingVerseIndex = index;
      notifyListeners();

      // ۱. منطق پخش آفلاین
      if (currentReciterBaseUrl == "offline_mode") {
        try {
          final uri = Uri.parse(originalUrl);
          final fileName = uri.pathSegments.last;
          await _player.setAsset('assets/audio/$fileName');
        } catch (e) {
          print("Error playing offline asset: $e");
          stopAudio();
          return;
        }
      } else {
        // ۲. منطق پخش آنلاین با سیستم شش سروره کاملاً مستقل و ضد اختلال (Multi-Server Fallback)
        final uri = Uri.parse(originalUrl);
        final fileName =
            uri.pathSegments.last; // استخراج نام فایل مثل 078001.mp3
        final qariFolder = currentReciterBaseUrl; // پوشه قاری

        // آرایه‌ای از ۶ سرور قدرتمند، بدون فیلتر و با ساختارهای متفاوت در سراسر وب
        List<String> candidateUrls = [
          "https://tanzil.net/res/audio/$qariFolder/$fileName", // سرور ۱: تنزیل اصلی
          "https://audio.quran.com/reciter/$qariFolder/$fileName", // سرور ۲: وب‌سایت جهانی قرآن‌دات‌کام
          "https://www.quran.network/media/audio/$qariFolder/$fileName", // سرور ۳: شبکه رسانه‌ای مستقل قرآن
          "https://server8.mp3quran.net/$qariFolder/$fileName", // سرور ۴: دیتابیس عظیم ام‌پی‌تری قرآن
          "http://www.reciter.org/media/audio/$qariFolder/$fileName", // سرور ۵: بک‌آپ کمکی پنجم
          "https://quranic-audio.com/reciters/$qariFolder/$fileName", // سرور ۶: شانس آخر پروژه‌های متن‌باز
        ];

        bool isLoadedSuccessfully = false;

        for (String url in candidateUrls) {
          if (currentPlayingVerseIndex != index)
            return; // لغو در صورت جابه‌جایی سریع آیه توسط دانش‌آموز

          try {
            print("Connecting to secure server mirror: $url");

            if (kIsWeb) {
              await _player.setUrl(url);
            } else {
              final fileInfo =
                  await DefaultCacheManager().getFileFromCache(url);
              if (fileInfo != null && await fileInfo.file.exists()) {
                await _player.setFilePath(fileInfo.file.path);
              } else {
                // تایمر هوشمند روی ۳ ثانیه؛ اگر سرور فیلتر یا قطع بود، سریعاً رد می‌شود
                await _player
                    .setUrl(url)
                    .timeout(const Duration(milliseconds: 3000));
              }
            }

            isLoadedSuccessfully = true;
            break; // به محض لود شدن یکی از سرورها، حلقه تمام می‌شود
          } catch (e) {
            print(
                "Mirror failed ($url). Switching to next backup resource... Exception: $e");
          }
        }

        if (!isLoadedSuccessfully) {
          print("All 6 global audio mirrors are currently unreachable.");
          stopAudio();
          return;
        }
      }

      if (currentPlayingVerseIndex == index) {
        _player.setSpeed(playbackSpeed);
        _player.play();
        notifyListeners();
      }
    } catch (e) {
      print("General error in player: $e");
      stopAudio();
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> stopAudio() async {
    try {
      await _player.stop();
      currentPlayingVerseIndex = null;
      isPlaying = false;
      notifyListeners();
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  void setSpeed(double speed) {
    playbackSpeed = speed;
    _player.setSpeed(speed);
    notifyListeners();
  }

  void toggleLoop() {
    isLooping = !isLooping;
    notifyListeners();
  }

  // --- دانلود یکجا کاملاً بدون فیلتر ---
  Future<void> downloadAllAudio() async {
    if (lessonIndex == null) return;
    if (currentReciterBaseUrl == "offline_mode") {
      downloadStatusText = "در حالت آفلاین نیازی به دانلود نیست.";
      notifyListeners();
      return;
    }
    if (kIsWeb) {
      downloadStatusText = "دانلود آفلاین در وب پشتیبانی نمی‌شود.";
      notifyListeners();
      return;
    }

    isDownloadingAll = true;
    downloadProgress = 0.0;
    downloadStatusText = "در حال آماده‌سازی...";
    notifyListeners();

    try {
      List<String> allUrls = [];
      for (var lessonRef in lessonIndex!) {
        final String response = await rootBundle
            .loadString('assets/data/lessons/${lessonRef.fileName}');
        final data = json.decode(response);
        final lesson = LessonContent.fromJson(data);
        for (var session in lesson.sessions) {
          if (session.verses != null) {
            for (var verse in session.verses!) {
              allUrls.add(getReciterUrl(verse.audioUrl));
            }
          }
        }
      }

      int total = allUrls.length;
      int count = 0;
      for (var url in allUrls) {
        if (!isDownloadingAll) break;
        count++;
        downloadStatusText = "دانلود فایل $count از $total";
        downloadProgress = count / total;
        notifyListeners();
        try {
          await DefaultCacheManager().downloadFile(url);
        } catch (e) {
          print("Skipping download item error: $e");
        }
      }
      if (isDownloadingAll) {
        downloadStatusText = "دانلود تمام شد!";
      }
    } catch (e) {
      downloadStatusText = "خطا در دانلود: $e";
    } finally {
      isDownloadingAll = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
