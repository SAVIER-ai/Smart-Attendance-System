from flask import Blueprint, request
from controllers.auth_controller import admin_signup, admin_login,teacher_signup, teacher_login

auth_bp = Blueprint("auth", __name__)

# SIGNUP ADMIN API
@auth_bp.route("/admin/signup", methods=["POST"])
def signup():
    data = request.json
    return admin_signup(data)


# LOGIN ADMIN API
@auth_bp.route("/admin/login", methods=["POST"])
def login():
    data = request.json
    return admin_login(data)

# TEACHER LOGIN API
@auth_bp.route("/teacher/login", methods=["POST"])
def teacher_login_route():
    data = request.json
    return teacher_login(data)

# TEACHER SIGNUP API
@auth_bp.route("/teacher/signup", methods=["POST"])
def teacher_signup_route():
    data = request.json
    return teacher_signup(data)