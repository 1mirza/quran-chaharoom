// quran_models.dart

class LessonIndex {
  final int id;
  final String title;
  final String fileName;

  LessonIndex({required this.id, required this.title, required this.fileName});

  factory LessonIndex.fromJson(Map<String, dynamic> json) {
    return LessonIndex(
      id: json['id'],
      title: json['title'],
      fileName: json['file_name'],
    );
  }
}

class LessonContent {
  final int id;
  final String title;
  final List<Session> sessions;

  LessonContent(
      {required this.id, required this.title, required this.sessions});

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      id: json['id'],
      title: json['title'],
      sessions:
          (json['sessions'] as List).map((i) => Session.fromJson(i)).toList(),
    );
  }
}

class Session {
  final String type; // 'reading', 'quiz', 'memorize'
  final String title;
  final List<Verse>? verses;
  final List<QuizQuestion>? questions;
  final MemorizeContent? memorizeContent;

  Session({
    required this.type,
    required this.title,
    this.verses,
    this.questions,
    this.memorizeContent,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      type: json['type'],
      title: json['title'],
      verses: json['verses'] != null
          ? (json['verses'] as List).map((i) => Verse.fromJson(i)).toList()
          : null,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((i) => QuizQuestion.fromJson(i))
              .toList()
          : null,
      memorizeContent: json['content'] != null
          ? MemorizeContent.fromJson(json['content'])
          : null,
    );
  }
}

class Verse {
  final String id;
  final String textArabic;
  final String textPersian;
  final String audioUrl;

  Verse({
    required this.id,
    required this.textArabic,
    required this.textPersian,
    required this.audioUrl,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'],
      textArabic: json['text_arabic'],
      textPersian: json['text_persian'],
      audioUrl: json['audio_url'],
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
    );
  }
}

class MemorizeContent {
  final String arabic;
  final String persian;
  final List<String> hiddenWords;

  // --- تغییرات نسخه ۲.۰ ---
  // لیستی از کلمات اشتباه برای نمایش در گزینه‌های بازی حفظ اضافه شد.
  final List<String> distractors;

  MemorizeContent({
    required this.arabic,
    required this.persian,
    required this.hiddenWords,
    required this.distractors,
  });

  factory MemorizeContent.fromJson(Map<String, dynamic> json) {
    return MemorizeContent(
      arabic: json['arabic'],
      persian: json['persian'],
      hiddenWords: List<String>.from(json['hidden_words'] ?? []),

      // اگر در فایل‌های JSON قدیمی شما این فیلد نبود، برنامه کرش نمی‌کند و یک لیست خالی در نظر می‌گیرد.
      // اما برای نسخه جدید، می‌توانید در فایل JSON آرایه "distractors" را هم اضافه کنید.
      distractors: json['distractors'] != null
          ? List<String>.from(json['distractors'])
          : [],
    );
  }
}
