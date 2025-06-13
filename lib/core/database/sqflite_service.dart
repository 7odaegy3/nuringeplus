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
    _database = await _initDB('nursing_plus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // await deleteDatabase(path); // uncomment for testing to clear db on each start
    return await openDatabase(
      path,
      version: 2, // Incremented version to trigger upgrade
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For simplicity in development, we're dropping and recreating the tables.
    // In a production environment, you would use ALTER TABLE statements.
    await db.execute('DROP TABLE IF EXISTS illustrations');
    await db.execute('DROP TABLE IF EXISTS implementations');
    await db.execute('DROP TABLE IF EXISTS procedures');
    await _createDB(db, newVersion);
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
        important_info TEXT,
        step_count INTEGER NOT NULL DEFAULT 0,
        has_illustrations INTEGER NOT NULL DEFAULT 0
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
    // === Category: تمريض أطفال ===
    int proc1 = await db.insert(
        'procedures',
        {
          'name': 'قياس ضغط الدم للطفل',
          'category': 'تمريض أطفال',
          'category_icon': 'child_care',
          'info_icon': 'lightbulb_outline',
          'info_text': 'نعم',
          'about': 'إجراء حيوي لتقييم صحة القلب والأوعية الدموية لدى الأطفال.',
          'indications': '• متابعة الحالات الحرجة\n• تقييم فعالية أدوية الضغط',
          'contraindications': '• وجود جرح في الذراع',
          'complications': '• قراءة غير دقيقة\n• ألم بسيط',
          'required_tools':
              '• جهاز قياس ضغط الدم (حجم مناسب للطفل)\n• سماعة طبية',
          'important_info': '• استخدم الحجم المناسب من الكفة للطفل.',
          'step_count': 4,
          'has_illustrations': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('implementations', {
      'procedure_id': proc1,
      'step_number': 1,
      'description': 'شرح الإجراء للطفل وذويه.'
    });
    await db.insert('implementations', {
      'procedure_id': proc1,
      'step_number': 2,
      'description': 'تأكد من أن الطفل هادئ ومسترخٍ.'
    });
    await db.insert('implementations', {
      'procedure_id': proc1,
      'step_number': 3,
      'description': 'لف الكفة حول العضد بشكل صحيح.'
    });
    await db.insert('implementations', {
      'procedure_id': proc1,
      'step_number': 4,
      'description': 'سجل القراءة في ملف المريض.'
    });
    await db.insert('illustrations',
        {'procedure_id': proc1, 'image_path': 'assets/images/body_parts.png'});
    await db.insert('illustrations',
        {'procedure_id': proc1, 'image_path': 'assets/images/intestine.png'});

    // === Category: تمريض العناية المركزة ===
    int proc2 = await db.insert('procedures', {
      'name': 'تركيب أنبوب تغذية أنفي معدي',
      'category': 'تمريض العناية المركزة',
      'category_icon': 'local_hospital',
      'info_text': 'نعم',
      'about': 'إدخال أنبوب عبر الأنف إلى المعدة للتغذية أو لإعطاء الأدوية.',
      'indications': '• عدم قدرة المريض على البلع',
      'contraindications': '• انسداد في المريء',
      'complications': '• دخول الأنبوب إلى الرئة',
      'required_tools': '• أنبوب تغذية\n• قفازات\n• جل مزلق',
      'important_info':
          '• التأكد من موضع الأنبوب بالأشعة السينية هو المعيار الذهبي.',
      'step_count': 5,
      'has_illustrations': 1,
    });
    await db.insert('implementations', {
      'procedure_id': proc2,
      'step_number': 1,
      'description':
          'قياس طول الأنبوب من الأنف إلى الأذن ثم إلى أسفل عظمة القص.'
    });
    await db.insert('implementations', {
      'procedure_id': proc2,
      'step_number': 2,
      'description': 'تزييت طرف الأنبوب بالجل.'
    });
    await db.insert('implementations', {
      'procedure_id': proc2,
      'step_number': 3,
      'description': 'إدخال الأنبوب بلطف عبر فتحة الأنف.'
    });
    await db.insert('implementations', {
      'procedure_id': proc2,
      'step_number': 4,
      'description':
          'اطلب من المريض البلع (إذا كان واعيًا) للمساعدة في مرور الأنبوب.'
    });
    await db.insert('implementations', {
      'procedure_id': proc2,
      'step_number': 5,
      'description': 'تثبيت الأنبوب بشريط لاصق على الأنف.'
    });
    await db.insert('illustrations',
        {'procedure_id': proc2, 'image_path': 'assets/images/intestine.png'});

    int proc3 = await db.insert('procedures', {
      'name': 'شفط الإفرازات من مجرى الهواء',
      'category': 'تمريض العناية المركزة',
      'category_icon': 'local_hospital',
      'info_text': 'لا',
      'about':
          'إجراء لإزالة الإفرازات من الجهاز التنفسي للمرضى الذين لا يستطيعون السعال بفعالية.',
      'indications': '• تراكم الإفرازات في مجرى الهواء',
      'required_tools': '• جهاز شفط\n• قسطرة شفط معقمة\n• قفازات معقمة',
      'step_count': 3,
      'has_illustrations': 0,
    });
    await db.insert('implementations', {
      'procedure_id': proc3,
      'step_number': 1,
      'description': 'توصيل قسطرة الشفط بجهاز الشفط.'
    });
    await db.insert('implementations', {
      'procedure_id': proc3,
      'step_number': 2,
      'description': 'إدخال القسطرة بلطف ودون تطبيق الشفط.'
    });
    await db.insert('implementations', {
      'procedure_id': proc3,
      'step_number': 3,
      'description': 'تطبيق الشفط بشكل متقطع أثناء سحب القسطرة بحركة دائرية.'
    });

    // === Category: تمريض صحة المجتمع ===
    int proc4 = await db.insert('procedures', {
      'name': 'إعطاء التطعيمات',
      'category': 'تمريض صحة المجتمع',
      'category_icon': 'groups',
      'info_text': 'نعم',
      'about': 'إعطاء اللقاحات للوقاية من الأمراض المعدية.',
      'important_info': '• التأكد من سلسلة التبريد للقاح.',
      'step_count': 4,
      'has_illustrations': 1,
    });
    await db.insert('implementations', {
      'procedure_id': proc4,
      'step_number': 1,
      'description': 'التحقق من هوية المريض واللقاح المطلوب.'
    });
    await db.insert('implementations', {
      'procedure_id': proc4,
      'step_number': 2,
      'description': 'تحديد موقع الحقن المناسب (مثل العضلة الدالية).'
    });
    await db.insert('implementations', {
      'procedure_id': proc4,
      'step_number': 3,
      'description': 'تطهير الجلد بالكحول.'
    });
    await db.insert('implementations', {
      'procedure_id': proc4,
      'step_number': 4,
      'description': 'حقن اللقاح والتخلص من الإبرة بأمان.'
    });
    await db.insert('illustrations',
        {'procedure_id': proc4, 'image_path': 'assets/images/body_parts.png'});
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
