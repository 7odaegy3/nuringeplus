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
  final String? description;
  final List<String>? steps;
  final List<String>? hints;

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
    this.description,
    this.steps,
    this.hints,
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
    String? description,
    List<String>? steps,
    List<String>? hints,
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
      description: description ?? this.description,
      steps: steps ?? this.steps,
      hints: hints ?? this.hints,
    );
  }

  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String?,
      categoryIcon: map['category_icon'] as String?,
      infoIcon: map['info_icon'] as String?,
      infoText: map['info_text'] as String?,
      about: map['about'] as String?,
      indications: map['indications'] as String?,
      contraindications: map['contraindications'] as String?,
      complications: map['complications'] as String?,
      requiredTools: map['required_tools'] as String?,
      importantInfo: map['important_info'] as String?,
      stepCount: map['step_count'] as int,
      hasIllustrations: (map['has_illustrations'] ?? 0) == 1,
      description: map['description'] as String?,
      steps: map['steps'] != null ? List<String>.from(map['steps']) : null,
      hints: map['hints'] != null ? List<String>.from(map['hints']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'category_icon': categoryIcon,
      'info_icon': infoIcon,
      'info_text': infoText,
      'about': about,
      'indications': indications,
      'contraindications': contraindications,
      'complications': complications,
      'required_tools': requiredTools,
      'important_info': importantInfo,
      'step_count': stepCount,
      'has_illustrations': hasIllustrations ? 1 : 0,
      'description': description,
      'steps': steps,
      'hints': hints,
    };
  }
}

class Implementation {
  final int id;
  final int procedureId;
  final int stepNumber;
  final String description;
  final String? rational;
  final String? hint;

  Implementation({
    required this.id,
    required this.procedureId,
    required this.stepNumber,
    required this.description,
    this.rational,
    this.hint,
  });

