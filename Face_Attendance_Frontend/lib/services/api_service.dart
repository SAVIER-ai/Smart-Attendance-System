import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  // static const String baseUrl = "http://192.168.79.217:5000/api";
  // static const String baseUrl = "http://10.135.55.79:5000/api";
  static const String baseUrl = "http://192.168.121.190:5000/api";

  // ======================
  // ADMIN LOGIN
  // ======================
  static Future<Map<String, dynamic>> adminLogin(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // ======================
  // TEACHER LOGIN
  // ======================
  static Future<Map<String, dynamic>> teacherLogin(
    String email,
    String password,
    String departmentCode,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/teacher/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "department_code": departmentCode, // 🔥 REQUIRED
      }),
    );

    return jsonDecode(response.body);
  }

  // ======================
  // REGISTER STUDENT
  // ======================
  static Future<Map<String, dynamic>> registerStudent(
    String name,
    String roll,
    String className,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/student/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "roll": roll, "class": className}),
    );

    return jsonDecode(res.body);
  }

  // ======================
  // GET STUDENTS
  // ======================
  static Future<List<dynamic>> getAllStudents(String adminId) async {
    final response = await http.get(Uri.parse("$baseUrl/student/all/$adminId"));

    final data = jsonDecode(response.body);

    return data["data"];
  }

  static Future markAttendance(
    String studentId,
    String subjectId,
    String status,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/attendance/manual"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "student_id": studentId,
        "subject_id": subjectId,
        "status": status,
      }),
    );

    print(response.body);

    return jsonDecode(response.body);
  }

  static Future faceAttendance(
    String classId,
    String subjectId,
    String image,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/attendance/mark"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "class_id": classId,
        "subject_id": subjectId,
        "image": image,
      }),
    );
    print(response.body);

    return jsonDecode(response.body);
  }

  static Future registerStudentWithImage(
    String name,
    String roll,
    String className,
    File image,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/student/register"),
    );

    request.fields['name'] = name;
    request.fields['roll'] = roll;
    request.fields['class'] = className;

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    await request.send();
  }

  static Future<Map<String, dynamic>> markAttendanceWithImage(
    File image,
    String classId,
    String subjectId,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/attendance/mark"),
    );

    request.fields['class_id'] = classId;
    request.fields['subject_id'] = subjectId;

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();
    var resBody = await response.stream.bytesToString();

    return jsonDecode(resBody);
  }

  static Future<Map<String, dynamic>> markAttendanceBase64(
    String base64Image,
    String classId,
    String subjectId,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/attendance/mark"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "image": base64Image,
        "class_id": classId,
        "subject_id": subjectId,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future registerStudentBase64(
    String name,
    String rollNo,
    String classId,
    String phone,
    String base64Image,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/student/register"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "name": name,
        "roll_no": rollNo,
        "phone": phone,
        "class_id": classId,
        "image": base64Image,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createDepartment(
    String name,
    String adminId,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/department/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "admin_id": adminId}),
    );

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getDepartments(String adminId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/departments/$adminId"),
    );

    final data = jsonDecode(response.body);

    return data["data"];
  }

  static Future<List<dynamic>> getClasses(String deptId) async {
    final res = await http.get(Uri.parse("$baseUrl/admin/classes/$deptId"));

    final decoded = jsonDecode(res.body);

    return decoded["data"];
  }

  static Future<List<dynamic>> getSubjects(String classId) async {
    final res = await http.get(Uri.parse("$baseUrl/admin/subjects/$classId"));

    final decoded = jsonDecode(res.body);
    return decoded["data"];
  }

  // 🔐 ADMIN SIGNUP
  static Future<Map<String, dynamic>> adminSignup(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return jsonDecode(res.body);
  }

  // 👨‍🏫 TEACHER SIGNUP
  static Future<Map<String, dynamic>> teacherSignup(
    String name,
    String email,
    String password,
    String code,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/teacher/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "department_code": code,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future deleteDepartment(String deptId) async {
    await http.delete(Uri.parse("$baseUrl/admin/department/delete/$deptId"));
  }

  static Future createClass(String name, String deptId) async {
    await http.post(
      Uri.parse("$baseUrl/admin/class/create"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({"name": name, "department_id": deptId}),
    );
  }

  static Future createSubject(String name, String classId) async {
    await http.post(
      Uri.parse("$baseUrl/admin/subject/create"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({"name": name, "class_id": classId, "teacher_id": null}),
    );
  }

  static Future deleteClass(String classId) async {
    await http.delete(Uri.parse("$baseUrl/admin/class/delete/$classId"));
  }

  static Future deleteSubject(String subjectId) async {
    await http.delete(Uri.parse("$baseUrl/admin/subject/delete/$subjectId"));
  }

  static Future<List<dynamic>> getStudentsByClass(String classId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/student/class/$classId"),
    );

    final data = jsonDecode(response.body);

    return data["data"];
  }

  static Future<List<dynamic>> getReport(
    String classId,
    String rollNo,
    String date,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/attendance/report"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({"class_id": classId, "roll_no": rollNo, "date": date}),
    );

    final decoded = jsonDecode(response.body);

    return decoded["data"];
  }

  static Future deleteStudent(String studentId) async {
    await http.delete(Uri.parse("$baseUrl/student/delete/$studentId"));
  }

  static Future getOverview(String adminId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/overview/$adminId"),
    );

    return jsonDecode(response.body);
  }
}
