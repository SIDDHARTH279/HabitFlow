import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import 'edit_habit_screen.dart';

class AllHabitsScreen extends StatefulWidget {
  const AllHabitsScreen({super.key});

  @override
  State<AllHabitsScreen> createState() => _AllHabitsScreenState();
}

class _AllHabitsScreenState extends State<AllHabitsScreen> {

  String _sortBy = 'streak'; // 'streak', 'name', 'days'

  final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // ── Completion Rate ──────────────────────────────
  double getCompletionRate(HabitModel habit) {
    DateTime now = DateTime.now();
    DateTime start = DateTime.parse(habit.createdAt);
    int totalScheduled = 0;
    int completed = 0;

    DateTime day = start;
    while (!day.isAfter(now)) {
      int dayIndex = day.weekday - 1;
      if (habit.repeatDays.contains(dayIndex)) {
        totalScheduled++;
        String dateStr = day.toIso8601String().split('T')[0];
        if (habit.completedDates.contains(dateStr)) completed++;
      }
      day = day.add(Duration(days: 1));
    }
    return totalScheduled == 0 ? 0 : completed / totalScheduled;
  }

  // ── Sort Habits ──────────────────────────────────
  List<HabitModel> getSortedHabits(List<HabitModel> habits) {
    List<HabitModel> sorted = List.from(habits);
    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'days':
        sorted.sort((a, b) => b.repeatDays.length.compareTo(a.repeatDays.length));
        break;
      case 'streak':
      default:
        sorted.sort((a, b) => b.streak.compareTo(a.streak));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;
    final sortedHabits = getSortedHabits(habits);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER ───────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All Habits 📋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  Text('${habits.length} total',
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ),

            // ── SORT OPTIONS ─────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Sort: ', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  SizedBox(width: 8),
                  _sortChip('🔥 Streak', 'streak'),
                  SizedBox(width: 8),
                  _sortChip('🔤 Name', 'name'),
                  SizedBox(width: 8),
                  _sortChip('📅 Days', 'days'),
                ],
              ),
            ),

            SizedBox(height: 12),

            // ── HABIT LIST ───────────────────────────
            Expanded(
              child: habits.isEmpty
                  ? Center(
                child: Text(
                  'No habits yet!\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: sortedHabits.length,
                padding: EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) {
                  final habit = sortedHabits[index];
                  double rate = getCompletionRate(habit);
                  int totalCompletions = habit.completedDates.length;

                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Row 1: Icon + Name + Buttons
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(habit.color),
                                child: Icon(
                                  IconData(habit.icon,
                                      fontFamily: 'MaterialIcons'),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(habit.name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                    SizedBox(height: 2),
                                    // Stats row
                                    Row(
                                      children: [
                                        Text(
                                          '🔥 ${habit.streak} streak',
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 11),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '✅ $totalCompletions done',
                                          style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11),
                                        ),
                                        if (habit.reminderTime != null) ...[
                                          SizedBox(width: 10),
                                          Text(
                                            '⏰ ${habit.reminderTime}',
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Edit + Delete buttons
                              IconButton(
                                icon: Icon(Icons.edit_rounded,
                                    color: Color(0xFF6C63FF), size: 20),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            EditHabitScreen(habit: habit)),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_rounded,
                                    color: Colors.red.shade400, size: 20),
                                onPressed: () => _confirmDelete(context, habit),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          // ── Row 2: Selected Days ──────────
                          Row(
                            children: List.generate(7, (i) {
                              bool isSelected =
                              habit.repeatDays.contains(i);
                              return Container(
                                width: 28,
                                height: 28,
                                margin: EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(habit.color)
                                      : Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    dayLabels[i],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white24,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          SizedBox(height: 10),

                          // ── Row 3: Completion Rate ────────
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Completion Rate',
                                  style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11)),
                              Text('${(rate * 100).toInt()}%',
                                  style: TextStyle(
                                    color: Color(habit.color),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                          SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: rate,
                              backgroundColor:
                              Colors.white.withOpacity(0.08),
                              valueColor: AlwaysStoppedAnimation(
                                  Color(habit.color)),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sort Chip ────────────────────────────────────
  Widget _sortChip(String label, String value) {
    bool isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFF6C63FF).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Color(0xFF6C63FF)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? Color(0xFF6C63FF) : Colors.white38,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }

  // ── Delete Confirmation ──────────────────────────
  void _confirmDelete(BuildContext context, HabitModel habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Habit?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${habit.name}"?\nThis cannot be undone.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitProvider>().deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}