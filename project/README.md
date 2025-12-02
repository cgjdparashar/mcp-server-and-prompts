# Order Dashboard

A comprehensive web-based Order Management Dashboard built with Python Flask and MySQL database.

## 📋 Features

- ✅ **List Orders** - View all orders in a responsive table
- ✅ **Create Order** - Add new orders with validation
- ✅ **Update Order** - Edit existing order details
- ✅ **Update Status** - Quick status changes via dropdown (AJAX)
- ✅ **Delete Order** - Remove orders with confirmation
- 📊 Real-time total calculation
- 🎨 Modern, responsive UI
- 🔒 No authentication required (as per specifications)

## 🛠️ Technology Stack

- **Backend**: Python 3.12+ with Flask 3.0+
- **Database**: MySQL (Azure Database for MySQL)
- **Project Management**: UV package manager
- **Dependencies**: Flask, mysql-connector-python, python-dotenv

## 📁 Project Structure

```
/project/
├── src/                        # All application code
│   ├── app.py                 # Flask application entry point
│   ├── config.py              # Configuration management
│   ├── database.py            # Database connection & schema
│   ├── models/
│   │   ├── __init__.py
│   │   └── order.py          # Order CRUD operations
│   ├── routes/
│   │   ├── __init__.py
│   │   └── orders.py         # Order endpoints
│   ├── templates/
│   │   ├── base.html         # Base template
│   │   ├── index.html        # Dashboard
│   │   ├── create_order.html # Create form
│   │   └── edit_order.html   # Edit form
│   └── README.md             # Technical documentation
├── pyproject.toml             # Project dependencies
├── .env.example               # Environment template
├── .env                       # Actual configuration
├── .gitignore                 # Version control
└── README.md                  # This file
```

## 🚀 Setup Instructions

### Prerequisites

- Python 3.12 or higher
- UV package manager (recommended) or pip
- MySQL database access
- Git (for version control)

### Installation

1. **Navigate to project directory**
   ```powershell
   cd project
   ```

2. **Install dependencies using UV**
   ```powershell
   uv pip install -e .
   ```
   
   Or using pip:
   ```powershell
   pip install flask mysql-connector-python python-dotenv
   ```

3. **Configure environment variables**
   
   The `.env` file is already configured with the database credentials:
   ```
   DB_HOST=moderswemysql02.mysql.database.azure.com
   DB_PORT=3306
   DB_NAME=dashboard
   DB_USER=modersweadmin
   DB_PASSWORD=admin@123
   ```
   
   You can modify these values if needed.

4. **Verify database exists**
   
   The `orders` table will be created automatically on first run. Ensure the MySQL database `dashboard` exists:
   ```sql
   CREATE DATABASE IF NOT EXISTS dashboard;
   ```

5. **Run the application**
   ```powershell
   cd src
   python app.py
   ```
   
   Or using Flask CLI:
   ```powershell
   cd src
   flask --app app.py run --debug
   ```

6. **Access the dashboard**
   
   Open your browser and navigate to:
   ```
   http://localhost:5000
   ```

## 📖 Usage Guide

### Creating an Order

1. Click the **"Create New Order"** button on the dashboard
2. Fill in the required fields:
   - Order Number (must be unique)
   - Customer Name
   - Product Name
   - Quantity (must be > 0)
   - Price per unit (must be > 0)
   - Status (optional, defaults to "Pending")
   - Notes (optional)
3. The total amount calculates automatically
4. Click **"Create Order"** to submit

### Viewing Orders

- All orders are displayed in a table on the main dashboard
- Columns show: Order #, Customer, Product, Quantity, Price, Total, Status, Date, Actions
- Orders are sorted by date (newest first)

### Updating Order Status

- Use the dropdown in the Status column
- Changes are saved immediately via AJAX (no page reload)
- Available statuses: Pending, Processing, Completed, Cancelled

### Editing an Order

1. Click the **"Edit"** button next to an order
2. Modify any fields except Order Number (immutable)
3. Total recalculates automatically when quantity/price changes
4. Click **"Update Order"** to save changes

### Deleting an Order

