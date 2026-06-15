import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ManualAttendanceScreen extends StatefulWidget {
  final String deptId;

  const ManualAttendanceScreen({super.key, required this.deptId});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  String selectedClass = "";
  String selectedSubject = "";

  bool isStarted = false;
  bool isStopped = false;
  List classes = [];
  List subjects = [];

  String selectedSubjectId = "";

  Map<String, String?> attendance = {};

  List students = [];
  String selectedClassId = "";

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void loadStudents(String classId) async {
    var data = await ApiService.getStudentsByClass(classId);

    setState(() {
      students = data;
    });
  }

  void loadSubjects(String classId) async {
    var data = await ApiService.getSubjects(classId);

    setState(() {
      subjects = data;
    });
  }

  void loadClasses() async {
    var data = await ApiService.getClasses(widget.deptId);

    setState(() {
      classes = data;
    });
  }

  void mark(String studentId, String status) async {
    print(studentId);
    print(selectedSubjectId);
    print(status);
    try {
      await ApiService.markAttendance(studentId, selectedSubjectId, status);

      setState(() {
        attendance[studentId] = status;
      });
    } catch (e) {
      print("Error marking attendance: $e");
    }
  }

  int get presentCount => students
      .where((s) => attendance[s["student_id"].toString()] == "present")
      .length;

  int get absentCount => students
      .where((s) => attendance[s["student_id"].toString()] == "absent")
      .length;

  int get unmarkedCount => students
      .where((s) => attendance[s["student_id"].toString()] == null)
      .length;

  @override
  Widget build(BuildContext context) {
    if (isStopped) return summaryScreen();

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),

      appBar: AppBar(
        title: Text("Manual Attendance", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            // SELECTORS
            if (!isStarted) ...[
              dropdown(
                "Select Class",

                selectedClass,

                classes
                    .map<String>((cls) => cls["class_name"].toString())
                    .toList(),

                (val) {
                  setState(() {
                    selectedClass = val;

                    selectedClassId = classes
                        .firstWhere((c) => c["class_name"] == val)["class_id"]
                        .toString();
                  });

                  loadSubjects(selectedClassId);

                  loadStudents(selectedClassId);
                },
              ),

              SizedBox(height: 10),

              dropdown(
                "Select Subject",
                selectedSubject,
                subjects
                    .map<String>((sub) => sub["subject_name"].toString())
                    .toList(),

                (v) {
                  setState(() {
                    selectedSubject = v;

                    selectedSubjectId = subjects
                        .firstWhere((s) => s["subject_name"] == v)["subject_id"]
                        .toString();
                  });
                  print(selectedSubjectId);
                },
              ),
            ],

            SizedBox(height: 15),

            // SESSION INFO
            if (isStarted)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$selectedClass · $selectedSubject"),
                    Row(
                      children: [
                        Text(
                          "$presentCount",
                          style: TextStyle(color: Colors.green),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "$absentCount",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            SizedBox(height: 15),

            // STUDENT LIST
            if (isStarted)
              Expanded(
                child: ListView(
                  children: students.map((s) {
                    String? status = attendance[s["student_id"].toString()];

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(s["name"].toString())),

                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: status == "present"
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    mark(s["student_id"].toString(), "present"),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: status == "absent"
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    mark(s["student_id"].toString(), "absent"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // BUTTON
            if (!isStarted)
              ElevatedButton(
                onPressed: selectedClass.isEmpty || selectedSubject.isEmpty
                    ? null
                    : () {
                        setState(() {
                          isStarted = true;
                          attendance.clear();
                        });
                      },
                child: Text("Start Attendance"),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    isStarted = false;
                    isStopped = true;
                  });
                },
                child: Text("Stop & Save"),
              ),
          ],
        ),
      ),
    );
  }

  // SUMMARY SCREEN
  Widget summaryScreen() {
    return Scaffold(
      appBar: AppBar(title: Text("Summary")),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                statBox("Present", presentCount, Colors.green),
                statBox("Absent", absentCount, Colors.red),
                statBox("Unmarked", unmarkedCount, Colors.orange),
              ],
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: students.map((s) {
                  String? status = attendance[s["student_id"].toString()];
                  return ListTile(
                    title: Text(s["name"].toString()),
                    subtitle: Text(s["roll_no"].toString()),
                    trailing: Text(
                      status ?? "Unmarked",
                      style: TextStyle(
                        color: status == "present"
                            ? Colors.green
                            : status == "absent"
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  isStopped = false;
                  selectedClass = "";
                  selectedSubject = "";
                });
              },
              child: Text("New Session"),
            ),
          ],
        ),
      ),
    );
  }

  Widget dropdown(
    String hint,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton(
        hint: Text(hint),
        value: value.isEmpty ? null : value,
        isExpanded: true,
        underline: SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v as String),
      ),
    );
  }

  Widget statBox(String label, int value, Color color) {
    return Column(
      children: [
        Text("$value", style: TextStyle(color: color, fontSize: 20)),
        Text(label),
      ],
    );
  }
}
