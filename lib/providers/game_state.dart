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

  // --- تغییرات نسخه ۲.۰: لیست جامع قاریان EveryAyah و پیش‌فرض آفلاین ---
  final Map<String, String> availableReciters = {
    // پیش‌فرض جدید برای اجرای بدون اینترنت در اولین ورود
    "قاری آفلاین (بدون اینترنت)": "offline_mode",

    // قاریان ایرانی و ترجمه‌های گویای فارسی (جدید)
    "پرهیزگار (ترتیل 48kbps)": "https://everyayah.com/data/Parhizgar_48kbps/",
    "کریم منصوری (ترتیل 40kbps)":
        "https://everyayah.com/data/Karim_Mansoori_40kbps/",
    "ترجمه فارسی (مکارم/کبیری)":
        "https://everyayah.com/data/translations/Makarem_Kabiri_16Kbps/",
    "ترجمه فارسی (فولادوند/هدایت‌فر)":
        "https://everyayah.com/data/translations/Fooladvand_Hedayatfar_40Kbps/",

    // اساتید برجسته (با کیفیت‌های بهینه برای کاهش مصرف حجم اینترنت گوشی)
    "مشاری العفاسی (ترتیل 64kbps)":
        "https://everyayah.com/data/Alafasy_64kbps/",
    "مشاری العفاسی (ترتیل 128kbps)":
        "https://everyayah.com/data/Alafasy_128kbps/",
    "عبدالباسط (تحقیق 64kbps)":
        "https://everyayah.com/data/AbdulSamad_64kbps_QuranExplorer.Com/",
    "عبدالباسط (تحقیق 128kbps)":
        "https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps/",
    "عبدالباسط (ترتیل 64kbps)":
        "https://everyayah.com/data/Abdul_Basit_Murattal_64kbps/",
    "منشاوی (تحقیق 64kbps)":
        "https://everyayah.com/data/Minshawy_Mujawwad_64kbps/",
    "منشاوی (ترتیل 128kbps)":
        "https://everyayah.com/data/Minshawy_Murattal_128kbps/",
    "حصری (ترتیل 64kbps)": "https://everyayah.com/data/Husary_64kbps/",
    "حصری (آموزشی/معلم 128kbps)":
        "https://everyayah.com/data/Husary_Muallim_128kbps/",
    "سدیس (ترتیل 64kbps)":
        "https://everyayah.com/data/Abdurrahmaan_As-Sudais_64kbps/",
    "شریم (ترتیل 64kbps)": "https://everyayah.com/data/Shuraym_64kbps/",
    "ماهر المعیقلی (ترتیل 64kbps)":
        "https://everyayah.com/data/Maher_AlMuaiqly_64kbps/",
    "ابوبکر شاطری (ترتیل 64kbps)":
        "https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_64kbps/",
    "احمد العجمی (ترتیل 64kbps)":
        "https://everyayah.com/data/Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com/",
    "یاسر الدوسری (ترتیل 128kbps)":
        "https://everyayah.com/data/Dussary_128kbps/",
    "محمد ایوب (ترتیل 64kbps)":
        "https://everyayah.com/data/Muhammad_Ayyoub_64kbps/",
    "محمد جبریل (ترتیل 64kbps)":
        "https://everyayah.com/data/Muhammad_Jibreel_64kbps/",
    "عبدالله بصفر (ترتیل 64kbps)":
        "https://everyayah.com/data/Abdullah_Basfar_64kbps/",
    "هانی الرفاعی (ترتیل 64kbps)":
        "https://everyayah.com/data/Hani_Rifai_64kbps/",
    "فارس عباد (ترتیل 64kbps)":
        "https://everyayah.com/data/Fares_Abbad_64kbps/",
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

  String getReciterUrl(String originalUrl) {
    if (currentReciterBaseUrl == "offline_mode")
      return originalUrl; // مدیریت آفلاین جداست
    try {
      final uri = Uri.parse(originalUrl);
      final fileName = uri.pathSegments.last;
      return "$currentReciterBaseUrl$fileName";
    } catch (e) {
      return originalUrl;
    }
  }

  Future<void> toggleMemorized(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (memorizedVerses.contains(id)) {
      memorizedVerses.remove(id);
      // کسر امتیاز در صورت حذف از حفظیات (اختیاری)
      totalScore = (totalScore - 10).clamp(0, double.infinity).toInt();
    } else {
      memorizedVerses.add(id);
      // اضافه شدن ۱۰ امتیاز برای حفظ هر آیه!
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

      // تغییرات نسخه ۲.۰: منطق پخش آفلاین
      if (currentReciterBaseUrl == "offline_mode") {
        try {
          final uri = Uri.parse(originalUrl);
          final fileName = uri.pathSegments.last;
          // فایل‌های آفلاین باید در پوشه assets/audio/ قرار داده شوند
          await _player.setAsset('assets/audio/$fileName');
        } catch (e) {
          print("Error playing offline asset: $e");
          stopAudio();
          return;
        }
      } else {
        // منطق پخش آنلاین / کش شده
        final url = getReciterUrl(originalUrl);
        if (kIsWeb) {
          await _player.setUrl(url);
        } else {
          try {
            final fileInfo = await DefaultCacheManager().getFileFromCache(url);
            if (fileInfo != null && await fileInfo.file.exists()) {
              if (currentPlayingVerseIndex != index) return;
              await _player.setFilePath(fileInfo.file.path);
            } else {
              if (currentPlayingVerseIndex != index) return;
              await _player.setUrl(url);
            }
          } catch (e) {
            if (currentPlayingVerseIndex != index) return;
            await _player.setUrl(url);
          }
        }
      }

      if (currentPlayingVerseIndex == index) {
        _player.setSpeed(playbackSpeed);
        _player.play();
        notifyListeners();
      }
    } catch (e) {
      print("Error playing audio: $e");
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

  // --- دانلود یکجا ---
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
        await DefaultCacheManager().downloadFile(url);
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
