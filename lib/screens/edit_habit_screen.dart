import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';

class EditHabitScreen extends StatefulWidget {
  final HabitModel habit;
  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {

  late TextEditingController _nameController;
  late int _selectedIcon;
  late int _selectedColor;
  late List<int> _selectedDays;
  late String? _reminderTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _selectedIcon   = widget.habit.icon;
    _selectedColor  = widget.habit.color;
    _selectedDays   = List.from(widget.habit.repeatDays);
    _reminderTime   = widget.habit.reminderTime;
  }

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
    Icons.water_drop, Icons.directions_run, Icons.menu_book,
    Icons.self_improvement, Icons.fitness_center, Icons.bedtime,
    Icons.restaurant, Icons.favorite, Icons.music_note, Icons.code,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Habit'),
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
                          color: isSelected
                              ? Color(0xFF6C63FF)
                              : Colors.white.withOpacity(0.1),
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
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(iconOptions.length, (index) {
                    final isSelected = _selectedIcon == iconOptions[index].codePoint;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = iconOptions[index].codePoint),
                      child: Container(
                        width: 44,
                        height: 44,
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
                  }),
                ),

                SizedBox(height: 20),

                // ── Set Reminder ─────────────────────────────
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
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.white38, size: 16),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _reminderTime =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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

                    final updated = HabitModel(
                      id: widget.habit.id,                     // ← keep same ID
                      name: _nameController.text.trim(),
                      icon: _selectedIcon,
                      color: _selectedColor,
                      repeatDays: _selectedDays,
                      completedDates: widget.habit.completedDates, // ← keep history
                      streak: widget.habit.streak,                 // ← keep streak
                      createdAt: widget.habit.createdAt,           // ← keep date
                      reminderTime: _reminderTime,
                    );

                    context.read<HabitProvider>().updateHabit(updated);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    minimumSize: Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
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