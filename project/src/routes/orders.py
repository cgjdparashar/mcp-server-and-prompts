"""
Order routes - Flask blueprint with all order endpoints.
Handles all HTTP requests for order management.
"""
from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from models.order import Order

orders_bp = Blueprint('orders', __name__)


@orders_bp.route('/')
def index():
    """
    Display all orders on the dashboard.
    
    Returns:
        Rendered index template with orders list
    """
    orders = Order.get_all()
    return render_template('index.html', orders=orders)


@orders_bp.route('/create', methods=['GET', 'POST'])
def create():
    """
    Create a new order.
    
    GET: Display create order form
    POST: Process form submission and create order
    
    Returns:
        GET: Rendered create form template
        POST: Redirect to index or form with errors
    """
    if request.method == 'POST':
        # Get form data
        order_number = request.form.get('order_number', '').strip()
        customer_name = request.form.get('customer_name', '').strip()
        product_name = request.form.get('product_name', '').strip()
        quantity = request.form.get('quantity', type=int)
        price = request.form.get('price', type=float)
        status = request.form.get('status', 'Pending')
        notes = request.form.get('notes', '').strip()
        
        # Validation
        errors = []
        if not order_number:
            errors.append('Order number is required')
        elif Order.order_number_exists(order_number):
            errors.append('Order number already exists')
        
        if not customer_name:
            errors.append('Customer name is required')
        
        if not product_name:
            errors.append('Product name is required')
        
        if not quantity or quantity <= 0:
            errors.append('Quantity must be greater than 0')
        
        if not price or price <= 0:
            errors.append('Price must be greater than 0')
        
        if errors:
            for error in errors:
                flash(error, 'error')
            return render_template('create_order.html')
        
        # Calculate total
        total = quantity * price
        
        # Create order
        order_data = {
            'order_number': order_number,
            'customer_name': customer_name,
            'product_name': product_name,
            'quantity': quantity,
            'price': price,
            'total': total,
            'status': status,
            'notes': notes
        }
        
        order_id = Order.create(order_data)
        
        if order_id:
            flash(f'Order {order_number} created successfully!', 'success')
            return redirect(url_for('orders.index'))
        else:
            flash('Error creating order. Please try again.', 'error')
            return render_template('create_order.html')
    
    # GET request - show form
    return render_template('create_order.html')


@orders_bp.route('/edit/<int:order_id>', methods=['GET', 'POST'])
def edit(order_id):
    """
    Edit an existing order.
    
    Args:
        order_id (int): Order ID to edit
    
    GET: Display edit order form
    POST: Process form submission and update order
    
    Returns:
        GET: Rendered edit form template
        POST: Redirect to index or form with errors
    """
    order = Order.get_by_id(order_id)
    
    if not order:
        flash('Order not found', 'error')
        return redirect(url_for('orders.index'))
    
    if request.method == 'POST':
        # Get form data
        customer_name = request.form.get('customer_name', '').strip()
        product_name = request.form.get('product_name', '').strip()
        quantity = request.form.get('quantity', type=int)
        price = request.form.get('price', type=float)
        status = request.form.get('status', 'Pending')
        notes = request.form.get('notes', '').strip()
        
        # Validation
        errors = []
        if not customer_name:
            errors.append('Customer name is required')
        
        if not product_name:
            errors.append('Product name is required')
        
        if not quantity or quantity <= 0:
            errors.append('Quantity must be greater than 0')
        
        if not price or price <= 0:
            errors.append('Price must be greater than 0')
        
        if errors:
            for error in errors:
                flash(error, 'error')
            return render_template('edit_order.html', order=order)
        
        # Calculate total
        total = quantity * price
        
        # Update order
        order_data = {
            'customer_name': customer_name,
            'product_name': product_name,
            'quantity': quantity,
            'price': price,
            'total': total,
            'status': status,
            'notes': notes
        }
        
        success = Order.update(order_id, order_data)
        
        if success:
            flash(f'Order {order["order_number"]} updated successfully!', 'success')
            return redirect(url_for('orders.index'))
        else:
            flash('Error updating order. Please try again.', 'error')
            return render_template('edit_order.html', order=order)
    
    # GET request - show form
    return render_template('edit_order.html', order=order)


@orders_bp.route('/delete/<int:order_id>', methods=['POST'])
def delete(order_id):
    """
    Delete an order.
    
    Args:
        order_id (int): Order ID to delete
    
    Returns:
        Redirect to index with success/error message
    """
    order = Order.get_by_id(order_id)
    
    if not order:
        flash('Order not found', 'error')
        return redirect(url_for('orders.index'))
    
    success = Order.delete(order_id)
    
    if success:
        flash(f'Order {order["order_number"]} deleted successfully!', 'success')
    else:
        flash('Error deleting order. Please try again.', 'error')
    
    return redirect(url_for('orders.index'))


@orders_bp.route('/update-status/<int:order_id>', methods=['POST'])
def update_status(order_id):
    """
    Update order status via AJAX.
    
    Args:
        order_id (int): Order ID to update
    
    Returns:
        JSON response with success status
    """
    data = request.get_json()
    new_status = data.get('status')
    
    if not new_status:
        return jsonify({'success': False, 'message': 'Status is required'}), 400
    
    success = Order.update_status(order_id, new_status)
    
    if success:
        return jsonify({'success': True, 'message': 'Status updated successfully'})
    else:
        return jsonify({'success': False, 'message': 'Error updating status'}), 500
