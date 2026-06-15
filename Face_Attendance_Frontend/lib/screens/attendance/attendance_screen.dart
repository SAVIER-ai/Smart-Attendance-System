import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';
import 'dart:convert';

class AttendanceScreen extends StatefulWidget {
  final String deptId;

  const AttendanceScreen({super.key, required this.deptId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedClass = "";
  String selectedSubject = "";

  List classes = [];
  List subjects = [];
  String selectedClassId = "";
  String selectedSubjectId = "";

  bool isScanning = false;
  String? detectedName;
  bool isRecognized = true;
  File? capturedImage;
  final picker = ImagePicker();
  List<Map<String, String>> presentStudents = [];
  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void loadClasses() async {
    var data = await ApiService.getClasses(widget.deptId); // temp dept_id

    setState(() {
      classes = data;
    });
  }

  void loadSubjects(String classId) async {
    var data = await ApiService.getSubjects(classId);

    setState(() {
      subjects = data;
    });
  }

  void scanFaceAndMark() async {
    if (selectedClass.isEmpty || selectedSubject.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Select class & subject first")));
      return;
    }
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        capturedImage = File(picked.path);
      });

      try {
        final bytes = await capturedImage!.readAsBytes();
        String base64Image = base64Encode(bytes);

        var res = await ApiService.faceAttendance(
          selectedClassId,
          selectedSubjectId,
          base64Image,
        );

        print(res);

        if (res["success"] == true) {
          setState(() {
            detectedName = res["student_name"];

            bool alreadyExists = presentStudents.any(
              (student) => student["name"] == res["student_name"],
            );

            if (!alreadyExists) {
              presentStudents.add({
                "name": res["student_name"],

                "roll_no": "Present",
              });
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res["message"]),

              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res["message"]),

              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("FACE ERROR: $e");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),

      // 🔝 HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Attendance", style: TextStyle(color: Colors.black)),
        actions: [
          if (isScanning)
            Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text("Live", style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            // 🎯 SELECTORS
            if (!isScanning) ...[
              dropdownBox(
                "Select Class",
                classes
                    .map<String>((cls) => cls["class_name"].toString())
                    .toList(),
                selectedClass,
                (val) {
                  setState(() {
                    selectedClass = val;

                    selectedClassId = classes
                        .firstWhere((c) => c["class_name"] == val)["class_id"]
                        .toString();
                  });

                  loadSubjects(selectedClassId);
                },
              ),

              SizedBox(height: 10),

              dropdownBox(
                "Select Subject",
                subjects
                    .map<String>((sub) => sub["subject_name"].toString())
                    .toList(),
                selectedSubject,
                (val) {
                  setState(() {
                    selectedSubject = val;

                    selectedSubjectId = subjects
                        .firstWhere(
                          (s) => s["subject_name"] == val,
                        )["subject_id"]
                        .toString();
                  });
                },
              ),

              SizedBox(height: 15),
            ],

            // 🎥 CAMERA
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // camera bg
                  Center(
                    child: Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                  ),

                  // scanning box
                  if (isScanning)
                    Center(
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: detectedName == null
                                ? Colors.green
                                : isRecognized
                                ? Colors.green
                                : Colors.red,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                  // detected name
                  if (detectedName != null)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isRecognized ? Icons.check_circle : Icons.cancel,
                              color: isRecognized ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRecognized
                                      ? "Marked Present"
                                      : "Not Recognized",
                                  style: TextStyle(
                                    color: isRecognized
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  detectedName!,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ▶ BUTTON
            if (!isScanning)
              ElevatedButton(
                onPressed: selectedClass.isEmpty || selectedSubject.isEmpty
                    ? null
                    : () {
                        setState(() {
                          isScanning = true;
                        });
                      },
                child: Text("Start Attendance"),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    isScanning = false;
                    detectedName = null;
                  });
                },
                child: Text("Stop"),
              ),

            SizedBox(height: 20),
            if (isScanning)
              ElevatedButton.icon(
                onPressed: scanFaceAndMark,
                icon: Icon(Icons.camera),
                label: Text("Scan Face"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            // 📋 PRESENT LIST
            if (isScanning || presentStudents.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // header
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Present Students"),
                          Text("${presentStudents.length}"),
                        ],
                      ),
                    ),

                    Divider(),

                    if (presentStudents.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Waiting for detection..."),
                      ),

                    ...presentStudents.map((s) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,

                          child: Icon(Icons.check, color: Colors.white),
                        ),

                        title: Text(s["name"]!),

                        subtitle: Text(s["roll_no"]!),

                        trailing: Text(
                          "Present",

                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔽 DROPDOWN
  Widget dropdownBox(
    String hint,
    List<String> items,
    String value,
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
        onChanged: (val) => onChanged(val as String),
      ),
    );
  }
}
