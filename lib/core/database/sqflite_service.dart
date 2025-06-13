import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Data Models based on the new schema
class Procedure {
  final int id;
  final String name;
  final String? category;
  final String? categoryIcon;
  final String? infoIcon;
  final String? infoText;
  final String? about;
  final String? indications;
  final String? contraindications;
  final String? complications;
  final String? requiredTools;
  final String? importantInfo;
  final List<Implementation> implementations;
  final List<Illustration> illustrations;

  Procedure({
    required this.id,
    required this.name,
    this.category,
    this.categoryIcon,
    this.infoIcon,
    this.infoText,
    this.about,
    this.indications,
    this.contraindications,
    this.complications,
    this.requiredTools,
    this.importantInfo,
    this.implementations = const [],
    this.illustrations = const [],
  });

  Procedure copyWith({
    int? id,
    String? name,
    String? category,
    String? categoryIcon,
    String? infoIcon,
    String? infoText,
    String? about,
    String? indications,
    String? contraindications,
    String? complications,
    String? requiredTools,
    String? importantInfo,
    List<Implementation>? implementations,
    List<Illustration>? illustrations,
  }) {
    return Procedure(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      infoIcon: infoIcon ?? this.infoIcon,
      infoText: infoText ?? this.infoText,
      about: about ?? this.about,
      indications: indications ?? this.indications,
      contraindications: contraindications ?? this.contraindications,
      complications: complications ?? this.complications,
      requiredTools: requiredTools ?? this.requiredTools,
      importantInfo: importantInfo ?? this.importantInfo,
      implementations: implementations ?? this.implementations,
      illustrations: illustrations ?? this.illustrations,
    );
  }

  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      categoryIcon: map['category_icon'],
      infoIcon: map['info_icon'],
      infoText: map['info_text'],
      about: map['about'],
      indications: map['indications'],
      contraindications: map['contraindications'],
      complications: map['complications'],
      requiredTools: map['required_tools'],
      importantInfo: map['important_info'],
    );
  }
}

class Implementation {
  final int id;
  final int procedureId;
  final int stepNumber;
  final String description;
  final String? rational;
  final String? extraNote;
  final String? extraNoteIcon;

  Implementation({
    required this.id,
    required this.procedureId,
    required this.stepNumber,
    required this.description,
    this.rational,
    this.extraNote,
    this.extraNoteIcon,
  });

  factory Implementation.fromMap(Map<String, dynamic> map) {
    return Implementation(
      id: map['id'],
      procedureId: map['procedure_id'],
      stepNumber: map['step_number'],
      description: map['description'],
      rational: map['rational'],
      extraNote: map['extra_note'],
      extraNoteIcon: map['extra_note_icon'],
    );
  }
}

class Illustration {
  final int id;
  final int procedureId;
  final String imagePath;

  Illustration({
    required this.id,
    required this.procedureId,
    required this.imagePath,
  });

