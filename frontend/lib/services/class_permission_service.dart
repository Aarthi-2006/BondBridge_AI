import 'session.dart';
import 'api_service.dart';

class ClassPermissionService {
  static List<Map<String, dynamic>> assignedClasses = [];

  static Future<void> loadPermissions() async {
    assignedClasses = [];

    if (Session.teacherId == null) {
      return;
    }

    final data = await ApiService.getTeacherClasses(
      Session.teacherId!,
    );

    assignedClasses =
        List<Map<String, dynamic>>.from(data);
  }

  static bool isAssigned(
    String className,
    String section,
  ) {
    return assignedClasses.any(
      (c) =>
          c["class"].toString() == className &&
          c["section"].toString() == section,
    );
  }

  static List<Map<String, dynamic>> getClasses() {
    return assignedClasses;
  }
  // ==========================================
// GET AVAILABLE CLASSES
// ==========================================

static List<String> getAvailableClasses() {
  return assignedClasses
      .map((e) => e["class"].toString())
      .toSet()
      .toList();
}

// ==========================================
// GET AVAILABLE SECTIONS
// ==========================================

static List<String> getAvailableSections(String className) {
  return assignedClasses
      .where((e) => e["class"].toString() == className)
      .map((e) => e["section"].toString())
      .toList();
}
}