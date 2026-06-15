from flask import Blueprint, request
from controllers.attendance_controller import mark_attendance_controller
from controllers.attendance_controller import manual_attendance_controller
from controllers.attendance_controller import get_class_attendance
from controllers.attendance_controller import stop_attendance_controller

attendance = Blueprint("attendance", __name__)

@attendance.route("/mark", methods=["POST"])
def mark():
    data = request.json
    return mark_attendance_controller(data)

@attendance.route(
    "/stop",
    methods=["POST"]
)
def stop_attendance():

    data = request.json

    return stop_attendance_controller(data)

@attendance.route("/manual", methods=["POST"])
def manual_attendance():
    data = request.json
    return manual_attendance_controller(data)

@attendance.route("/report", methods=["POST"])
def get_report():

    data = request.json

    class_id = data.get("class_id")
    subject_id = data.get("subject_id")
    roll_no = data.get("roll_no")
    filter_type = data.get("filter_type")

    result = get_class_attendance(
        class_id,
        subject_id,
        roll_no,
        filter_type
    )

    return {
        "data": result
    }, 200