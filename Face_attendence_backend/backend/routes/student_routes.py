from flask import Blueprint, request
from controllers.student_controller import register_student
from controllers.student_controller import get_all_students
from controllers.student_controller import (
    get_students_by_class as get_students_by_class_controller
)
from controllers.student_controller import delete_student_controller

student_bp = Blueprint("student", __name__)

@student_bp.route("/register", methods=["POST"])
def register():
    data = request.json
    return register_student(data)

@student_bp.route("/all/<int:admin_id>", methods=["GET"])
def get_students(admin_id):
    return get_all_students(admin_id)

@student_bp.route("/class/<int:class_id>", methods=["GET"])
def get_students_by_class_route(class_id):
    return get_students_by_class_controller(class_id)

@student_bp.route(
    "/delete/<int:student_id>",
    methods=["DELETE"]
)
def delete_student(student_id):


    return delete_student_controller(student_id)