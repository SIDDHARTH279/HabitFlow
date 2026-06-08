import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class StatsScreen extends StatefulWidget {
  StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {

  // Month navigation state
  int _currentMonth = DateTime.now().month;
  int _currentYear  = DateTime.now().year;

  // ── Weekly Data ──────────────────────────────────
  List<double> getWeeklyData(List<HabitModel> habits) {
    List<double> data = [];
    for (int i = 6; i >= 0; i--) {
      DateTime day = DateTime.now().subtract(Duration(days: i));
      String dateStr = day.toIso8601String().split('T')[0];
      int dayIndex = day.weekday - 1;
      int count = habits.where((h) =>
      h.repeatDays.contains(dayIndex) &&
          h.completedDates.contains(dateStr)).length;
      data.add(count.toDouble());
    }
    return data;
  }

  List<double> getScheduledData(List<HabitModel> habits) {
    List<double> data = [];
    for (int i = 6; i >= 0; i--) {
      DateTime day = DateTime.now().subtract(Duration(days: i));
      int dayIndex = day.weekday - 1;
      int count = habits.where((h) => h.repeatDays.contains(dayIndex)).length;
      data.add(count.toDouble());
    }
    return data;
  }

  List<BarChartRodStackItem> buildSegments(int completed, int scheduled) {
    List<BarChartRodStackItem> items = [];
    double segmentHeight = 0.85;
    double gap = 0.15;
    for (int i = 0; i < scheduled; i++) {
      double from = i * (segmentHeight + gap);
      double to = from + segmentHeight;
      bool isDone = i < completed;
      items.add(BarChartRodStackItem(
        from, to,
        isDone ? Color(0xFF6C63FF) : Colors.white.withOpacity(0.08),
      ));
    }
    return items;
  }

  // ── Completion Rate Per Habit ────────────────────
  double getCompletionRate(HabitModel habit) {
    DateTime now = DateTime.now();
    DateTime start = DateTime.parse(habit.createdAt); // ← fix!
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

  // ── Calendar Day Color ───────────────────────────
  Color? getDayColor(List<HabitModel> habits, int day) {
    DateTime date = DateTime(_currentYear, _currentMonth, day);
    if (date.isAfter(DateTime.now())) return null; // future day

    String dateStr = date.toIso8601String().split('T')[0];
    int dayIndex = date.weekday - 1;

    int scheduled = habits.where((h) => h.repeatDays.contains(dayIndex)).length;
    if (scheduled == 0) return null; // no habits scheduled

    int completed = habits.where((h) =>
    h.repeatDays.contains(dayIndex) &&
        h.completedDates.contains(dateStr)).length;

    if (completed == 0)          return Colors.white.withOpacity(0.08); // none done
    if (completed < scheduled)   return Colors.orange.withOpacity(0.7); // some done
    return Color(0xFF6C63FF);                                            // all done!
  }

  // ── Month Name ───────────────────────────────────
  String get monthName {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[_currentMonth - 1]} $_currentYear';
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habits = habitProvider.habits;

    String today = DateTime.now().toIso8601String().split('T')[0];
    int todayIndex = DateTime.now().weekday - 1;

    int scheduledToday = habits.where((h) => h.repeatDays.contains(todayIndex)).length;
    int completedToday = habits.where((h) =>
    h.repeatDays.contains(todayIndex) &&
        h.completedDates.contains(today)).length;
    int bestStreak = habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce(max);

    final weekData      = getWeeklyData(habits);
    final scheduledData = getScheduledData(habits);

    double maxY = scheduledData.isEmpty || scheduledData.every((d) => d == 0)
        ? 1
        : scheduledData.map((s) {
      int n = s.toInt();
      return n > 0 ? n * 0.85 + (n - 1) * 0.15 : 0.0;
    }).reduce(max);

    int daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    int firstWeekday = DateTime(_currentYear, _currentMonth, 1).weekday; // Mon=1

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView( // ← scrollable now!
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HEADER ───────────────────────────
              Text('Your Progress 📊',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),

              SizedBox(height: 24),

              // ── STAT CARDS ───────────────────────
              Row(
                children: [
                  Expanded(
                    child: _statCard('🔥', '$bestStreak days', 'Best Streak'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _statCard('✅', '$completedToday/$scheduledToday', 'Done Today'),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Total Habits
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text('📋', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text('Total Habits Created',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ]),
                    Text('${habits.length}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF))),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ── TEST NOTIFICATION BUTTON ─────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => NotificationService().showTestNotification(),
                  icon: Icon(Icons.notifications_active_rounded),
                  label: Text('Test Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              SizedBox(height: 28),

              // ── WEEKLY CHART ─────────────────────
              Text('This Week',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 16),

              SizedBox(
                height: 220,
                child: BarChart(BarChartData(
                  backgroundColor: Colors.transparent,
                  maxY: maxY,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          DateTime barDay = DateTime.now()
                              .subtract(Duration(days: 6 - value.toInt()));
                          const dayNames = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                          return Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(dayNames[barDay.weekday - 1],
                                style: TextStyle(color: Colors.white54, fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    int scheduled = scheduledData[index].toInt();
                    int completed = weekData[index].toInt();
                    double barHeight = scheduled > 0
                        ? scheduled * 0.85 + (scheduled - 1) * 0.15
                        : 0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: barHeight,
                          color: Colors.transparent,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          rodStackItems: buildSegments(completed, scheduled),
                        ),
                      ],
                    );
                  }),
                )),
              ),

              SizedBox(height: 28),

              // ── MONTHLY CALENDAR ─────────────────
              Text('Monthly View 📅',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 12),

              // Month Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.white54),
                    onPressed: () {
                      setState(() {
                        if (_currentMonth == 1) {
                          _currentMonth = 12;
                          _currentYear--;
                        } else {
                          _currentMonth--;
                        }
                      });
                    },
                  ),
                  Text(monthName,
                      style: TextStyle(color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: Colors.white54),
                    onPressed: () {
                      setState(() {
                        if (_currentMonth == 12) {
                          _currentMonth = 1;
                          _currentYear++;
                        } else {
                          _currentMonth++;
                        }
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Day Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['M','T','W','T','F','S','S'].map((d) =>
                    SizedBox(width: 36,
                        child: Center(
                            child: Text(d, style: TextStyle(color: Colors.white38, fontSize: 12))))
                ).toList(),
              ),

              SizedBox(height: 8),

              // Calendar Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: (firstWeekday - 1) + daysInMonth,
                itemBuilder: (context, index) {
                  int dayNumber = index - (firstWeekday - 1) + 1;
                  if (index < firstWeekday - 1) return SizedBox(); // empty cells

                  Color? color = getDayColor(habits, dayNumber);
                  bool isToday = dayNumber == DateTime.now().day &&
                      _currentMonth == DateTime.now().month &&
                      _currentYear == DateTime.now().year;

                  return Container(
                    decoration: BoxDecoration(
                      color: color ?? Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Color(0xFF6C63FF), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text('$dayNumber',
                          style: TextStyle(
                            color: color != null ? Colors.white : Colors.white38,
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          )),
                    ),
                  );
                },
              ),

              SizedBox(height: 12),

              // Calendar Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(Color(0xFF6C63FF), 'All Done'),
                  SizedBox(width: 16),
                  _legendItem(Colors.orange.withOpacity(0.7), 'Partial'),
                  SizedBox(width: 16),
                  _legendItem(Colors.white.withOpacity(0.08), 'Missed'),
                ],
              ),

              SizedBox(height: 28),

              // ── COMPLETION RATE PER HABIT ────────
              if (habits.isNotEmpty) ...[
                Text('Habit Completion Rate 🎯',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 16),

                ...habits.map((habit) {
                  double rate = getCompletionRate(habit);
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Color(habit.color),
                                child: Icon(
                                  IconData(habit.icon, fontFamily: 'MaterialIcons'),
                                  color: Colors.white, size: 14,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(habit.name,
                                  style: TextStyle(color: Colors.white, fontSize: 14)),
                            ]),
                            Text('${(rate * 100).toInt()}%',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                )),
                          ],
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: rate,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation(Color(habit.color)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ───────────────────────────────
  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(children: [
        Text(emoji, style: TextStyle(fontSize: 32)),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
      ]),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      SizedBox(width: 4),
      Text(label, style: TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}