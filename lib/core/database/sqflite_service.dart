import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteService {
  static final SqfliteService _instance = SqfliteService._internal();
  static SqfliteService get instance => _instance;

  late Database _database;
  Database get database => _database;

  SqfliteService._internal();

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'nursing_plus.db');

    _database = await openDatabase(path, version: 1, onCreate: _onCreate);

    // Insert dummy data if the database is empty
    final categoriesCount = Sqflite.firstIntValue(
      await _database.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (categoriesCount == 0) {
      await _insertDummyData();
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name_ar TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        gradient_colors TEXT NOT NULL
      )
    ''');

    // Create procedures table
    await db.execute('''
      CREATE TABLE procedures (
        id INTEGER PRIMARY KEY,
        category_id INTEGER NOT NULL,
        category_name_ar TEXT NOT NULL,
        title_ar TEXT NOT NULL,
        overview_ar TEXT NOT NULL,
        indications_ar TEXT NOT NULL,
        contraindications_ar TEXT NOT NULL,
        complications_ar TEXT NOT NULL,
        tools_ar TEXT NOT NULL,
        extra_info_ar TEXT,
        image_urls TEXT NOT NULL,
        is_viewed INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Create procedure_steps table
    await db.execute('''
      CREATE TABLE procedure_steps (
        id INTEGER PRIMARY KEY,
        procedure_id INTEGER NOT NULL,
        step_en TEXT NOT NULL,
        rational_ar TEXT NOT NULL,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id)
      )
    ''');
  }

  Future<void> _insertDummyData() async {
    // Insert categories
    final categories = [
      {
        'id': 1,
        'name_ar': 'الرعاية المركزة',
        'icon_name': '0xe3e4', // monitor_heart
        'gradient_colors': jsonEncode(['0xFF9C27B0', '0xFF7B1FA2']),
      },
      {
        'id': 2,
        'name_ar': 'تمريض الأطفال',
        'icon_name': '0xe491', // child_care
        'gradient_colors': jsonEncode(['0xFF2196F3', '0xFF1976D2']),
      },
    ];

    for (final category in categories) {
      await _database.insert('categories', category);
    }

    // Insert procedures
    final procedures = [
      {
        'id': 1,
        'category_id': 1,
        'category_name_ar': 'الرعاية المركزة',
        'title_ar': 'قياس العلامات الحيوية',
        'overview_ar': 'قياس العلامات الحيوية للمريض في العناية المركزة',
        'indications_ar': jsonEncode([
          'تقييم الحالة الصحية للمريض',
          'متابعة تطور الحالة',
          'تحديد مدى فعالية العلاج',
        ]),
        'contraindications_ar': jsonEncode(['لا يوجد']),
        'complications_ar': jsonEncode([
          'قراءات غير دقيقة في حال عدم اتباع الخطوات بشكل صحيح',
        ]),
        'tools_ar': jsonEncode([
          'جهاز قياس الضغط',
          'سماعة طبية',
          'جهاز قياس الحرارة',
          'ساعة لقياس النبض',
        ]),
        'extra_info_ar': 'يجب تسجيل القراءات في ملف المريض مباشرة',
        'image_urls': jsonEncode([]),
      },
      {
        'id': 2,
        'category_id': 2,
        'category_name_ar': 'تمريض الأطفال',
        'title_ar': 'قياس درجة حرارة الطفل',
        'overview_ar': 'قياس درجة حرارة الطفل باستخدام الطرق المختلفة',
        'indications_ar': jsonEncode([
          'تقييم درجة حرارة الطفل',
          'الكشف عن الحمى',
          'متابعة فعالية خافضات الحرارة',
        ]),
        'contraindications_ar': jsonEncode(['لا يوجد']),
        'complications_ar': jsonEncode([
          'عدم دقة القراءة في حال عدم التثبيت الجيد',
        ]),
        'tools_ar': jsonEncode([
          'ميزان حرارة رقمي',
          'مناديل معقمة',
          'قفازات طبية',
        ]),
        'extra_info_ar': 'يفضل استخدام الميزان الرقمي للأطفال',
        'image_urls': jsonEncode([]),
      },
    ];

    for (final procedure in procedures) {
      await _database.insert('procedures', procedure);
    }

    // Insert procedure steps
    final steps = [
      {
        'id': 1,
        'procedure_id': 1,
        'step_en': 'Explain the procedure to the patient',
        'rational_ar': 'لبناء الثقة وتقليل القلق والحصول على تعاون المريض',
      },
      {
        'id': 2,
        'procedure_id': 1,
        'step_en': 'Perform hand hygiene and wear gloves',
        'rational_ar': 'لمنع انتقال العدوى',
      },
      {
        'id': 3,
        'procedure_id': 2,
        'step_en': 'Clean the thermometer with alcohol swab',
        'rational_ar': 'للتأكد من نظافة وتعقيم الميزان',
      },
      {
        'id': 4,
        'procedure_id': 2,
        'step_en': 'Place the thermometer in the appropriate position',
        'rational_ar': 'للحصول على قراءة دقيقة',
      },
    ];

    for (final step in steps) {
      await _database.insert('procedure_steps', step);
    }
  }

  // CRUD Operations
  Future<List<Map<String, dynamic>>> getProcedures({int? categoryId}) async {
    final db = await database;
    if (categoryId != null) {
      return db.query(
        'procedures',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
    }
    return db.query('procedures');
  }

  Future<Map<String, dynamic>?> getProcedure(int id) async {
    final db = await database;
    final results = await db.query(
      'procedures',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first;
  }

  Future<List<Map<String, dynamic>>> getProcedureSteps(int procedureId) async {
    final db = await database;
    return db.query(
      'procedure_steps',
      where: 'procedure_id = ?',
      whereArgs: [procedureId],
    );
  }

  Future<List<Map<String, dynamic>>> searchProcedures(String query) async {
    final db = await database;
    return db.query(
      'procedures',
      where: 'title_ar LIKE ? OR overview_ar LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }
}
