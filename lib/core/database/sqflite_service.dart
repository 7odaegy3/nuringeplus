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
  final int stepCount;
  final bool hasIllustrations;
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
    required this.stepCount,
    required this.hasIllustrations,
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
    int? stepCount,
    bool? hasIllustrations,
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
      stepCount: stepCount ?? this.stepCount,
      hasIllustrations: hasIllustrations ?? this.hasIllustrations,
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
      stepCount: map['step_count'] ?? 0,
      hasIllustrations: (map['has_illustrations'] ?? 0) == 1,
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
    _database = await _initDB('nursing_procedures.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // await deleteDatabase(path); // uncomment for testing to clear db on each start
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE procedures(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        about TEXT,
        stepCount INTEGER DEFAULT 0,
        categoryIcon TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_procedures(
        procedure_id INTEGER PRIMARY KEY,
        saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id) ON DELETE CASCADE
      )
    ''');

    // Add some dummy data
    await _addDummyData(db);
  }

  Future<void> _addDummyData(Database db) async {
    final procedures = [
      {
        'name': 'قياس العلامات الحيوية',
        'category': 'تمريض الأطفال',
        'about': 'قياس درجة الحرارة والضغط والنبض',
        'stepCount': 32,
        'categoryIcon': 'child_care'
      },
      {
        'name': 'تركيب كانيولا',
        'category': 'الرعاية المركزة',
        'about': 'خطوات تركيب الكانيولا الوريدية',
        'stepCount': 24,
        'categoryIcon': 'local_hospital'
      },
      // Add more dummy procedures as needed
    ];

    for (var procedure in procedures) {
      await db.insert('procedures', procedure);
    }
  }

  Future<Procedure> getProcedureById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'procedures',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Procedure.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

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

  // New methods for saved procedures
  Future<List<Procedure>> getSavedProcedures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM procedures p
      INNER JOIN saved_procedures sp ON p.id = sp.procedure_id
      ORDER BY sp.saved_at DESC
    ''');

    return List.generate(maps.length, (i) => Procedure.fromMap(maps[i]));
  }

  Future<bool> isProcedureSaved(int procedureId) async {
    final db = await database;
    final result = await db.query(
      'saved_procedures',
      where: 'procedure_id = ?',
      whereArgs: [procedureId],
    );
    return result.isNotEmpty;
  }

  Future<void> saveProcedure(int procedureId) async {
    final db = await database;
    await db.insert(
      'saved_procedures',
      {'procedure_id': procedureId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> unsaveProcedure(int procedureId) async {
    final db = await database;
    await db.delete(
      'saved_procedures',
      where: 'procedure_id = ?',
      whereArgs: [procedureId],
    );
  }
}