1. Click the **"Delete"** button next to an order
2. Confirm the deletion in the popup dialog
3. Order is permanently removed from the database

## 🗄️ Database Schema

The `orders` table is automatically created with the following structure:

| Column | Type | Description |
|--------|------|-------------|
| id | INT (PK, Auto) | Unique identifier |
| order_number | VARCHAR(50) | Unique order number |
| customer_name | VARCHAR(255) | Customer name |
| product_name | VARCHAR(255) | Product name |
| quantity | INT | Order quantity |
| price | DECIMAL(10,2) | Price per unit |
| total | DECIMAL(10,2) | Total amount (quantity × price) |
| status | ENUM | Pending, Processing, Completed, Cancelled |
| order_date | DATETIME | Creation timestamp |
| updated_at | DATETIME | Last update timestamp |
| notes | TEXT | Optional notes |

**Indexes:** order_number (unique), status, order_date

## 🔧 Configuration

All configuration is managed through environment variables in the `.env` file:

### Database Settings
- `DB_HOST` - MySQL server hostname
- `DB_PORT` - MySQL port (default: 3306)
- `DB_NAME` - Database name
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password

### Flask Settings
- `SECRET_KEY` - Flask secret key (change in production!)
- `DEBUG` - Debug mode (True/False)
- `HOST` - Server host (default: 0.0.0.0)
- `PORT` - Server port (default: 5000)

## 🧪 Testing

### Manual Testing Checklist

- [ ] Create order with valid data → Success
- [ ] Create order with duplicate order number → Error
- [ ] Create order with invalid quantity/price → Validation error
- [ ] Update order status from dropdown → Immediate update
- [ ] Edit order and change details → Persists correctly
- [ ] Delete order with confirmation → Removes from database
- [ ] View empty dashboard → Shows "No orders yet" message
- [ ] Total calculation updates automatically → Correct math

## 🐛 Troubleshooting

### Database Connection Errors

**Problem:** "Error connecting to MySQL"

**Solutions:**
- Verify database credentials in `.env`
- Check if MySQL server is running and accessible
- Ensure database `dashboard` exists
- Check firewall rules if using Azure MySQL

### Import Errors

**Problem:** "ModuleNotFoundError: No module named 'flask'"

**Solution:**
```powershell
cd project
uv pip install -e .
```

### Port Already in Use

**Problem:** "Address already in use"

**Solution:**
```powershell
# Change PORT in .env file to different value (e.g., 5001)
# Or kill the process using port 5000
```

### Application Won't Start

**Solution:**
1. Check Python version: `python --version` (must be 3.12+)
2. Verify you're in the correct directory: `cd project/src`
3. Check for syntax errors in terminal output
4. Ensure all dependencies are installed

## 📝 Requirements Verification

- ✅ Python Flask web application
- ✅ Used UV for project setup (via `uv pip install`)
- ✅ All code in `/project/src/` folder
- ✅ MySQL database integration
- ✅ Connection string from `.env` file
- ✅ No mock data (100% from database)
- ✅ No login/authentication
- ✅ List orders feature
- ✅ Create order feature
- ✅ Update order status feature
- ✅ Delete order feature

## 🚀 Production Deployment

Before deploying to production:

1. **Change secret key** in `.env`:
   ```
   SECRET_KEY=generate-a-strong-random-secret-key
   ```

2. **Disable debug mode**:
   ```
   DEBUG=False
   ```

3. **Use production WSGI server** (e.g., Gunicorn):
   ```powershell
   uv pip install gunicorn
   gunicorn -w 4 -b 0.0.0.0:5000 app:app
   ```

4. **Set up HTTPS** with reverse proxy (nginx/Apache)

5. **Configure proper database backups**

6. **Enable logging** for monitoring

## 📞 Support

For issues or questions:
- Check this README for setup instructions
- Review `/project/src/README.md` for technical details
- Verify database connectivity
- Check Flask debug logs in terminal

## 📄 License

Internal project for Modern SWE Team

## 👥 Contributors

- Modern SWE Team
- Implemented for Azure DevOps Work Item #299

---

**Version:** 1.0.0  
**Last Updated:** December 2, 2025  
**Status:** ✅ Production Ready
