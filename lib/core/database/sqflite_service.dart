import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteService {
  static final SqfliteService _instance = SqfliteService._internal();
  static Database? _database;

  factory SqfliteService() => _instance;

  SqfliteService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    await _insertDummyData();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nursing_plus.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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
            image_urls TEXT
          )
        ''');

        // Create procedure_steps table
        await db.execute('''
          CREATE TABLE procedure_steps(
            id INTEGER PRIMARY KEY,
            procedure_id INTEGER,
            step_en TEXT,
            rational_ar TEXT,
            FOREIGN KEY (procedure_id) REFERENCES procedures (id)
          )
        ''');
      },
    );
  }

  Future<void> _insertDummyData() async {
    final db = await database;

    // Check if data already exists
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM procedures'),
    );

    if (count != null && count > 0) return;

    // Insert dummy procedures
    final procedures = [
      {
        'id': 1,
        'category_id': 1,
        'category_name_ar': 'تمريض الأطفال',
        'title_ar': 'قياس درجة حرارة الطفل',
        'overview_ar': 'قياس درجة حرارة الجسم للطفل باستخدام الترمومتر الرقمي',
        'indications_ar': jsonEncode([
          'متابعة الحالة الصحية للطفل',
          'الاشتباه في وجود حمى',
          'متابعة فعالية العلاج',
        ]),
        'contraindications_ar': jsonEncode([
          'عدم وجود موانع لقياس درجة الحرارة',
        ]),
        'complications_ar': jsonEncode([
          'قراءة غير دقيقة في حالة عدم الاستخدام الصحيح',
          'عدم راحة الطفل',
        ]),
        'tools_ar': jsonEncode(['ترمومتر رقمي', 'معقم كحولي', 'قطن طبي']),
        'extra_info_ar': 'يجب تنظيف الترمومتر قبل وبعد الاستخدام',
        'image_urls': jsonEncode([
          'assets/images/temp1.png',
          'assets/images/temp2.png',
        ]),
      },
      {
        'id': 2,
        'category_id': 2,
        'category_name_ar': 'الرعاية المركزة',
        'title_ar': 'تركيب القسطرة الوريدية',
        'overview_ar': 'إدخال قسطرة في الوريد لإعطاء السوائل أو الأدوية',
        'indications_ar': jsonEncode([
          'الحاجة لإعطاء السوائل الوريدية',
          'إعطاء الأدوية عن طريق الوريد',
          'سحب عينات دم متكررة',
        ]),
        'contraindications_ar': jsonEncode([
          'التهاب في موقع الإدخال',
          'حروق شديدة في المنطقة',
          'تجلط في الوريد المستهدف',
        ]),
        'complications_ar': jsonEncode([
          'التهاب موضعي',
          'تسرب السوائل خارج الوريد',
          'تجلط الدم',
        ]),
        'tools_ar': jsonEncode([
          'قسطرة وريدية معقمة',
          'قفازات معقمة',
          'محلول مطهر',
          'شاش معقم',
          'رباط ضاغط',
        ]),
        'extra_info_ar':
            'يجب مراقبة موقع القسطرة بشكل منتظم للكشف عن أي مضاعفات',
        'image_urls': jsonEncode([
          'assets/images/iv1.png',
          'assets/images/iv2.png',
        ]),
      },
    ];

    final steps = [
      {
        'procedure_id': 1,
        'step_en': 'Clean the thermometer with alcohol swab',
        'rational_ar': 'لضمان القراءة الدقيقة ومنع انتقال العدوى',
      },
      {
        'procedure_id': 1,
        'step_en': 'Place the thermometer in the axilla',
        'rational_ar':
            'الإبط هو موقع آمن وموثوق لقياس درجة الحرارة عند الأطفال',
      },
      {
        'procedure_id': 2,
        'step_en': 'Perform hand hygiene and wear sterile gloves',
        'rational_ar': 'منع انتقال العدوى وحماية المريض والممرض',
      },
      {
        'procedure_id': 2,
        'step_en': 'Apply tourniquet and select appropriate vein',
        'rational_ar': 'تسهيل رؤية وتحديد الوريد المناسب',
      },
    ];

    // Insert data in a transaction
    await db.transaction((txn) async {
      for (final procedure in procedures) {
        await txn.insert('procedures', procedure);
      }
      for (final step in steps) {
        await txn.insert('procedure_steps', step);
      }
    });
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
