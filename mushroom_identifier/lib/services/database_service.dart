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
  static const String columnImagePath = 'image_path';
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
            $columnImagePath TEXT,
            $columnConfidenceScore REAL,
            $columnBasicInfo TEXT,
            $columnPhysicalCharacteristics TEXT,
            $columnLookAlike TEXT,
            $columnUsages TEXT,
            $columnSafetyTips TEXT,
            $columnDateOfCreation TEXT            
          )
        ''');

        // Insert sample data
        await db.insert(tableMushrooms, {
          columnImagePath: 'assets/sample/sample.jpg',
          columnConfidenceScore: 0.95,
          columnBasicInfo: '{"name": "Fly Agaric", "scientific_name": "Amanita muscaria", '
              '"edibility": "Toxic, hallucinogenic. Ingestion can cause severe gastrointestinal distress, neurological symptoms, '
              'and potentially death. Historically used for ritualistic purposes in small doses.", "toxicity_level": "Highly Toxic", "'
              'habitat": "Commonly found in mycorrhizal association with coniferous and deciduous trees, particularly birch and pine. '
              'Grows in forests."}',
          columnPhysicalCharacteristics: 'Red cap with white warts, white stem',
          columnLookAlike: 'Similar to edible mushrooms but distinguishable by warts',
          columnUsages: 'Historically ritualistic',
          columnSafetyTips: 'Avoid ingestion, seek medical help if consumed',
          columnDateOfCreation: DateTime.now().toIso8601String(),
        });
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

  // TODO: Implement add mushroom info after firebase integration and AI scanning feature

  // User cannot edit mushroom info
}
