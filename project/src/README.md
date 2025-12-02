# Order Dashboard - Technical Documentation

## Architecture Overview

This application follows a clean architecture pattern with separation of concerns:

- **`app.py`** - Application entry point and factory
- **`config.py`** - Configuration management
- **`database.py`** - Database abstraction layer
- **`models/`** - Data models and business logic
- **`routes/`** - HTTP request handlers (controllers)
- **`templates/`** - HTML views (Jinja2 templates)

## Code Organization

### Application Factory (`app.py`)

The application uses the factory pattern for better testability and configuration management:

```python
def create_app():
    # Creates and configures Flask app
    # Initializes database
    # Registers blueprints
    return app
```

**Key Features:**
- Automatic database initialization on startup
- Blueprint registration for modular routing
- Graceful error handling for database connection issues

### Configuration (`config.py`)

Centralized configuration using environment variables:

```python
class Config:
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_PORT = int(os.getenv('DB_PORT', '3306'))
    # ... more config
```

**Best Practices:**
- All secrets loaded from `.env` file
- Default values for development
- Type conversion (int, bool) for proper types
- Static method for database config dictionary

### Database Layer (`database.py`)

Two-class design for database operations:

1. **`Database`** - Static methods for connection and initialization
2. **`DatabaseContext`** - Context manager for safe connection handling

**Features:**
- Connection pooling via mysql.connector
- Auto-creation of database schema
- Context manager for automatic cleanup
- Transaction management (commit/rollback)
- Error handling with proper logging

**Usage Example:**
```python
with DatabaseContext() as cursor:
    cursor.execute(query, params)
    return cursor.fetchall()
```

### Models (`models/order.py`)

The `Order` model provides static methods for all CRUD operations:

**Methods:**
- `get_all()` - Fetch all orders
- `get_by_id(order_id)` - Fetch single order
- `create(order_data)` - Insert new order
- `update(order_id, order_data)` - Update existing order
- `update_status(order_id, status)` - Quick status update
- `delete(order_id)` - Remove order
- `order_number_exists(order_number, exclude_id)` - Uniqueness check

**Security:**
- Parameterized queries prevent SQL injection
- All user input sanitized via query parameters
- No raw SQL concatenation

**Error Handling:**
- Try-catch blocks for all database operations
- Graceful degradation on errors
- Logging for debugging

### Routes (`routes/orders.py`)

Flask Blueprint organizing all order-related endpoints:

| Route | Method | Purpose |
|-------|--------|---------|
| `/` | GET | Display all orders |
| `/create` | GET/POST | Create order form/submission |
| `/edit/<id>` | GET/POST | Edit order form/submission |
| `/delete/<id>` | POST | Delete order |
| `/update-status/<id>` | POST | AJAX status update |

**Request Handling Pattern:**
1. Extract and validate form data
2. Check business rules (uniqueness, constraints)
3. Perform database operation
4. Flash message for user feedback
5. Redirect or return JSON

**Validation:**
- Required field checks
- Type validation (int, float)
- Business rule validation (positive quantities, unique order numbers)
- Comprehensive error messages

### Templates

Jinja2 templates with template inheritance:

**Base Template (`base.html`):**
- Common HTML structure
- Embedded CSS for styling
- Flash message display
- Block definitions for extension

**Page Templates:**
- `index.html` - Order list with AJAX status updates
- `create_order.html` - Creation form with auto-calculation
- `edit_order.html` - Edit form with pre-populated data

**Features:**
- Responsive design
- Real-time total calculation (JavaScript)
- AJAX for status updates (no page reload)
- Confirmation dialogs for destructive actions
- Client-side form validation

## Database Schema

### Orders Table

