import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  final String departmentId;

  const ReportScreen({super.key, required this.departmentId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController rollController = TextEditingController();

  List reports = [];
  List classes = [];

  String selectedClassId = "";
  String selectedDate = "";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loadClasses();
  }

  // LOAD CLASSES
  void loadClasses() async {
    try {
      // Replace 15 with actual department id later
      var data = await ApiService.getClasses(widget.departmentId);

      setState(() {
        classes = data;
      });
    } catch (e) {
      print(e);
    }
  }

  // GENERATE REPORT
  void generateReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      var data = await ApiService.getReport(
        selectedClassId,
        rollController.text,
        selectedDate,
      );

      setState(() {
        reports = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }

  // SUMMARY
  int get presentCount {
    return reports.where((e) => e["status"] == "Present").length;
  }

  int get absentCount {
    return reports.where((e) => e["status"] == "Absent").length;
  }

  int get totalCount {
    return reports.length;
  }

  // DATE PICKER
  Future pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),

      firstDate: DateTime(2024),

      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Attendance Reports",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text("Track attendance records", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [
            // FILTER CARD
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),

              child: Column(
                children: [
                  // ROLL SEARCH
                  TextField(
                    controller: rollController,

                    decoration: InputDecoration(
                      hintText: "Search by Roll Number",

                      prefixIcon: Icon(Icons.search),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // CLASS DROPDOWN
                  DropdownButtonFormField(
                    value: selectedClassId.isEmpty ? null : selectedClassId,

                    decoration: InputDecoration(
                      labelText: "Select Class",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: classes.map((c) {
                      return DropdownMenuItem(
                        value: c["class_id"].toString(),

                        child: Text(c["class_name"]),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedClassId = value.toString();
                      });
                    },
                  ),

                  SizedBox(height: 15),

                  // DATE PICKER
                  GestureDetector(
                    onTap: pickDate,

                    child: Container(
                      width: double.infinity,

                      padding: EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Text(
                        selectedDate.isEmpty ? "Select Date" : selectedDate,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,

                    height: 50,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: generateReport,

                      child: Text(
                        "Generate Report",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // SUMMARY
            Row(
              children: [
                statBox(presentCount.toString(), "Present", Colors.green),

                SizedBox(width: 10),

                statBox(absentCount.toString(), "Absent", Colors.red),

                SizedBox(width: 10),

                statBox(totalCount.toString(), "Total", Colors.blue),
              ],
            ),

            SizedBox(height: 20),

            // REPORT LIST
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (reports.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 50),

                child: Text("No Reports Found"),
              )
            else
              ListView.builder(
                shrinkWrap: true,

                physics: NeverScrollableScrollPhysics(),

                itemCount: reports.length,

                itemBuilder: (context, index) {
                  var r = reports[index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 15),

                    padding: EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),

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
                              r["name"] ?? "",

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),

                              decoration: BoxDecoration(
                                color: r["status"] == "Present"
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,

                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Text(r["status"] ?? ""),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        Text("Roll No: ${r["roll_no"]}"),

                        Text("Class: ${r["class_name"]}"),

                        Text(
                          r["date"]?.toString() ?? "",

                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // SUMMARY CARD
  Widget statBox(String value, String title, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),

        child: Column(
          children: [
            Text(
              value,

              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            Text(title),
          ],
        ),
      ),
    );
  }
}
