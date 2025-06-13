import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  static Database? _database;

  factory SqliteService() => _instance;

  SqliteService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nursing_plus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increased version number for schema updates
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add video_url column to procedures table
      await db.execute('ALTER TABLE procedures ADD COLUMN video_url TEXT');

      // Create user_progress table
      await db.execute('''
        CREATE TABLE user_progress(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          procedure_id INTEGER,
          completed_steps TEXT,
          last_accessed INTEGER,
          completion_status TEXT,
          notes TEXT,
          FOREIGN KEY (procedure_id) REFERENCES procedures (id)
        )
      ''');

      // Create recent_searches table
      await db.execute('''
        CREATE TABLE recent_searches(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          search_query TEXT NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');

      // Create procedure_checklists table
      await db.execute('''
        CREATE TABLE procedure_checklists(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          procedure_id INTEGER,
          step_id INTEGER,
          item_text TEXT NOT NULL,
          is_required BOOLEAN DEFAULT 1,
          is_completed BOOLEAN DEFAULT 0,
          FOREIGN KEY (procedure_id) REFERENCES procedures (id),
          FOREIGN KEY (step_id) REFERENCES procedure_steps (id)
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add video_url column to procedure_steps table
      await db.execute('ALTER TABLE procedure_steps ADD COLUMN video_url TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Create procedures table
    await db.execute('''
      CREATE TABLE procedures(
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        category_name_ar TEXT,
        title_ar TEXT,
        overview_ar TEXT,
        indications_ar TEXT,
        contraindications_ar TEXT,
        complications_ar TEXT,
        tools_ar TEXT,
        extra_info_ar TEXT,
        image_urls TEXT,
        video_url TEXT
      )
    ''');

    // Create procedure_steps table
    await db.execute('''
      CREATE TABLE procedure_steps(
        id INTEGER PRIMARY KEY,
        procedure_id INTEGER,
        step_en TEXT,
        rational_ar TEXT,
        video_url TEXT,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id)
      )
    ''');

    // Create user_progress table
    await db.execute('''
      CREATE TABLE user_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        procedure_id INTEGER,
        completed_steps TEXT,
        last_accessed INTEGER,
        completion_status TEXT,
        notes TEXT,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id)
      )
    ''');

    // Create recent_searches table
    await db.execute('''
      CREATE TABLE recent_searches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        search_query TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Create procedure_checklists table
    await db.execute('''
      CREATE TABLE procedure_checklists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        procedure_id INTEGER,
        step_id INTEGER,
        item_text TEXT NOT NULL,
        is_required BOOLEAN DEFAULT 1,
        is_completed BOOLEAN DEFAULT 0,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id),
        FOREIGN KEY (step_id) REFERENCES procedure_steps (id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Sample Categories:
    // 1: تمريض الأطفال
    // 2: الرعاية المركزة

    // Insert sample procedures
    final procedures = [
      {
        'id': 1,
        'category_id': 1,
        'category_name_ar': 'تمريض الأطفال',
        'title_ar': 'قياس درجة حرارة الطفل',
        'overview_ar': 'قياس درجة حرارة الجسم للطفل باستخدام الترمومتر الرقمي',
        'indications_ar': jsonEncode(['متابعة الحالة الصحية', 'تشخيص الحمى']),
        'contraindications_ar': jsonEncode(['لا يوجد']),
        'complications_ar':
            jsonEncode(['قراءات غير دقيقة في حالة عدم الاستخدام الصحيح']),
        'tools_ar': jsonEncode(['ترمومتر رقمي', 'معقم', 'قفازات']),
        'extra_info_ar': 'يجب تنظيف الترمومتر قبل وبعد الاستخدام',
        'image_urls': jsonEncode([]),
        'video_url': jsonEncode('')
      },
      {
        'id': 2,
        'category_id': 2,
        'category_name_ar': 'الرعاية المركزة',
        'title_ar': 'تركيب القسطرة الوريدية',
        'overview_ar': 'إجراء تركيب القسطرة الوريدية للمريض في العناية المركزة',
        'indications_ar':
            jsonEncode(['إعطاء الأدوية الوريدية', 'سحب عينات الدم']),
        'contraindications_ar':
            jsonEncode(['التهاب في موقع الإدخال', 'اضطرابات النزيف']),
        'complications_ar': jsonEncode(['العدوى', 'النزيف', 'تجلط الدم']),
        'tools_ar':
            jsonEncode(['قسطرة وريدية', 'معقم', 'قفازات معقمة', 'ضمادات']),
        'extra_info_ar':
            'يجب مراقبة موقع القسطرة يومياً للكشف عن أي علامات التهاب',
        'image_urls': jsonEncode([]),
        'video_url': jsonEncode('')
      }
    ];

    for (var procedure in procedures) {
      await db.insert('procedures', procedure);
    }

    // Insert sample procedure steps
    final steps = [
      {
        'id': 1,
        'procedure_id': 1,
        'step_en': 'Explain the procedure to the child and caregiver',
        'rational_ar': 'بناء الثقة وتقليل القلق والحصول على التعاون',
        'video_url': 'https://example.com/videos/explain_procedure.mp4'
      },
      {
        'id': 2,
        'procedure_id': 1,
        'step_en': 'Clean the thermometer with alcohol swab',
        'rational_ar': 'منع انتقال العدوى',
        'video_url': 'https://example.com/videos/clean_thermometer.mp4'
      },
      {
        'id': 3,
        'procedure_id': 2,
        'step_en': 'Perform hand hygiene and wear sterile gloves',
        'rational_ar': 'منع انتقال العدوى والحفاظ على التعقيم',
        'video_url': 'https://example.com/videos/hand_hygiene.mp4'
      },
      {
        'id': 4,
        'procedure_id': 2,
        'step_en': 'Select appropriate vein and apply tourniquet',
        'rational_ar': 'تسهيل الوصول للوريد وتحديد أفضل موقع للإدخال',
        'video_url': 'https://example.com/videos/vein_selection.mp4'
      }
    ];

    for (var step in steps) {
      await db.insert('procedure_steps', step);
    }

    // Insert sample checklist items
    final checklistItems = [
      {
        'procedure_id': 1,
        'step_id': 1,
        'item_text': 'Introduce yourself to the child and caregiver',
        'is_required': 1,
        'is_completed': 0
      },
      {
        'procedure_id': 1,
        'step_id': 1,
        'item_text': 'Explain the purpose of temperature measurement',
        'is_required': 1,
        'is_completed': 0
      },
      {
        'procedure_id': 1,
        'step_id': 2,
        'item_text': 'Check thermometer battery',
        'is_required': 1,
        'is_completed': 0
      },
      {
        'procedure_id': 1,
        'step_id': 2,
        'item_text': 'Use new alcohol swab',
        'is_required': 1,
        'is_completed': 0
      },
      {
        'procedure_id': 2,
        'step_id': 3,
        'item_text': 'Perform hand hygiene for at least 20 seconds',
        'is_required': 1,
        'is_completed': 0
      },
      {
        'procedure_id': 2,
        'step_id': 3,
        'item_text': 'Check gloves size and integrity',
        'is_required': 1,
        'is_completed': 0
      },
      {
        'procedure_id': 2,
        'step_id': 4,
        'item_text': 'Assess vein visibility and palpability',
        'is_required': 1,
        'is_completed': 0
      },
      {
        'procedure_id': 2,
        'step_id': 4,
        'item_text': 'Check tourniquet elasticity',
        'is_required': 0,
        'is_completed': 0
      }
    ];

    for (var item in checklistItems) {
      await db.insert('procedure_checklists', item);
    }
  }

  // CRUD Operations for Procedures
  Future<List<Map<String, dynamic>>> getProcedures() async {
    final db = await database;
    return await db.query('procedures');
  }

  Future<List<Map<String, dynamic>>> getProceduresByCategory(
      int categoryId) async {
    final db = await database;
    return await db.query(
      'procedures',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<Map<String, dynamic>?> getProcedureById(int id) async {
    final db = await database;
    final results = await db.query(
      'procedures',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // CRUD Operations for Procedure Steps
  Future<List<Map<String, dynamic>>> getProcedureSteps(int procedureId) async {
    final db = await database;
    return await db.query(
      'procedure_steps',
      where: 'procedure_id = ?',
      whereArgs: [procedureId],
    );
  }

  // Search Procedures
  Future<List<Map<String, dynamic>>> searchProcedures(String query) async {
    final db = await database;
    return await db.query(
      'procedures',
      where: 'title_ar LIKE ? OR overview_ar LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // New methods for user progress
  Future<void> updateUserProgress(
      String userId, int procedureId, List<int> completedSteps) async {
    final db = await database;
    await db.insert(
      'user_progress',
      {
        'user_id': userId,
        'procedure_id': procedureId,
        'completed_steps': jsonEncode(completedSteps),
        'last_accessed': DateTime.now().millisecondsSinceEpoch,
        'completion_status':
            completedSteps.isEmpty ? 'not_started' : 'in_progress'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProgress(
      String userId, int procedureId) async {
    final db = await database;
    final results = await db.query(
      'user_progress',
      where: 'user_id = ? AND procedure_id = ?',
      whereArgs: [userId, procedureId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Recent searches methods
  Future<void> addRecentSearch(String userId, String query) async {
    final db = await database;
    await db.insert(
      'recent_searches',
      {
        'user_id': userId,
        'search_query': query,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getRecentSearches(String userId,
      {int limit = 10}) async {
    final db = await database;
    return await db.query(
      'recent_searches',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  // Checklist methods
  Future<void> addChecklistItem(
      int procedureId, int stepId, String itemText, bool isRequired) async {
    final db = await database;
    await db.insert(
      'procedure_checklists',
      {
        'procedure_id': procedureId,
        'step_id': stepId,
        'item_text': itemText,
        'is_required': isRequired ? 1 : 0,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getChecklistItems(
      int procedureId, int stepId) async {
    final db = await database;
    return await db.query(
      'procedure_checklists',
      where: 'procedure_id = ? AND step_id = ?',
      whereArgs: [procedureId, stepId],
    );
  }

  Future<void> updateChecklistItemStatus(int itemId, bool isCompleted) async {
    final db = await database;
    await db.update(
      'procedure_checklists',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }
}