```sql
CREATE TABLE orders (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Design Decisions:**
- `order_number` unique constraint prevents duplicates
- ENUM for status ensures valid values only
- Indexes on commonly filtered/sorted columns
- Timestamps auto-updated by MySQL
- InnoDB for transaction support
- utf8mb4 for full Unicode support

## API Endpoints

### GET /
Display all orders on dashboard

**Response:** HTML page with orders table

### GET /create
Display order creation form

**Response:** HTML form

### POST /create
Create new order

**Form Data:**
- order_number (required, unique)
- customer_name (required)
- product_name (required)
- quantity (required, > 0)
- price (required, > 0)
- status (optional, default: Pending)
- notes (optional)

**Response:** Redirect to dashboard with flash message

### GET /edit/<order_id>
Display order edit form

**Response:** HTML form with pre-populated data

### POST /edit/<order_id>
Update existing order

**Form Data:** Same as create (except order_number is immutable)

**Response:** Redirect to dashboard with flash message

### POST /delete/<order_id>
Delete order

**Response:** Redirect to dashboard with flash message

### POST /update-status/<order_id>
Update order status via AJAX

**Request Body (JSON):**
```json
{
  "status": "Processing"
}
```

**Response (JSON):**
```json
{
  "success": true,
  "message": "Status updated successfully"
}
```

## Security Considerations

### SQL Injection Prevention
- All queries use parameterized statements
- No string concatenation for SQL
- mysql.connector handles escaping

### XSS Prevention
- Jinja2 auto-escapes all template variables
- No `|safe` filter used on user input
- HTML entities properly encoded

### CSRF Protection
- Flask session-based CSRF protection
- POST requests for state-changing operations
- DELETE operations via POST with confirmation

### Input Validation
- Server-side validation for all inputs
- Type checking (int, float, string)
- Range validation (positive numbers)
- Length limits on strings
- Business rule enforcement

## Performance Optimization

### Database
- Indexes on frequently queried columns
- Connection pooling via mysql.connector
- Context managers for proper cleanup
- Efficient queries (no N+1 problems)

### Frontend
- CSS embedded to reduce HTTP requests
- Minimal JavaScript for better performance
- AJAX for status updates (no page reload)
- Client-side calculation reduces server load

### Caching
- No caching implemented (current requirement)
- Can add Redis for session/query caching if needed

## Error Handling

### Database Errors
- Try-catch blocks around all database operations
- Graceful degradation with user-friendly messages
- Logging for debugging
- Transaction rollback on errors

### Application Errors
- Flask error handlers for 404, 500
- Flash messages for user feedback
- Validation errors displayed on forms
- Detailed error messages in debug mode

### User Feedback
- Success messages (green alerts)
- Error messages (red alerts)
- Confirmation dialogs for destructive actions
- Form validation feedback

## Testing Strategy

### Manual Testing
- Create orders with various inputs
- Test validation (empty fields, invalid data)
- Test uniqueness constraints
- Test CRUD operations
- Test status updates via AJAX
- Test total calculation

### Automated Testing (Future)
- Unit tests for models
- Integration tests for routes
- Database transaction tests
- Form validation tests
- AJAX endpoint tests

### Test Data
No mock data used - all testing against real database

## Development Workflow

### Local Development
1. Activate virtual environment
2. Install dependencies
3. Configure `.env` file
4. Run Flask development server
5. Access at http://localhost:5000

### Debugging
- Flask debug mode enabled by default
- Error messages displayed in browser
- Terminal logs for database operations
- Browser DevTools for frontend debugging

### Code Style
- PEP 8 compliance
- Comprehensive docstrings
- Type hints where beneficial
- Inline comments for complex logic

## Deployment Considerations

### Production Checklist
- [ ] Change `SECRET_KEY` to secure random value
- [ ] Set `DEBUG=False`
- [ ] Use production WSGI server (Gunicorn)
- [ ] Set up reverse proxy (nginx)
- [ ] Configure HTTPS/SSL
- [ ] Set up database backups
- [ ] Enable application logging
- [ ] Monitor error rates
- [ ] Set up health checks

### Environment Variables
All sensitive data in `.env` file:
- Database credentials
- Flask secret key
- Debug mode flag

**Never commit `.env` to version control!**

## Extending the Application

### Adding New Features
1. Create model methods in `models/`
2. Add routes in `routes/`
3. Create/update templates in `templates/`
4. Update configuration if needed
5. Document changes in README

### Adding Authentication
1. Install Flask-Login
2. Create User model
3. Add login/logout routes
4. Protect routes with @login_required
5. Add user context to templates

### Adding API
1. Create new blueprint for API
2. Return JSON instead of HTML
3. Add authentication (JWT tokens)
4. Version API endpoints (/api/v1/)
5. Document with OpenAPI/Swagger

## Maintenance

### Database Migrations
- Currently using auto-creation on startup
- For production, use Alembic for schema migrations
- Version control all schema changes

### Dependency Updates
- Regular updates for security patches
- Test thoroughly after updates
- Pin versions in `pyproject.toml`

### Monitoring
- Log all database errors
- Track response times
- Monitor database connection pool
- Set up alerting for critical errors

## Contributors Guide

### Code Conventions
- Follow PEP 8
- Use meaningful variable names
- Add docstrings to all functions/classes
- Keep functions small and focused
- Write self-documenting code

### Git Workflow
1. Create feature branch
2. Make changes
3. Test thoroughly
4. Commit with descriptive messages
5. Create pull request
6. Code review
7. Merge to main

### Documentation
- Update README.md for user-facing changes
- Update this file for technical changes
- Comment complex logic
- Keep docstrings up to date

---

**For questions or clarifications, refer to the main README.md or contact the development team.**
