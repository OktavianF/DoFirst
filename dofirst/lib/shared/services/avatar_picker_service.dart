import 'avatar_picker_service_stub.dart'
    if (dart.library.html) 'avatar_picker_service_web.dart';

class AvatarPickerService {
  static Future<String?> pickAvatarDataUrl() {
    return pickAvatarDataUrlImpl();
  }
}
