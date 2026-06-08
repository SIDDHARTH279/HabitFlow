# 🔥 HabitFlow — Habit Tracker App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FF7A00?style=for-the-badge&logo=hive&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-6C63FF?style=for-the-badge&logoColor=white)

A beautiful, offline-first habit tracking app built with Flutter.  
Build consistency, track streaks, and achieve your goals — one day at a time.

</div>

---

## 📱 Screenshots

| Home Screen | Add Habit | Stats |
|---|---|---|
| ![Home](screenshots/home.png) | ![Add](screenshots/add_habit.png) | ![Stats](screenshots/stats.png) |

---

## ✨ Features

- ✅ **Create Custom Habits** — Name, icon, color, and repeat days
- 🔥 **Streak Tracking** — Track your longest and current streaks
- 📊 **Progress Bar** — See daily completion at a glance
- 🎨 **Beautiful Dark UI** — Glassmorphism design with gradient backgrounds
- 🔔 **Local Notifications** — Daily reminders for each habit
- 💾 **Offline First** — All data stored locally using Hive (no internet needed)
- 🗓️ **Custom Schedules** — Set habits for specific days of the week
- 🗑️ **Swipe to Delete** — Easily remove habits with a swipe gesture
- 📈 **Stats Screen** — Weekly charts and monthly calendar view

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Hive** | Fast local NoSQL database (offline storage) |
| **Provider** | State management |
| **flutter_local_notifications** | Daily habit reminders |
| **fl_chart** | Progress charts and graphs |
| **uuid** | Unique ID generation for habits |
| **intl** | Date formatting |
| **google_fonts** | Custom typography |

---

## 📂 Project Structure

```
lib/
├── main.dart                  # App entry point + theme setup
├── models/
│   ├── habit.dart             # Habit data model
│   └── habit.g.dart           # Auto-generated Hive adapter
├── providers/
│   └── habit_provider.dart    # State management (ChangeNotifier)
├── screens/
│   ├── home_screen.dart       # Main habits list screen
│   ├── add_habit_screen.dart  # Create/edit habit screen
│   └── stats_screen.dart      # Progress & analytics screen
├── services/
│   └── hive_services.dart     # Database CRUD operations
└── widgets/
    └── habit_card.dart        # Reusable habit card widget
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SIDDHARTH279/habit_tracker.git
   cd habit_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture

This app follows a clean **3-layer architecture**:

```
UI Layer (Screens & Widgets)
        ↕
State Layer (Provider)
        ↕
Data Layer (HiveService + Hive DB)
```

- **UI** never talks to the database directly
- **Provider** acts as the bridge between UI and data
- **HiveService** handles all database operations

---

## 📦 Key Dependencies

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.1.2
  flutter_local_notifications: ^18.0.1
  fl_chart: ^0.69.0
  uuid: ^4.5.1
  intl: ^0.19.0
  google_fonts: ^6.2.1

dev_dependencies:
  hive_generator: ^1.1.3
  build_runner: ^2.4.13
```

---

## 🎯 What I Learned

Building this project taught me:

- 📦 **Local database management** with Hive (NoSQL, type adapters, code generation)
- 🔄 **State management** using Provider and ChangeNotifier pattern
- 🏗️ **Clean architecture** — separating UI, business logic, and data layers
- 📱 **Android configuration** — Gradle setup, desugaring, build types
- 🔔 **Local notifications** scheduling and management
- 🎨 **Modern UI design** — Glassmorphism, dark themes, gradient backgrounds
- 📊 **Data visualization** with fl_chart
- 🚀 **Play Store deployment** — signing, release builds, store listing

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---



<div align="center">
  <b>If you found this helpful, please ⭐ the repository!</b>
</div>
