import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const String _boxName = 'deviceBox';
  static const String _key = 'device_uuid';

  static Future<String> getOrCreateDeviceId() async {
    final box = Hive.box(_boxName);

    final existingId = box.get(_key) as String?;
    if (existingId != null && existingId.isNotEmpty) {
      return existingId; // ✅ reuse
    }

    final newId = const Uuid().v4();
    await box.put(_key, newId); // ✅ store once
    return newId;
  }
}
