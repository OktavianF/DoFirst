# Background Timer Implementation

## 📋 Overview

Fitur background timer memungkinkan timer focus session tetap berjalan bahkan ketika app di-minimize atau di-background. User akan mendapatkan notifikasi ketika timer selesai.

## 🔧 Implementation Details

### 1. **FocusSessionViewModel Enhancement** 
File: `lib/features/focus/presentation/focus_session/focus_session_view_model.dart`

**Perubahan:**
- Tambah `_targetEndAt` untuk track waktu target completion (bukan hanya remaining seconds)
- Implementasi `_saveTimerState()` - menyimpan timer state ke SharedPreferences saat app pause
- Implementasi `_restoreTimerStateFromBackground()` - restore state saat app resume
- Update `didChangeAppLifecycleState()` - save state sebelum app masuk background

**Key Methods:**
```dart
// Save timer state untuk background persistence
Future<void> _saveTimerState()

// Restore timer state dari background
Future<void> _restoreTimerStateFromBackground()

// Recalculate remaining seconds dari target end time
void _syncRemainingFromTarget()

// Restart periodic timer yang tick setiap 1 detik
void _restartPeriodicTimer()
```

### 2. **Background Task Handler**
File: `lib/shared/services/focus_background_task.dart`

**Tanggung Jawab:**
- Setup background_fetch untuk monitor timer setiap 15 menit
- Handle periodic background checks untuk timer completion
- Show notification ketika timer selesai
- Prepare next session (switch antara focus & break)

**Static Methods:**
```dart
// Initialize background task handler
static Future<void> init()

// Start background monitoring
static Future<void> start()

// Stop background monitoring  
static Future<void> stop()
```

### 3. **Integration di FocusSessionPage**
File: `lib/features/focus/presentation/focus_session/focus_session_page.dart`

**Perubahan:**
- Tambah wrapper method `_handleToggleTimer()` - toggle timer + manage background task
- Tambah wrapper method `_handleStopTimer()` - stop timer + stop background task
- Update `_buildControls()` untuk menggunakan wrapper methods

**Flow:**
1. User tekan Play → Timer start + Background monitoring start
2. User tekan Pause → Timer pause + Background monitoring stop
3. User tekan Reset → Timer stop + Background monitoring stop
4. App minimize → Timer state di-save ke SharedPreferences
5. System trigger background check (setiap 15 menit) → Check jika timer selesai → Show notification
6. User buka app → Restore timer state + Continue timer

## 📱 How It Works

### User Flow
```
┌─────────────────────────┐
│  User Start Timer       │
│  (Play button)          │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Timer Running          │
│  Background Start       │
│  State Saved            │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  App Minimize/Pause     │
│  State Saved            │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  System Background Check│
│  (Every 15 minutes)     │
└────────────┬────────────┘
             │
      ┌──────▼──────┐
      │             │
   [Time Remains]  [Timer Done]
      │             │
      │             ▼
      │      ┌──────────────┐
      │      │ Show Notif   │
      │      │ Save Next    │
      │      │ Session      │
      │      └──────────────┘
      │
      ▼
┌─────────────────────────┐
│  User Open App          │
│  Restore State          │
│  Continue Timer         │
└─────────────────────────┘
```

## 🔑 Key Variables (SharedPreferences)

```dart
// Timer state persistence keys
'focus_timer_state'       // Future use
'focus_timer_target'      // Target end time (ISO 8601 string)
'focus_timer_is_break'    // Boolean: is break mode?
'focus_timer_is_running'  // Boolean: is timer running?
```

## ⚙️ Android & iOS Specific

### Android
- Menggunakan WorkManager internally oleh background_fetch
- Tidak memerlukan configurasi khusus di AndroidManifest.xml
- Berjalan setiap 15 menit (dapat diubah di `minimumFetchInterval`)

### iOS
- Menggunakan Background App Refresh
- Memerlukan capability "Background Modes" di Xcode
- Berjalan lebih fleksibel tergantung system battery/memory

### Flutter Web
- Background fetch tidak tersedia (limitation web browser)
- Timer tetap berjalan selama browser tab open
- Recommendation: User tidak close browser tab saat timer active

## 🧪 Testing

### Manual Test
1. Start timer di focus session
2. Minimize app (press home button)
3. Wait 15 minutes untuk background check trigger (atau test in dev dengan `minimumFetchInterval: 1`)
4. Check notification saat timer selesai
5. Open app → Timer state restored

### Debug Print Statements
Background task handler menggunakan `print()` statements untuk debugging:
```dart
print('[FocusBackgroundTask] Background fetch started: $status');
print('[FocusBackgroundTask] Timer target: $target, now: $now, diff: $diff seconds');
print('[FocusBackgroundTask] Error in background fetch: $e');
```

## 📦 Dependencies

```yaml
background_fetch: ^1.6.2
wakelock_plus: ^1.2.11         # Keep screen on saat timer active
flutter_local_notifications: ^18.0.1  # Show notifications
```

## ⚠️ Known Limitations

1. **Flutter Web**: Background execution tidak tersedia (browser limitation)
2. **Strict Mode**: Jika strict mode active, timer stop ketika app minimize (intentional)
3. **Frequency**: Background check hanya setiap 15 menit (balance battery vs accuracy)
4. **Notification Timing**: Mungkin delay beberapa menit tergantung OS scheduling

## 🚀 Future Improvements

1. Allow user configure background check frequency
2. Add persistent notification saat timer running (Android notification badge)
3. Use WorkManager directly untuk Android untuk lebih granular control
4. Add sound/vibration saat timer complete di background
5. Store multiple timer sessions history
