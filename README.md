# HabitFlow - Flutter Habit Tracker

A modern, beautifully designed Habit Tracking application built with Flutter. It helps users build positive routines, maintain consistency through streaks, and visualize their progress over time. The app is entirely local-first, ensuring complete privacy while delivering a seamless, offline experience.

## ✨ Features

* **Daily Habit Tracking:** Easily check off your habits for the day from a clean, glassmorphism-inspired Home Screen.
* **Smart Streaks System:** Automatically calculates and tracks consecutive days of completion to keep you motivated.
* **Detailed Analytics & Statistics:** 
  * Weekly bar charts showing completion trends.
  * Monthly interactive calendar view with color-coded success rates.
  * Individual habit completion percentage tracking.
* **Custom Local Notifications:** Set exact reminder times for each habit, plus a smart "Evening Review" notification for incomplete tasks.
* **Full Customization:** Choose from 36 unique icons, 8 vibrant colors, and specific repeat days (e.g., Weekdays only, Every Mon/Wed/Fri).
* **Dark/Light Mode:** Seamlessly toggle between a premium dark theme and a clean light theme.
* **Local Persistence:** All data is securely stored on your device using Hive, ensuring blazing-fast performance and offline capability.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **State Management:** Provider
* **Local Database:** [Hive](https://pub.dev/packages/hive) (NoSQL, Key-Value database)
* **Notifications:** `flutter_local_notifications` with Android exact alarm scheduling
* **Charts/Visualizations:** `fl_chart`

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (Latest Version)
* Android Studio / VS Code
* An Android device or emulator (Android 12+ requires explicit alarm permissions)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/SIDDHARTH279/habit-tracker-app.git
   ```
2. Navigate to the project directory:
   ```bash
   cd habit-tracker-app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 📸 Screenshots
*(Add screenshots of your Home Screen, Stats Calendar, and Add Habit screen here later!)*

## 🔒 Privacy
This app is 100% offline. No user data, habits, or statistics are transmitted to any external servers. Your habits remain entirely on your device.
