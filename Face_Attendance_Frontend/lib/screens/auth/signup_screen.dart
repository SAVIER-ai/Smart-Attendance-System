import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final deptController = TextEditingController();

  String role = "Teacher";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ICON
                Center(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                ),

                SizedBox(height: 15),

                Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                Center(child: Text("Sign up to get started")),

                SizedBox(height: 25),

                Text("Select Role"),

                SizedBox(height: 10),

                // ROLE BUTTONS
                Row(
                  children: [
                    roleBox("Admin"),
                    SizedBox(width: 10),
                    roleBox("Teacher"),
                  ],
                ),

                SizedBox(height: 20),

                buildField(nameController, "Enter your name", Icons.person),
                SizedBox(height: 15),

                buildField(emailController, "Enter your email", Icons.email),
                SizedBox(height: 15),

                buildField(
                  passwordController,
                  "Enter your password",
                  Icons.lock,
                  isPassword: true,
                ),
                SizedBox(height: 15),

                if (role == "Teacher") ...[
                  SizedBox(height: 15),
                  buildField(
                    deptController,
                    "Enter department code",
                    Icons.apartment,
                  ),
                ],
                SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        Map<String, dynamic> res;

                        if (role == "Admin") {
                          res = await ApiService.adminSignup(
                            nameController.text,
                            emailController.text,
                            passwordController.text,
                          );
                        } else {
                          res = await ApiService.teacherSignup(
                            nameController.text,
                            emailController.text,
                            passwordController.text,
                            deptController.text,
                          );
                        }

                        if (res["error"] != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(res["error"])));
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Signup successful")),
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Signup failed")),
                        );
                      }
                    },
                    child: Text("Sign Up"),
                  ),
                ),

                SizedBox(height: 15),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ROLE BOX (IMPORTANT FIX)
  Widget roleBox(String value) {
    bool isSelected = role == value;

    Color activeColor = value == "Admin" ? Colors.blue : Colors.green;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            role = value;
            if (role == "Admin") deptController.clear();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                value == "Admin" ? Icons.admin_panel_settings : Icons.person,
                color: isSelected ? activeColor : Colors.grey,
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: isSelected ? activeColor : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // INPUT FIELD
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
}
