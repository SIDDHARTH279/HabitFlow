import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {

  final TextEditingController _nameController = TextEditingController();
  int _selectedIcon = Icons.water_drop.codePoint;
  int _selectedColor = 0xFF6C63FF;
  List<int> _selectedDays = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final List<int> colorOptions = [
    0xFF6C63FF, 0xFF2196F3, 0xFF4CAF50, 0xFFFF5722,
    0xFFF44336, 0xFFFF9800, 0xFF9C27B0, 0xFF00BCD4,
  ];

  final List<IconData> iconOptions = [
    // Health & Fitness
    Icons.water_drop,
    Icons.directions_run,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.favorite,
    Icons.monitor_heart,
    Icons.sports_gymnastics,
    Icons.sports_soccer,
    Icons.sports_basketball,
    Icons.directions_bike,
    Icons.pool,
    Icons.hiking,

    // Mind & Learning
    Icons.menu_book,
    Icons.code,
    Icons.school,
    Icons.psychology,
    Icons.lightbulb,
    Icons.edit_note,
    Icons.language,
    Icons.calculate,

    // Lifestyle
    Icons.bedtime,
    Icons.restaurant,
    Icons.coffee,
    Icons.music_note,
    Icons.brush,
    Icons.camera_alt,
    Icons.travel_explore,
    Icons.volunteer_activism,

    // Productivity
    Icons.task_alt,
    Icons.alarm,
    Icons.work,
    Icons.savings,
    Icons.phone_android,
    Icons.no_drinks,
    Icons.smoking_rooms,
    Icons.pets,
  ];

  String? _reminderTime; // stores "07:00" format

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Habit'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Habit Name ──────────────────────────────
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Morning Run',
                    hintStyle: TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // ── Select Days ──────────────────────────────
                Text('Select Days',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final isSelected = _selectedDays.contains(index);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected
                              ? _selectedDays.remove(index)
                              : _selectedDays.add(index);
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFF6C63FF) : Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dayLabels[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 20),

                // ── Pick a Color ─────────────────────────────
                Text('Pick a Color',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(colorOptions.length, (index) {
                    final isSelected = _selectedColor == colorOptions[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorOptions[index]),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(colorOptions[index]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 20),

                // ── Choose Icon ──────────────────────────────
                Text('Choose Icon',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),

                SizedBox(
                  height: 160, // ← fixed height scrollable area
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,      // 6 icons per row
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: iconOptions.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIcon == iconOptions[index].codePoint;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = iconOptions[index].codePoint),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(_selectedColor)
                                : Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white24 : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            iconOptions[index],
                            color: isSelected ? Colors.white : Colors.white54,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.alarm, color: Color(0xFF6C63FF)),
                    title: Text(
                      _reminderTime ?? 'Set Reminder (optional)',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _reminderTime = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}';
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 32),

                // ── Save Button ──────────────────────────────
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) return;

                    final habit = HabitModel(
                      id: Uuid().v4(),
                      name: _nameController.text.trim(),
                      icon: _selectedIcon,
                      color: _selectedColor,
                      repeatDays: _selectedDays,
                      completedDates: [],
                      streak: 0,
                      createdAt: DateTime.now().toIso8601String().split('T')[0],
                      reminderTime: _reminderTime
                    );

                    context.read<HabitProvider>().addHabit(habit);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    minimumSize: Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save Habit',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}