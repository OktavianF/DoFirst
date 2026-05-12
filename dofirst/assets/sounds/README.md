# Alarm Sounds for DoFirst Focus Timer

## 📁 Directory Structure

Place your alarm sound files in this directory:
```
assets/sounds/
├── alarm.mp3          # Main alarm sound (required)
├── break_alarm.mp3    # Alternative break sound (optional)
└── focus_complete.mp3 # Alternative focus complete sound (optional)
```

## 🔊 Sound Requirements

| Property | Requirement |
|----------|-------------|
| Format | MP3, WAV, OGG, AAC, FLAC |
| Duration | 1-3 seconds (recommended) |
| Size | < 100 KB |
| Loudness | -3dB to -10dB (not too loud) |

## 📥 How to Add Alarm Sounds

### Option 1: Download Free Sounds
1. Visit [Freesound.org](https://freesound.org) or [Zapsplat.com](https://www.zapsplat.com)
2. Search for "alarm sound" or "notification sound"
3. Download in MP3 format
4. Convert to MP3 if needed using Audacity or ffmpeg:
   ```bash
   ffmpeg -i input_sound.wav -q:a 9 -n alarm.mp3
   ```
5. Place file in `assets/sounds/` folder

### Option 2: Use System Alert Sound (Automatic Fallback)
If no custom sound file exists, the app will automatically:
1. Try to load `sounds/alarm.mp3`
2. Fall back to `SystemSound.play(SystemSoundType.alert)`
3. This ensures alarm still works without custom assets

### Option 3: Generated Sounds
Use online tone generator like [Sinewave Generator](https://www.sinewave-generator.com/):
- Generate 1-2 seconds of 800-1000 Hz tone
- Export as MP3
- Save as `alarm.mp3`

## 🎵 Recommended Sounds

Popular free alarm sounds:
- **Classic Bell**: [Freesound - Classic Alarm Bell](https://freesound.org/search/?q=alarm+bell)
- **Digital Beep**: [Freesound - Beep Notification](https://freesound.org/search/?q=beep+notification)
- **Melodic Alarm**: [Freesound - Morning Alarm](https://freesound.org/search/?q=morning+alarm)

## 🔧 Troubleshooting

### Sound Not Playing
1. **File doesn't exist**: Verify file is in `assets/sounds/alarm.mp3`
2. **Wrong format**: Convert to MP3 using ffmpeg or Audacity
3. **Device silent mode**: User has device on vibrate/mute (app shows vibration instead)
4. **Sound disabled in app**: User disabled sound in Focus Settings

### Repeated Alarm Not Working
- The app automatically loops alarm for 10-15 seconds
- If audio file is less than 2 seconds, it will replay continuously
- If audio file is longer, it will play once per loop cycle

## 📱 Testing Alarm

1. Open Focus Session page
2. Set timer to 1 second (for testing)
3. Click Start button
4. Wait for timer to complete
5. You should hear alarm sound + vibration + notification

## 🛠️ Customizing Alarm Behavior

Edit `lib/shared/services/focus_notification_service.dart`:

```dart
// Change alarm duration (currently 15 seconds)
await playAlarmSound(
  soundAsset: 'sounds/alarm.mp3',
  duration: const Duration(seconds: 30), // ← Change this
);

// Change alarm loop interval (currently 2 seconds)
_alarmLoopTimer = Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
  // ← Change this to 3000ms instead of 2000ms
```

## ✅ Verification

After adding alarm sound:
```bash
# Verify file exists
ls -la assets/sounds/alarm.mp3

# Verify pubspec.yaml includes sounds folder
grep -A2 "assets:" pubspec.yaml

# Run app and test
flutter run -d chrome
```

## 📖 References

- [Audio Players Documentation](https://pub.dev/packages/audioplayers)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Haptic Feedback API](https://api.flutter.dev/flutter/services/HapticFeedback-class.html)
