import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static const String databaseName = 'mushroom_information.db';
  static const String tableMushrooms = 'mushrooms';
  static const String columnId = 'id';
  static const String columnImage = 'image';
  static const String columnConfidenceScore = 'confidence_score';
  static const String columnBasicInfo = 'basic_info';
  static const String columnPhysicalCharacteristics = 'physical_characteristics';
  static const String columnLookAlike = 'look_alike';
  static const String columnUsages = 'usages';
  static const String columnSafetyTips = 'safety_tips';
  static const String columnDateOfCreation = 'date_of_creation';

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$databaseName';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableMushrooms (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnImage BLOB,
            $columnConfidenceScore REAL,
            $columnBasicInfo TEXT,
            $columnPhysicalCharacteristics TEXT,
            $columnLookAlike TEXT,
            $columnUsages TEXT,
            $columnSafetyTips TEXT,
            $columnDateOfCreation TEXT            
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllMushroomsInfo() async {
    final db = await database;
    return await db.query(tableMushrooms);
  }

  Future <void> deleteMushroomInfo(int id) async {
    final db = await database;
    await db.delete(
      tableMushrooms,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertMushroomInfo({
    required Uint8List imageBytes,
    required double confidenceScore,
    required String basicInfo,
    required String physicalCharacteristics,
    required String lookAlike,
    required String usages,
    required String safetyTips,
  }) async {
    final db = await database;
    await db.insert(tableMushrooms, {
      columnImage: imageBytes,
      columnConfidenceScore: confidenceScore,
      columnBasicInfo: basicInfo,
      columnPhysicalCharacteristics: physicalCharacteristics,
      columnLookAlike: lookAlike,
      columnUsages: usages,
      columnSafetyTips: safetyTips,
      columnDateOfCreation: DateTime.now().toIso8601String(),
    });
  }

}
