from flask import Flask, jsonify
from config import *
from routes.auth_routes import auth_bp
from routes.admin_routes import admin_bp
from routes.student_routes import student_bp
from routes.attendance_routes import attendance
from flask_cors import CORS
app = Flask(__name__)
CORS(app, supports_credentials=True)
# Configuration
app.config['JSON_SORT_KEYS'] = False

# Register blueprints
app.register_blueprint(auth_bp, url_prefix="/api")
app.register_blueprint(admin_bp, url_prefix="/api/admin")    
app.register_blueprint(student_bp, url_prefix="/api/student")
app.register_blueprint(attendance, url_prefix="/api/attendance")

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', '*')
    response.headers.add('Access-Control-Allow-Methods', '*')
    return response
# Error handlers
@app.errorhandler(400)
def bad_request(error):
    return jsonify({"error": "Bad request"}), 400

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500

@app.route("/", methods=["GET"])
def health_check():
    return jsonify({"status": "API is running"}), 200

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)

