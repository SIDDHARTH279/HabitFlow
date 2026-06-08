import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/hive_services.dart';
import 'package:habit_tracker/services/notification_service.dart';

class HabitProvider extends ChangeNotifier{

  List<HabitModel> _habits = [];
  List<HabitModel> get habits => _habits;

  final HiveServices _hiveService = HiveServices();

  Future<void> loadHabits() async{

    _habits = await _hiveService.getAllHabit();
    notifyListeners();
  }

  void addHabit(HabitModel habit) {
    _habits.add(habit);
    _hiveService.saveHabit(habit);
    NotificationService().scheduleHabitReminder(habit);
    notifyListeners();
  }

  void updateHabit(HabitModel habit) {
    // Find index of habit with matching id, replace it
    int index = _habits.indexWhere((h) => h.id == habit.id);
    _habits[index] = habit;
    _hiveService.updateHabit(habit);
    NotificationService().scheduleHabitReminder(habit);
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    _hiveService.deleteHabit(id);
    NotificationService().cancelHabitReminder(id);
    notifyListeners();
  }

  void toggleHabitCompletion(String id) {
    // STEP 1: FIND THE HABIT BY ID
    int index = _habits.indexWhere((h) => h.id == id);

    // STEP 2: GET TODAY'S DATE AS A STRING
    String today = DateTime.now().toIso8601String().split('T')[0];
    int todayDayIndex = DateTime.now().weekday - 1;


    // STEP 3: CHECK IF ALREADY COMPLETED TODAY

    if(_habits[index].completedDates.contains(today)) {
      _habits[index].completedDates.remove(today); // UNCHECK
      _habits[index].streak = calculateStreak(_habits[index].completedDates);
      NotificationService().scheduleHabitReminder(_habits[index]);
    } else {
      _habits[index].completedDates.add(today);  // CHECK
      _habits[index].streak = calculateStreak(_habits[index].completedDates);
      NotificationService().cancelTodayNotification(id, todayDayIndex);
    }

    // STEP 4: SAVE UPDATED HABIT TO HIVE
    _hiveService.updateHabit(_habits[index]);

    notifyListeners();
  }

  int calculateStreak(List<String> completedDates) {
    int streak = 0;
    DateTime day = DateTime.now();

    while(true) {
      String dateStr = day.toIso8601String().split('T')[0];

      if(completedDates.contains(dateStr)) {
        streak++;
        day = day.subtract((Duration(days: 1))); // go back one day
      } else {
        break;
      }
    }
    return streak;
  }


}