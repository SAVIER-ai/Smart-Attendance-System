import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../services/api_service.dart';
import '../admin/admin_dashboard.dart';
import '../teacher/teacher_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final codeController = TextEditingController();

  String role = "Teacher"; // 🔥 default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // 🔝 ICON
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.login, color: Colors.white),
                ),

                SizedBox(height: 15),

                Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                Text("Login to continue"),

                SizedBox(height: 25),

                // 🔥 ROLE SELECT (same as signup)
                Row(
                  children: [
                    roleBox("Admin"),
                    SizedBox(width: 10),
                    roleBox("Teacher"),
                  ],
                ),

                SizedBox(height: 20),

                buildField(emailController, "Enter your email", Icons.email),
                SizedBox(height: 15),

                buildField(
                  passwordController,
                  "Enter your password",
                  Icons.lock,
                  isPassword: true,
                ),

                // 🔥 ONLY FOR TEACHER
                if (role == "Teacher") ...[
                  SizedBox(height: 15),
                  buildField(
                    codeController,
                    "Enter department code",
                    Icons.apartment,
                  ),
                ],

                SizedBox(height: 25),

                // 🔥 LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    child: Text("Login"),
                  ),
                ),

                SizedBox(height: 15),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignupScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔐 LOGIN FUNCTION
  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      Map<String, dynamic> response;

      if (role == "Admin") {
        response = await ApiService.adminLogin(email, password);
      } else {
        response = await ApiService.teacherLogin(
          email,
          password,
          codeController.text,
        );
      }

      if (response["error"] != null) {
        showError(response["error"]);
        return;
      }

      if (role == "Admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminDashboard(adminId: response["admin_id"].toString()),
          ),
        );
      } else {
        String deptId = response["department_id"].toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TeacherDashboard(deptId: deptId)),
        );
      }
    } catch (e) {
      showError("Login failed");
    }
  }

  // 🔘 ROLE BOX (same as signup)
  Widget roleBox(String value) {
    bool isSelected = role == value;
    Color color = value == "Admin" ? Colors.blue : Colors.green;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            role = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                value == "Admin" ? Icons.admin_panel_settings : Icons.person,
                color: isSelected ? color : Colors.grey,
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: isSelected ? color : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔤 INPUT FIELD
  Widget buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
