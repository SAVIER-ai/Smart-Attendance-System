from models.admin_model import create_admin, get_admin_by_email
from utils.hash_password import hash_password
from models.teacher_model import create_teacher, get_teacher_by_email
from models.department_model import get_department_by_code

# SIGNUP (Register Admin)
def admin_signup(data):
    try:
        name = data.get("name")
        email = data.get("email")
        password = data.get("password")
        
        
        # Validate required fields
        if not all([name, email, password]):
            return {"error": "Missing required fields"}

        password = hash_password(password)
        create_admin(name, email, password)

        return {"message": "Admin registered successfully"}
    except Exception as e:
        return {"error": f"Registration failed: {str(e)}"}


# ADMIN LOGIN
def admin_login(data):
    try:
        email = data.get("email")
        password = data.get("password")
        
        if not email or not password:
            return {"error": "Missing email or password"}

        password = hash_password(password)
        admin = get_admin_by_email(email)

        if admin and admin["password"] == password:
            return {
                "message": "Login successful",
                "admin_id": admin["admin_id"],
                "name": admin["name"],
                "email": admin["email"]
            }

        return {"error": "Invalid email or password"}
    except Exception as e:
        return {"error": f"Login failed: {str(e)}"}

# TEACHER LOGIN
def teacher_login(data):
    try:
        email = data.get("email")
        password = data.get("password")
        code = data.get("department_code")
        
        if not all([email, password, code]):
            return {"error": "Missing required fields"}

        password = hash_password(password)
        teacher = get_teacher_by_email(email)
        dept = get_department_by_code(code)

        if not teacher or not dept:
            return {"error": "Invalid credentials"}

        if teacher["password"] != password:
            return {"error": "Wrong password"}

        if teacher["department_id"] != dept["department_id"]:
            return {"error": "Invalid department code"}

        return {
            "message": "Teacher login successful",
            "department_id": dept["department_id"]
        }
    except Exception as e:
        return {"error": f"Login failed: {str(e)}"}

# TEACHER SIGNUP
def teacher_signup(data):
    try:
        name = data.get("name")
        email = data.get("email")
        password = data.get("password")
        code = data.get("department_code")
        
        # Validate required fields
        if not all([name, email, password, code]):
            return {"error": "Missing required fields"}
        
        password = hash_password(password)

        # Check if teacher already exists
        existing_teacher = get_teacher_by_email(email)
        if existing_teacher:
            return {"error": "Teacher already exists"}

        # Check department code
        dept = get_department_by_code(code)
        if not dept:
            return {"error": "Invalid department code"}

        # Create teacher
        create_teacher(name, email, password, dept["department_id"])

        return {"message": "Teacher registered successfully"}
    except Exception as e:
        return {"error": f"Registration failed: {str(e)}"}