  factory Implementation.fromMap(Map<String, dynamic> map) {
    return Implementation(
      id: map['id'],
      procedureId: map['procedure_id'],
      stepNumber: map['step_number'],
      description: map['description'],
      rational: map['rational'],
      hint: map['hint'],
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
    await deleteDatabase(
        path); // uncomment for testing to clear db on each start
    return await openDatabase(
      path,
      version: 2,
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
        indications TEXT,
        contraindications TEXT,
        complications TEXT,
        required_tools TEXT,
        important_info TEXT,
        step_count INTEGER DEFAULT 0,
        category_icon TEXT,
        info_icon TEXT,
        info_text TEXT,
        has_illustrations INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE implementations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        procedure_id INTEGER NOT NULL,
        step_number INTEGER NOT NULL,
        description TEXT NOT NULL,
        rational TEXT,
        hint TEXT,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE illustrations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        procedure_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_procedures(
        procedure_id INTEGER PRIMARY KEY,
        saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (procedure_id) REFERENCES procedures (id) ON DELETE CASCADE
      )
    ''');

    await _addDummyData(db);
  }

  Future<void> _addDummyData(Database db) async {
    final categories = [
      'تمريض الأطفال',
      'الرعاية المركزة',
      'تمريض الطوارئ',
      'تمريض صحة المجتمع',
      'التمريض الجراحي',
      'تمريض الباطنة'
    ];
    final icons = [
      'child_care',
      'local_hospital',
      'emergency',
      'groups',
      'medical_services',
      'healing'
    ];

    for (int i = 0; i < categories.length; i++) {
      for (int j = 1; j <= 3; j++) {
        final procedureId = (i * 3) + j;
        await db.insert('procedures', {
          'id': procedureId,
          'name': 'إجراء ${categories[i]} رقم $j',
          'category': categories[i],
          'about':
              'هذا وصف تفصيلي عن إجراء ${categories[i]} رقم $j. يتضمن هذا الإجراء عدة خطوات مهمة لضمان سلامة المريض.',
          'indications': 'يستخدم هذا الإجراء في حالات ...',
          'contraindications': 'يمنع استخدام هذا الإجراء في حالات ...',
          'complications': 'قد تحدث بعض المضاعفات مثل ...',
          'required_tools': 'الأدوات المطلوبة: قفازات، شاش، محلول مطهر.',
          'important_info':
              'معلومات هامة: يجب التأكد من هوية المريض قبل البدء.',
          'step_count': 5,
          'category_icon': icons[i],
          'info_icon': 'info',
          'info_text': 'ملاحظة إضافية',
          'has_illustrations': 1,
        });

        for (int k = 1; k <= 5; k++) {
          await db.insert('implementations', {
            'procedure_id': procedureId,
            'step_number': k,
            'description':
                'وصف تفصيلي للخطوة رقم $k من إجراء ${categories[i]} رقم $j.',
            'rational': 'السبب العلمي للخطوة رقم $k هو ...',
            'hint': 'تلميح للخطوة رقم $k',
          });
        }

        await db.insert('illustrations', {
          'procedure_id': procedureId,
          'image_path': 'assets/images/placeholder.png' // Placeholder image
        });
      }
    }
  }

  Future<Procedure> getProcedureById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('procedures', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final procedureMap = maps.first;
      final implementations = await _getImplementationsForProcedure(id);
      final illustrations = await _getIllustrationsForProcedure(id);
      return Procedure.fromMap(procedureMap).copyWith(
          implementations: implementations, illustrations: illustrations);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Implementation>> _getImplementationsForProcedure(
      int procedureId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'implementations',
      where: 'procedure_id = ?',
      whereArgs: [procedureId],
      orderBy: 'step_number ASC',
    );
    return List.generate(maps.length, (i) => Implementation.fromMap(maps[i]));
  }

  Future<List<Illustration>> _getIllustrationsForProcedure(
      int procedureId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'illustrations',
      where: 'procedure_id = ?',
      whereArgs: [procedureId],
    );
    return List.generate(maps.length, (i) => Illustration.fromMap(maps[i]));
  }

  Future<List<Procedure>> getAllProcedures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('procedures');

    List<Procedure> procedures = [];
    for (var map in maps) {
      final implementations = await _getImplementationsForProcedure(map['id']);
      final illustrations = await _getIllustrationsForProcedure(map['id']);
      procedures.add(Procedure.fromMap(map).copyWith(
          implementations: implementations, illustrations: illustrations));
    }
    return procedures;
  }

  Future<List<Procedure>> searchProcedures(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query('procedures', where: 'name LIKE ?', whereArgs: ['%$query%']);

    List<Procedure> procedures = [];
    for (var map in maps) {
      final implementations = await _getImplementationsForProcedure(map['id']);
      final illustrations = await _getIllustrationsForProcedure(map['id']);
      procedures.add(Procedure.fromMap(map).copyWith(
          implementations: implementations, illustrations: illustrations));
    }
    return procedures;
  }

  Future<List<Procedure>> getProceduresByCategory(String categoryName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query('procedures', where: 'category = ?', whereArgs: [categoryName]);

    List<Procedure> procedures = [];
    for (var map in maps) {
      final implementations = await _getImplementationsForProcedure(map['id']);
      final illustrations = await _getIllustrationsForProcedure(map['id']);
      procedures.add(Procedure.fromMap(map).copyWith(
          implementations: implementations, illustrations: illustrations));
    }
    return procedures;
  }

  Future<List<Procedure>> getSavedProcedures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM procedures p
      INNER JOIN saved_procedures sp ON p.id = sp.procedure_id
      ORDER BY sp.saved_at DESC
    ''');

    List<Procedure> procedures = [];
    for (var map in maps) {
      final implementations = await _getImplementationsForProcedure(map['id']);
      final illustrations = await _getIllustrationsForProcedure(map['id']);
      procedures.add(Procedure.fromMap(map).copyWith(
          implementations: implementations, illustrations: illustrations));
    }
    return procedures;
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
