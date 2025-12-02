"""
Order model with full CRUD operations.
Handles all database operations for orders.
"""
from mysql.connector import Error
from database import DatabaseContext


class Order:
    """Order model for managing order data."""
    
    @staticmethod
    def get_all():
        """
        Retrieve all orders from database.
        
        Returns:
            list: List of order dictionaries
        """
        try:
            with DatabaseContext() as cursor:
                query = """
                SELECT id, order_number, customer_name, product_name, 
                       quantity, price, total, status, order_date, 
                       updated_at, notes
                FROM orders
                ORDER BY order_date DESC
                """
                cursor.execute(query)
                return cursor.fetchall()
        except Error as e:
            print(f"Error fetching orders: {e}")
            return []
    
    @staticmethod
    def get_by_id(order_id):
        """
        Retrieve a single order by ID.
        
        Args:
            order_id (int): Order ID
            
        Returns:
            dict: Order data or None if not found
        """
        try:
            with DatabaseContext() as cursor:
                query = """
                SELECT id, order_number, customer_name, product_name, 
                       quantity, price, total, status, order_date, 
                       updated_at, notes
                FROM orders
                WHERE id = %s
                """
                cursor.execute(query, (order_id,))
                return cursor.fetchone()
        except Error as e:
            print(f"Error fetching order {order_id}: {e}")
            return None
    
    @staticmethod
    def create(order_data):
        """
        Create a new order.
        
        Args:
            order_data (dict): Order data including order_number, customer_name, 
                              product_name, quantity, price, total, status, notes
            
        Returns:
            int: Inserted order ID or None if failed
        """
        try:
            with DatabaseContext() as cursor:
                query = """
                INSERT INTO orders (order_number, customer_name, product_name, 
                                  quantity, price, total, status, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """
                values = (
                    order_data['order_number'],
                    order_data['customer_name'],
                    order_data['product_name'],
                    order_data['quantity'],
                    order_data['price'],
                    order_data['total'],
                    order_data.get('status', 'Pending'),
                    order_data.get('notes', '')
                )
                cursor.execute(query, values)
                return cursor.lastrowid
        except Error as e:
            print(f"Error creating order: {e}")
            return None
    
    @staticmethod
    def update(order_id, order_data):
        """
        Update an existing order.
        
        Args:
            order_id (int): Order ID to update
            order_data (dict): Updated order data
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            with DatabaseContext() as cursor:
                query = """
                UPDATE orders
                SET customer_name = %s, product_name = %s, quantity = %s,
                    price = %s, total = %s, status = %s, notes = %s
                WHERE id = %s
                """
                values = (
                    order_data['customer_name'],
                    order_data['product_name'],
                    order_data['quantity'],
                    order_data['price'],
                    order_data['total'],
                    order_data['status'],
                    order_data.get('notes', ''),
                    order_id
                )
                cursor.execute(query, values)
                return cursor.rowcount > 0
        except Error as e:
            print(f"Error updating order {order_id}: {e}")
            return False
    
    @staticmethod
    def update_status(order_id, status):
        """
        Update order status only.
        
        Args:
            order_id (int): Order ID
            status (str): New status
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            with DatabaseContext() as cursor:
                query = "UPDATE orders SET status = %s WHERE id = %s"
                cursor.execute(query, (status, order_id))
                return cursor.rowcount > 0
        except Error as e:
            print(f"Error updating order status {order_id}: {e}")
            return False
    
    @staticmethod
    def delete(order_id):
        """
        Delete an order.
        
        Args:
            order_id (int): Order ID to delete
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            with DatabaseContext() as cursor:
                query = "DELETE FROM orders WHERE id = %s"
                cursor.execute(query, (order_id,))
                return cursor.rowcount > 0
        except Error as e:
            print(f"Error deleting order {order_id}: {e}")
            return False
    
    @staticmethod
    def order_number_exists(order_number, exclude_id=None):
        """
        Check if order number already exists.
        
        Args:
            order_number (str): Order number to check
            exclude_id (int, optional): Order ID to exclude from check (for updates)
            
        Returns:
            bool: True if exists, False otherwise
        """
        try:
            with DatabaseContext() as cursor:
                if exclude_id:
                    query = "SELECT COUNT(*) as count FROM orders WHERE order_number = %s AND id != %s"
                    cursor.execute(query, (order_number, exclude_id))
                else:
                    query = "SELECT COUNT(*) as count FROM orders WHERE order_number = %s"
                    cursor.execute(query, (order_number,))
                
                result = cursor.fetchone()
                return result['count'] > 0
        except Error as e:
            print(f"Error checking order number: {e}")
            return False
