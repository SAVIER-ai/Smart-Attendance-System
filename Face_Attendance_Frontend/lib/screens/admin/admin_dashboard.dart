import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'student_registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String adminId;

  const AdminDashboard({super.key, required this.adminId});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedTab = 0; // 0 = overview
  int totalDepartments = 0;
  int totalClasses = 0;
  int totalSubjects = 0;
  int totalStudents = 0;

  List recentStudents = [];

  bool showAddDeptDialog = false;
  TextEditingController deptController = TextEditingController();
  List students = [];
  bool isLoading = true;
  List<Map<String, dynamic>> departments = [];

  @override
  void initState() {
    super.initState();
    print("ADMIN ID: ${widget.adminId}");
    loadDepartments();
    loadStudents();
    loadOverview();
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

  void loadOverview() async {
    var data = await ApiService.getOverview(widget.adminId);

    setState(() {
      totalDepartments = data["total_departments"];

      totalClasses = data["total_classes"];

      totalSubjects = data["total_subjects"];

      totalStudents = data["total_students"];

      recentStudents = data["recent_students"];
    });
  }

  void loadStudents() async {
    print("CALLING API...");

    try {
      var data = await ApiService.getAllStudents(widget.adminId);

      print("DATA RECEIVED: $data");

      setState(() {
        students = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");

      setState(() {
        isLoading = false; // 🔥 THIS FIXES INFINITE LOADING
      });
    }
  }

  Future<void> loadDepartments() async {
    try {
      var data = await ApiService.getDepartments(widget.adminId);
      print("DEPARTMENTS DATA: $data");
      setState(() {
        departments = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Department load error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),

      // 🔝 HEADER (same as React)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin Dashboard", style: TextStyle(color: Colors.black)),
            Text(
              "Welcome, Admin",
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

      body: Column(
        children: [
          // 🔹 TABS (Overview / Departments / Students)
          Container(
            color: Colors.white,
            child: Row(
              children: [
                tabItem("Overview", Icons.bar_chart, 0),
                tabItem("Departments", Icons.business, 1),
                tabItem("Students", Icons.people, 2),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  // =======================
                  // 🔥 OVERVIEW SECTION
                  // =======================
                  if (selectedTab == 0) ...[
                    // 📊 STATS (exact style)
                    Row(
                      children: [
                        statCard(
                          "Departments",
                          totalDepartments.toString(),
                          Colors.green,
                          Colors.green.shade50,
                        ),
                        SizedBox(width: 10),
                        statCard(
                          "Classes",
                          totalClasses.toString(),
                          Colors.blue,
                          Colors.blue.shade50,
                        ),
                        SizedBox(width: 10),
                        statCard(
                          "Subjects",
                          totalSubjects.toString(),
                          Colors.orange,
                          Colors.orange.shade50,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // ⚡ QUICK ACTIONS
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Quick Actions"),

                          SizedBox(height: 10),

                          actionTile(
                            "Add New Department",
                            Icons.business,
                            Colors.green,
                          ),

                          actionTile(
                            "Register New Student",
                            Icons.person_add,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // 👨‍🎓 RECENT STUDENTS
                    Container(
                      padding: EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                "Recent Students",

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Icon(Icons.people, color: Colors.blue),
                            ],
                          ),

                          SizedBox(height: 20),

                          if (recentStudents.isEmpty)
                            Center(child: Text("No students found"))
                          else
                            Column(
                              children: recentStudents.map((student) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),

                                  padding: EdgeInsets.all(12),

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,

                                    borderRadius: BorderRadius.circular(15),
                                  ),

                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue,

                                        child: Text(
                                          student["name"][0].toUpperCase(),

                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),

                                      SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              student["name"],

                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            SizedBox(height: 3),

                                            Text(
                                              "Roll No: ${student["roll_no"]}",
                                            ),

                                            Text(
                                              "Class: ${student["class_name"]}",

                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (selectedTab == 1) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Add Department"),

                                  content: TextField(
                                    controller: deptController,

                                    decoration: InputDecoration(
                                      hintText: "Department name",
                                    ),
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },

                                      child: Text("Cancel"),
                                    ),

                                    ElevatedButton(
                                      onPressed: () async {
                                        await ApiService.createDepartment(
                                          deptController.text,
                                          widget.adminId,
                                        );

                                        deptController.clear();

                                        Navigator.pop(context);

                                        loadDepartments();
                                      },

                                      child: Text("Add"),
                                    ),
                                  ],
                                ),
                              );
                            },

                            child: Text("Add Department"),
                          ),
                        ),

                        SizedBox(width: 10),

                        IconButton(
                          onPressed: () {
                            loadDepartments();
                          },

                          icon: Icon(Icons.refresh),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    ...departments.map((dept) {
                      TextEditingController classController =
                          TextEditingController();

                      return Container(
                        margin: EdgeInsets.only(bottom: 20),

                        padding: EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(15),

                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Text(
                                  dept["department_name"],

                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),

                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: Text(dept["department_code"]),
                                    ),

                                    SizedBox(width: 10),

                                    IconButton(
                                      onPressed: () async {
                                        await ApiService.deleteDepartment(
                                          dept["department_id"].toString(),
                                        );

                                        loadDepartments();
                                      },

                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 15),

                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,

                                  builder: (context) => AlertDialog(
                                    title: Text("Add Class"),

                                    content: TextField(
                                      controller: classController,

                                      decoration: InputDecoration(
                                        hintText: "Class name",
                                      ),
                                    ),

                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          await ApiService.createClass(
                                            classController.text,

                                            dept["department_id"].toString(),
                                          );

                                          Navigator.pop(context);

                                          setState(() {});
                                        },

                                        child: Text("Add"),
                                      ),
                                    ],
                                  ),
                                );
                              },

                              icon: Icon(Icons.add),

                              label: Text("Add Class"),
                            ),

                            SizedBox(height: 15),

                            FutureBuilder(
                              future: ApiService.getClasses(
                                dept["department_id"].toString(),
                              ),

                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox();
                                }

                                List classes = snapshot.data as List;

                                if (classes.isEmpty) {
                                  return Text("No Classes");
                                }

                                return Column(
                                  children: classes.map((cls) {
                                    TextEditingController subjectController =
                                        TextEditingController();

                                    return ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,

                                        children: [
                                          Text(cls["class_name"]),

                                          IconButton(
                                            onPressed: () async {
                                              await ApiService.deleteClass(
                                                cls["class_id"].toString(),
                                              );

                                              setState(() {});
                                            },

                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),

                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,

                                                builder: (context) => AlertDialog(
                                                  title: Text("Add Subject"),

                                                  content: TextField(
                                                    controller:
                                                        subjectController,

                                                    decoration: InputDecoration(
                                                      hintText: "Subject name",
                                                    ),
                                                  ),

                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await ApiService.createSubject(
                                                          subjectController
                                                              .text,

                                                          cls["class_id"]
                                                              .toString(),
                                                        );

                                                        Navigator.pop(context);

                                                        setState(() {});
                                                      },

                                                      child: Text("Add"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },

                                            icon: Icon(Icons.add),

                                            label: Text("Add Subject"),
                                          ),
                                        ),

                                        FutureBuilder(
                                          future: ApiService.getSubjects(
                                            cls["class_id"].toString(),
                                          ),

                                          builder: (context, subSnap) {
                                            if (!subSnap.hasData) {
                                              return SizedBox();
                                            }

                                            List subjects =
                                                subSnap.data as List;

                                            if (subjects.isEmpty) {
                                              return Padding(
                                                padding: EdgeInsets.all(10),

                                                child: Text("No Subjects"),
                                              );
                                            }

                                            return Column(
                                              children: subjects.map((sub) {
                                                return ListTile(
                                                  leading: Icon(Icons.book),

                                                  title: Text(
                                                    sub["subject_name"],
                                                  ),

                                                  trailing: IconButton(
                                                    onPressed: () async {
                                                      await ApiService.deleteSubject(
                                                        sub["subject_id"]
                                                            .toString(),
                                                      );

                                                      setState(() {});
                                                    },

                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  if (selectedTab == 2) ...[
                    // ➕ REGISTER BUTTON
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentRegistrationScreen(
                                    adminId: widget.adminId,
                                  ),
                                ),
                              );
                              // 🔥 Refresh after coming back
                              loadStudents();
                            },
                            child: Text("Register Student"),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              loadStudents();
                            });
                          },
                          icon: Icon(Icons.refresh, color: Colors.red),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    // 📋 STUDENT LIST
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      ...students.map((s) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),

                          padding: EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // 👤 ICON
                              Container(
                                padding: EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,

                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Icon(Icons.person, color: Colors.blue),
                              ),

                              SizedBox(width: 10),

                              // 📄 DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    // NAME
                                    Text(
                                      s["name"] ?? "",

                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    SizedBox(height: 5),

                                    // ROLL NO
                                    Text(
                                      "Roll No: ${s["roll_no"]}",

                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                    SizedBox(height: 2),

                                    // CLASS
                                    Text(
                                      "Class: ${s["class_name"]}",

                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ❌ DELETE BUTTON
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),

                                onPressed: () async {
                                  await ApiService.deleteStudent(
                                    s["student_id"].toString(),
                                  );

                                  loadStudents();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Student deleted")),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 TAB ITEM
  Widget tabItem(String title, IconData icon, int index) {
    bool isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.green : Colors.grey,
              ),
              SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📊 STAT CARD
  Widget statCard(String title, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.circle, color: color, size: 18),
            ),
            SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 20)),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ⚡ ACTION TILE
  Widget actionTile(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // 🔥 HANDLE ACTIONS
        if (title == "Add New Department") {
          setState(() {
            selectedTab = 1; // go to department tab
          });
        }

        if (title == "Register New Student") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  StudentRegistrationScreen(adminId: widget.adminId),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 10),
            Expanded(child: Text(title)),
            Icon(Icons.add, color: color),
          ],
        ),
      ),
    );
  }

  // 📊 SUMMARY BOX
  Widget summaryBox(String value, String label) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: Colors.white, fontSize: 18)),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  // DEPARTMENT CARD
  Widget departmentCard(String name, List classes, int deptIndex) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(name)),

            IconButton(
              icon: Icon(Icons.visibility, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Department Code"),
                    content: Text(
                      departments[deptIndex]["department_code"]?.string() ??
                          "No Code",
                    ),
                  ),
                );
              },
            ),

            // ❌ DELETE BUTTON
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  departments.removeAt(deptIndex);
                });
              },
            ),
          ],
        ),

        children: [
          // ➕ ADD CLASS BUTTON
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController classController =
                      TextEditingController();

                  return AlertDialog(
                    title: Text("Add Class"),
                    content: TextField(
                      controller: classController,
                      decoration: InputDecoration(hintText: "Class name"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (classController.text.isEmpty) return;

                          try {
                            // 🔥 CALL BACKEND API
                            var res = await ApiService.createClass(
                              classController.text,
                              departments[deptIndex]["department_id"]
                                  .toString(),
                            );

                            setState(() {
                              departments[deptIndex]["classes"].add({
                                "id": res["class_id"], // 🔥 ADD THIS
                                "name": classController.text,
                                "subjects": [],
                              });
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Class created successfully"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error creating class")),
                            );
                          }
                        },
                        child: Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text("Add Class"),
          ),

          // 📂 CLASSES
          ...classes.asMap().entries.map((entry) {
            int classIndex = entry.key;
            var cls = entry.value;

            return classCard(cls, deptIndex, classIndex);
          }),
        ],
      ),
    );
  }

  // CLASS CARD
  Widget classCard(Map cls, int deptIndex, int classIndex) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(cls["name"])),

            // ❌ DELETE CLASS
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  departments[deptIndex]["classes"].removeAt(classIndex);
                });
              },
            ),
          ],
        ),

        children: [
          // ➕ ADD SUBJECT
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController subController = TextEditingController();

                  return AlertDialog(
                    title: Text("Add Subject"),
                    content: TextField(
                      controller: subController,
                      decoration: InputDecoration(hintText: "Subject name"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (subController.text.isEmpty) return;

                          try {
                            // 🔥 CALL BACKEND API
                            await ApiService.createSubject(
                              subController.text,
                              cls["id"], // ⚠️ TEMP class_id (fix later)
                            );

                            // 🔥 UPDATE UI
                            setState(() {
                              departments[deptIndex]["classes"][classIndex]["subjects"]
                                  .add(subController.text);
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Subject created successfully"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error creating subject")),
                            );
                          }
                        },
                        child: Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text("Add Subject"),
          ),

          // 📘 SUBJECTS
          ...cls["subjects"].map<Widget>((sub) {
            return ListTile(
              title: Text(sub),
              leading: Icon(Icons.book, color: Colors.orange),
            );
          }).toList(),
        ],
      ),
    );
  }
}
