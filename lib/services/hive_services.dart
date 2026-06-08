import 'package:habit_tracker/models/habit.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveServices {

  static const String _boxName = 'habits';
  Box<HabitModel> get _box => Hive.box<HabitModel>(_boxName);

  Future<void> init() async{
    await Hive.initFlutter();
    Hive.registerAdapter(HabitModelAdapter());
    await Hive.openBox<HabitModel>(_boxName);
    // <HabitModel>	Tells Hive this box stores HabitModel objects specifically
    // _boxName	The name "habits" — like naming a folder
  }
  Future<void> saveHabit(HabitModel habit) async{
    _box.put(habit.id, habit);
  }
  Future<void> updateHabit(HabitModel habit) async{
    _box.put(habit.id, habit);
  }
  Future<void> deleteHabit(String id) async{
    _box.delete(id);
  }

  Future<List<HabitModel>> getAllHabit() async{
    return  _box.values.toList();
  }
}