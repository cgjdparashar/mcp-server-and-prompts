"""
Database connection manager and schema initialization.
Handles MySQL connection, table creation, and connection pooling.
"""
import mysql.connector
from mysql.connector import Error
from config import Config


class Database:
    """Database connection manager with context manager support."""
    
    @staticmethod
    def get_connection():
        """
        Create and return a database connection.
        
        Returns:
            mysql.connector.connection: Active database connection
            
        Raises:
            Error: If connection fails
        """
        try:
            connection = mysql.connector.connect(**Config.get_db_config())
            return connection
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            raise
    
    @staticmethod
    def init_database():
        """
        Initialize database schema.
        Creates orders table if it doesn't exist.
        """
        try:
            conn = Database.get_connection()
            cursor = conn.cursor()
            
            # Create orders table
            create_table_query = """
            CREATE TABLE IF NOT EXISTS orders (
                id INT AUTO_INCREMENT PRIMARY KEY,
                order_number VARCHAR(50) UNIQUE NOT NULL,
                customer_name VARCHAR(255) NOT NULL,
                product_name VARCHAR(255) NOT NULL,
                quantity INT NOT NULL DEFAULT 1,
                price DECIMAL(10, 2) NOT NULL,
                total DECIMAL(10, 2) NOT NULL,
                status ENUM('Pending', 'Processing', 'Completed', 'Cancelled') DEFAULT 'Pending',
                order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                notes TEXT,
                INDEX idx_order_number (order_number),
                INDEX idx_status (status),
                INDEX idx_order_date (order_date)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            """
            
            cursor.execute(create_table_query)
            conn.commit()
            
            cursor.close()
            conn.close()
            
            print("✅ Database schema initialized successfully")
            
        except Error as e:
            print(f"❌ Error initializing database: {e}")
            raise
    
    @staticmethod
    def test_connection():
        """
        Test database connection.
        
        Returns:
            bool: True if connection successful, False otherwise
        """
        try:
            conn = Database.get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            cursor.close()
            conn.close()
            print("✅ Database connection successful")
            return True
        except Error as e:
            print(f"❌ Database connection failed: {e}")
            return False


class DatabaseContext:
    """Context manager for database connections."""
    
    def __enter__(self):
        """Open database connection."""
        self.connection = Database.get_connection()
        self.cursor = self.connection.cursor(dictionary=True)
        return self.cursor
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Close database connection and handle exceptions."""
        if exc_type:
            self.connection.rollback()
        else:
            self.connection.commit()
        
        self.cursor.close()
        self.connection.close()
