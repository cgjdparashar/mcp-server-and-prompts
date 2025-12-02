"""
Main Flask application entry point.
Initializes Flask app, registers blueprints, and starts the server.
"""
from flask import Flask
from config import Config
from database import Database
from routes import orders_bp


def create_app():
    """
    Application factory pattern.
    Creates and configures the Flask application.
    
    Returns:
        Flask: Configured Flask application instance
    """
    app = Flask(__name__)
    
    # Configure Flask app
    app.config['SECRET_KEY'] = Config.SECRET_KEY
    app.config['DEBUG'] = Config.DEBUG
    
    # Initialize database
    try:
        Database.test_connection()
        Database.init_database()
    except Exception as e:
        print(f"⚠️  Warning: Database initialization failed: {e}")
        print("Application will start but database operations may fail.")
    
    # Register blueprints
    app.register_blueprint(orders_bp)
    
    return app


if __name__ == '__main__':
    app = create_app()
    print(f"🚀 Starting Order Dashboard on http://{Config.HOST}:{Config.PORT}")
    print(f"📊 Debug mode: {Config.DEBUG}")
    print(f"💾 Database: {Config.DB_NAME} @ {Config.DB_HOST}")
    app.run(host=Config.HOST, port=Config.PORT, debug=Config.DEBUG)