  factory Illustration.fromMap(Map<String, dynamic> map) {
    return Illustration(
      id: map['id'],
      procedureId: map['procedure_id'],
      imagePath: map['image_path'],
    );
  }
}

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
    // await deleteDatabase(path); // uncomment for testing to clear db on each start
    return await openDatabase(
      path,
      version: 1, // Start with version 1 for the new schema
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create the new schema tables
    await db.execute('''
      CREATE TABLE procedures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        category_icon TEXT,
        info_icon TEXT,
        info_text TEXT,
        about TEXT,
        indications TEXT,
        contraindications TEXT,
        complications TEXT,
        required_tools TEXT,
        important_info TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE implementations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        procedure_id INTEGER NOT NULL,
        step_number INTEGER NOT NULL,
        description TEXT NOT NULL,
        rational TEXT,
        extra_note TEXT,
        extra_note_icon TEXT,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE illustrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        procedure_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id) ON DELETE CASCADE
      )
    ''');

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

    await db.execute('''
      CREATE TABLE recent_searches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        search_query TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Insert new sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Sample Procedure 1
    int procedureId1 = await db.insert(
        'procedures',
        {
          'name': 'قياس ضغط الدم',
          'category': 'تمريض أطفال',
          'category_icon':
              'child_care', // Using a placeholder string for the icon
          'info_icon':
              'lightbulb_outline', // Using a placeholder string for the icon
          'info_text': '4 خطوة',
          'about':
              'نبذة عن قياس ضغط الدم وهو إجراء حيوي لتقييم صحة القلب والأوعية الدموية.',
          'indications': '• تشخيص الحمى\n• تشخيص النزلات المعوية',
          'contraindications':
              '• وجود جرح في الذراع\n• وجود جهاز غسيل كلوي بالذراع',
          'complications': '• قراءة غير دقيقة\n• ألم بسيط مكان القياس',
          'required_tools': '• جهاز قياس ضغط الدم\n• سماعة طبية',
          'important_info': '• تأكد من أن المريض في وضع مريح قبل البدء.'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('implementations', {
      'procedure_id': procedureId1,
      'step_number': 1,
      'description':
          'Introduce yourself to the patient including your name and role',
      'rational': 'This helps in building rapport and trust with the patient.',
      'extra_note': null,
      'extra_note_icon': null,
    });
    await db.insert('implementations', {
      'procedure_id': procedureId1,
      'step_number': 2,
      'description':
          'Confirm the location of the brachial artery by palpating medial to the biceps brachii tendon and lateral to the medial epicondyle of the humerus',
      'rational':
          'لضمان وضع السماعة في المكان الصحيح لسماع أصوات كورتكوف بوضوح.',
      'extra_note': null,
      'extra_note_icon': null,
    });
    await db.insert('implementations', {
      'procedure_id': procedureId1,
      'step_number': 3,
      'description': 'Identify the first Korotkoff sound',
      'rational': null,
      'extra_note':
          'أصوات يُسمعها الأطباء عند قياس ضغط الدم بإستخدام سماعة الطبيب',
      'extra_note_icon': 'brain', // Placeholder for icon name
    });
    await db.insert('implementations', {
      'procedure_id': procedureId1,
      'step_number': 4,
      'description':
          'Document the lowest blood pressure recording in the patient\'s notes',
      'rational':
          'التوثيق الدقيق ضروري لمتابعة حالة المريض واتخاذ القرارات العلاجية.',
      'extra_note': null,
      'extra_note_icon': null,
    });

    await db.insert('illustrations', {
      'procedure_id': procedureId1,
      'image_path':
          'assets/images/body_parts.png' // Placeholder asset path, user must add this image
    });
    await db.insert('illustrations', {
      'procedure_id': procedureId1,
      'image_path':
          'assets/images/intestine.png' // Placeholder asset path, user must add this image
    });
  }

  // Method to fetch a single procedure with all its details
  Future<Procedure?> getProcedureById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> procedureMaps = await db.query(
      'procedures',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (procedureMaps.isEmpty) {
      return null;
    }

    final procedureData = procedureMaps.first;

    final List<Map<String, dynamic>> implementationMaps = await db.query(
      'implementations',
      where: 'procedure_id = ?',
      whereArgs: [id],
      orderBy: 'step_number ASC',
    );

    final List<Map<String, dynamic>> illustrationMaps = await db.query(
      'illustrations',
      where: 'procedure_id = ?',
      whereArgs: [id],
    );

    final implementations =
        implementationMaps.map((map) => Implementation.fromMap(map)).toList();
    final illustrations =
        illustrationMaps.map((map) => Illustration.fromMap(map)).toList();

    return Procedure.fromMap(procedureData).copyWith(
      implementations: implementations,
      illustrations: illustrations,
    );
  }

  // Method to fetch all procedures (without details for list view)
  Future<List<Procedure>> getAllProcedures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('procedures');

    return List.generate(maps.length, (i) {
      return Procedure.fromMap(maps[i]);
    });
  }

  // Method to search procedures by name
  Future<List<Procedure>> searchProcedures(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'procedures',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Procedure.fromMap(maps[i]);
    });
  }

  // Method to get procedures by category name
  Future<List<Procedure>> getProceduresByCategory(String categoryName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'procedures',
      where: 'category = ?',
      whereArgs: [categoryName],
    );

    return List.generate(maps.length, (i) {
      return Procedure.fromMap(maps[i]);
    });
  }
}
