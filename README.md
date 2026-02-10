# MedAdhere – Medication Adherence Companion

A Flutter-based medication tracker designed to help patients manage chronic conditions by improving adherence through reminders, dose logging, and simple analytics.

Built as a offline first, habit tracking tool for reminding user of their medication.

---

## ✅ Current Features (Working)

- **Add Medications**: Enter medicine name, dosage, frequency (Daily/Weekly/Bi-Weekly/Custom), and multiple 12-hour dose times.
- **Local Persistence**: All data saved offline using **Hive** (No internet required).
- **Clean UI**: Intuitive form + home screen with swipe-to-delete.
- **Responsive Design**: Works on mobile & tablet.

---

## 🚧 Coming Soon

- Notification reminders at scheduled dose times (Android/iOS).
- Mark doses as **Taken / Missed**
- Weekly **adherence percentage** & streaks
- Export data as CSV
- Accessibility enhancements (large text, high contrast)
- Edit existing medications

> *Note: Web support is limited (no notifications). Best experienced on Android/iOS.*

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (planned), currently StatefulWidget
- **Local DB**: Hive (NoSQL, offline-first)
- **Notifications**: `flutter_local_notifications`
- **Navigation**: `go_router`
- **UI**: Material 3

---

## ▶️ How to Run

1. Clone the repo:
   ```bash
   git clone https://github.com/your-username/med-adhere.git
   cd med-adhere
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run on device (recommended for notifications):
   ```bash
   flutter run -d android   # or -d ios
   ```

> 💡 For web: `flutter run -d chrome` (note: notifications won’t work).

---

## 📎 Inspiration

Built to address a core challenge in chronic care: **medication non-adherence**. Designed with empathy for elderly patients and simplicity in mind.

> “Take your pills” isn’t enough. We need **gentle, reliable nudges** — not judgment.

---

## 📄 License

MIT License — feel free to learn, fork, and improve!
```
