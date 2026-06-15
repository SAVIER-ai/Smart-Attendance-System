import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class StudentRegistrationScreen extends StatefulWidget {
  final String adminId;

  const StudentRegistrationScreen({super.key, required this.adminId});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final phoneController = TextEditingController();
  List classes = [];
  String selectedClassId = "";
  bool isLoading = false;

  bool faceScanned = false;
  bool showSuccess = false;
  File? selectedImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void scanFace() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        faceScanned = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Face scanned successfully")));
    }
  }

  void loadClasses() async {
    var data = await ApiService.getDepartments(widget.adminId);

    List allClasses = [];

    for (var dept in data) {
      var cls = await ApiService.getClasses(dept["department_id"].toString());

      allClasses.addAll(cls);
    }

    setState(() {
      classes = allClasses;
    });
  }

  void pickFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        faceScanned = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image selected successfully")));
    }
  }

  void registerStudent() async {
    setState(() {
      isLoading = true;
    });
    if (nameController.text.isEmpty ||
        rollController.text.isEmpty ||
        selectedClassId.isEmpty ||
        phoneController.text.isEmpty) {
      showError("Fill all fields");
      return;
    }
    if (!faceScanned) {
      showError("Scan face first");
      return;
    }

    if (selectedImage == null) {
      showError("Please capture image");
      return;
    }
    try {
      final bytes = await selectedImage!.readAsBytes();
      String base64Image = base64Encode(bytes);

      await ApiService.registerStudentBase64(
        nameController.text,
        rollController.text,
        selectedClassId,
        phoneController.text,
        base64Image,
      );

      setState(() {
        showSuccess = true;
      });

      // 🔥 Wait → then go back AND reset
      Future.delayed(Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          showSuccess = false;
          faceScanned = false;

          nameController.clear();
          rollController.clear();
          selectedClassId = "";
          classes = [...classes];
          phoneController.clear();
        });

        Navigator.pop(context); // 👈 AFTER reset
      });
    } catch (e) {
      showError("Error saving student");
    }
    setState(() {
      isLoading = false;
    });
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text("Register Student", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                inputField("Student Name", Icons.person, nameController),
                inputField("Roll Number", Icons.tag, rollController),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),

                  child: DropdownButtonFormField<String>(
                    value: selectedClassId.isEmpty ? null : selectedClassId,

                    items: classes.map<DropdownMenuItem<String>>((cls) {
                      return DropdownMenuItem<String>(
                        value: cls["class_id"].toString(),

                        child: Text(cls["class_name"]),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedClassId = value!;
                      });
                    },

                    decoration: InputDecoration(
                      labelText: "Select Class",

                      prefixIcon: Icon(Icons.school),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                inputField("Phone Number", Icons.phone, phoneController),

                SizedBox(height: 20),

                // FACE SCAN
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      if (!faceScanned) ...[
                        Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Scan student face for recognition"),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: scanFace,
                                icon: Icon(Icons.camera),
                                label: Text("Scan Face"),
                              ),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: pickFromGallery,
                                icon: Icon(Icons.upload),
                                label: Text("Upload Image"),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Icon(Icons.check_circle, size: 60, color: Colors.green),
                        SizedBox(height: 10),
                        Text(
                          "Face scanned successfully!",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // REGISTER BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 50),
                  ),

                  onPressed: (faceScanned && !isLoading)
                      ? registerStudent
                      : null,

                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,

                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Register Student"),
                ),
              ],
            ),
          ),

          // SUCCESS POPUP
          if (showSuccess)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 60, color: Colors.green),
                      SizedBox(height: 10),
                      Text("Success!"),
                      Text("Student registered successfully"),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget inputField(String label, IconData icon, controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              hintText: "Enter $label",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
