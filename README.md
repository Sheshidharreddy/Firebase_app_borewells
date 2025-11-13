# ServiceMaster - Vehicle Maintenance Management

A Flutter web app for easy vehicle maintenance tracking. Simplified interface for non-technical users.

## 🚀 Quick Setup

### 1. Install Flutter
- Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
- Add Flutter to your PATH

### 2. Clone & Run
```bash
git clone <your-repo-url>
cd servicemaster
flutter pub get
flutter run -d web-server --web-port=8081
```

### 3. Open in Browser
```
http://localhost:8081
```

## 👥 Test Login

**Admin User**
- Email: `admin@servicemaster.com`  
- Password: `123456`

**Regular User** 
- Email: `driver@servicemaster.com`
- Password: `123456`

Or just click the colored login buttons!

## � Dependencies 

All dependencies are automatically installed with `flutter pub get`:

- **flutter**: Core framework
- **firebase_core**: ^3.6.0 (for authentication)
- **firebase_auth**: ^5.3.1 (user login)
- **cloud_firestore**: ^5.4.4 (database)
- **cupertino_icons**: ^1.0.8 (icons)

## ✨ Features

### For Admins
- Manage all vehicles and users
- View maintenance schedules  
- Complete system access

### For Users (Simplified)
- Log maintenance with dropdowns only
- Update vehicle hours/kilometers
- View maintenance status (Red/Yellow/Green)
- No complex typing required!

## 🚨 Troubleshooting

**App won't start?**
```bash
flutter clean
flutter pub get
flutter run -d web-server --web-port=8081
```

**Port busy?** Try a different port:
```bash
flutter run -d web-server --web-port=8082
```

**Login not working?** Use the quick login buttons (Red = Admin, Green = User)

## 📝 Pre-defined Maintenance Items
1. Engine Oil Change (250 hrs/5,000 km)
2. Air Filter (500 hrs/10,000 km)  
3. Fuel Filter (500 hrs/12,000 km)
4. Hydraulic Oil (1,000 hrs/20,000 km)
5. Coolant Check (750 hrs/15,000 km)
6. Brake Inspection (600 hrs/12,000 km)
7. Tire Pressure (100 hrs/2,000 km)
8. General Inspection (300 hrs/6,000 km)

---
**Built with Flutter • Ready to use offline • No Firebase setup required**
