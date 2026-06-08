import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class HabitModel {

  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int icon;
  @HiveField(3)
  int color;
  @HiveField(4)
  List<int> repeatDays;
  @HiveField(5)
  String? reminderTime;
  @HiveField(6)
  List<String> completedDates;
  @HiveField(7)
  int streak;
  @HiveField(8)
  String createdAt;

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.repeatDays,
    this.reminderTime,
    required this.completedDates,
    required this.streak,
    required this.createdAt,
  });
}