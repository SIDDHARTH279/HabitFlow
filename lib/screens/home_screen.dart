import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/add_habit_screen.dart';
import 'package:habit_tracker/screens/stats_screen.dart';
import 'package:provider/provider.dart';

import 'all_habits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  int _currentIndex = 0;  // 0 means HOME , 1 means STATS
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    // Get hour to determine greeting
    int hour = DateTime.now().hour;
    String greeting = hour >= 5 && hour < 12
        ? 'Good Morning'
        : hour >= 12 && hour < 17
        ? 'Good Afternoon'
        : hour >= 17 && hour < 21
        ? 'Good Evening'
        : 'Good Night'; // ← 9PM to 5AM
    return Scaffold(
      appBar: AppBar(title: Text('')),

      bottomNavigationBar: NavigationBar(
        backgroundColor: Color(0xFF1A1A2E),
        indicatorColor: Color(0xFF6C63FF).withOpacity(0.3),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_rounded, color: Colors.white38),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6C63FF)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded, color: Colors.white38),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF6C63FF)),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_rounded, color: Colors.white38),
            selectedIcon: Icon(Icons.list_rounded, color: Color(0xFF6C63FF)),
            label: 'All Habits',
          ),
        ],
      ),

      body: _currentIndex == 0
          ? _buildHome(habitProvider, greeting)
          : _currentIndex == 1
              ?StatsScreen()
              : AllHabitsScreen(),
      floatingActionButton: _currentIndex == 0  // ← only show on home tab
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddHabitScreen()),
          );
        },
        backgroundColor: Color(0xFF6C63FF),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text('Habit', style: TextStyle(color: Colors.white)),
      )
          : null, // ← hidden on Stats & All Habits
    );
  }
}

Widget _buildHome(HabitProvider habitProvider, String greeting) {

  int todayIndex = DateTime.now().weekday - 1;
  final todayHabits = habitProvider.habits.where((h) => h.repeatDays.contains(todayIndex)).toList();
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E), Color(0xFF16213E)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting! 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${todayHabits.length} habits today',
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
              SizedBox(height: 16),
              // Calculate completed count
              Builder(
                builder: (context) {
                  String today = DateTime.now().toIso8601String().split(
                    'T',
                  )[0];
                  int completed = todayHabits
                      .where((h) => h.completedDates.contains(today))
                      .length;
                  int total = todayHabits.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completed of $total completed',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : completed / total,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(
                            Color(0xFF6C63FF),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // HABIT LIST
        Expanded(
          child: ListView.builder(
            itemCount: todayHabits.length,
            itemBuilder: (context, index) {
              final habits = todayHabits[index];
              String today = DateTime.now().toIso8601String().split('T')[0];
              bool isCompletedToday = habits.completedDates.contains(today);


              return Dismissible(
                  key: Key(habits.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<HabitProvider>().deleteHabit(habits.id); // ← the one line!
                  },
                  child: Container(
                    // ← glassmorphism container
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(habits.color),
                        child: Icon(
                          IconData(habits.icon, fontFamily: 'MaterialIcons'),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        habits.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: habits.streak > 0
                          ? Text('${habits.streak} day streak', style: TextStyle(color: Colors.orange, fontSize: 12))
                          : Text('Start your streak today!', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      trailing: Checkbox(
                        value: isCompletedToday,
                        activeColor: Color(0xFF6C63FF),
                        onChanged: (_) {
                          context.read<HabitProvider>().toggleHabitCompletion(
                            habits.id,
                          );
                        },
                      ),
                    ),
                  )
              );
            },
          ),
        ),
      ],
    ),
  );
}