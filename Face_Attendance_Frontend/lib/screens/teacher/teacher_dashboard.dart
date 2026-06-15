import 'package:flutter/material.dart';
import '../attendance/attendance_screen.dart';
import '../attendance/manual_attendance_screen.dart';
import '../reports/report_screen.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final String deptId;

  const TeacherDashboard({super.key, required this.deptId});
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List classes = [];
  bool isLoading = true;
  List subjects = [];
  String selectedClassId = "";

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(builder: (_) => LoginScreen()),

      (route) => false,
    );
  }

  void loadSubjects(String classId) async {
    try {
      var data = await ApiService.getSubjects(classId);

      setState(() {
        subjects = data;
      });
    } catch (e) {
      print("Subject error: $e");
    }
  }

  void loadClasses() async {
    try {
      var data = await ApiService.getClasses(widget.deptId);

      setState(() {
        classes = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Teacher Dashboard", style: TextStyle(color: Colors.black)),
            Text(
              "Welcome, Teacher",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(height: 2),

            // =====================
            // ⚡ MAIN ACTIONS
            // =====================
            actionCard(
              "Start Attendance",
              "Scan student faces with camera",
              Icons.camera_alt,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceScreen(deptId: widget.deptId),
                  ),
                );
              },
            ),

            actionCard(
              "Manual Attendance",
              "Mark students manually",
              Icons.check_circle,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ManualAttendanceScreen(deptId: widget.deptId),
                  ),
                );
              },
            ),

            actionCard(
              "View Reports",
              "Check attendance analytics",
              Icons.insert_chart,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportScreen(departmentId: widget.deptId),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // =====================
            // 📅 SCHEDULE
            // =====================
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                ),

                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.class_, color: Colors.white, size: 20),

                      SizedBox(width: 8),

                      Text(
                        "Classes",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // =====================
                  // 📚 CLASSES (FROM API)
                  // =====================
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (classes.isEmpty)
                    Text("No Classes Found")
                  else
                    Column(
                      children: classes.map((c) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedClassId = c["class_id"].toString();
                            });
                            loadSubjects(selectedClassId);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedClassId == c["class_id"].toString()
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.class_, color: Colors.blue),
                                SizedBox(width: 10),
                                Expanded(child: Text(c["class_name"])),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 20),

                  // =====================
                  // 📘 SUBJECTS (FROM API)
                  // =====================
                  if (subjects.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Subjects",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    ...subjects.map((s) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.book, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              s["subject_name"],
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 STAT BOX
  Widget statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, color: color)),
            SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ⚡ ACTION CARD
  Widget actionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  // 📅 SCHEDULE ITEM
  Widget scheduleItem(String time, String subject, String cls) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(time, style: TextStyle(color: Colors.white, fontSize: 12)),

          SizedBox(width: 10),

          Container(width: 1, height: 30, color: Colors.white30),

          SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject, style: TextStyle(color: Colors.white)),
              Text(cls, style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
