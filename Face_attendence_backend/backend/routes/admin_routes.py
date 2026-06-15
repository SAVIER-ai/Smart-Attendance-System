from flask import Blueprint, request
from controllers.admin_controller import add_department
from controllers.admin_controller import fetch_classes_controller, get_subjects_by_class
from controllers.admin_controller import create_class_controller
from controllers.admin_controller import create_subject_controller
from controllers.admin_controller import get_dashboard_overview
from flask import jsonify
from controllers.admin_controller import fetch_departments
from controllers.admin_controller import delete_department_controller
from controllers.admin_controller import delete_class_controller
from controllers.admin_controller import delete_subject_controller

admin_bp = Blueprint("admin", __name__)
# Create Department
@admin_bp.route("/department/create", methods=["POST"])
def create_dept():
    data = request.json
    return add_department(data)

@admin_bp.route("/departments/<int:admin_id>", methods=["GET"])
def get_departments(admin_id):
    return fetch_departments(admin_id)

@admin_bp.route("/classes/<int:dept_id>", methods=["GET"])
def get_classes(dept_id):
    return fetch_classes_controller(dept_id)

@admin_bp.route("/class/create", methods=["POST"])
def create_class():
    data = request.json
    return create_class_controller(data)

@admin_bp.route("/subject/create", methods=["POST"])
def create_subject():
    data = request.json
    return create_subject_controller(data)

@admin_bp.route("/subjects/<int:class_id>", methods=["GET"])
def get_subjects(class_id):
    return jsonify({
    "data": get_subjects_by_class(class_id)
    })

@admin_bp.route("/department/delete/<int:dept_id>", methods=["DELETE"])
def delete_department(dept_id):
    return delete_department_controller(dept_id)

@admin_bp.route("/class/delete/<int:class_id>", methods=["DELETE"])
def delete_class(class_id):
    return delete_class_controller(class_id)

@admin_bp.route("/subject/delete/<int:subject_id>", methods=["DELETE"])
def delete_subject(subject_id):
    return delete_subject_controller(subject_id)

@admin_bp.route("/overview/<int:admin_id>", methods=["GET"])
def get_overview(admin_id):


    return get_dashboard_overview(admin_id)