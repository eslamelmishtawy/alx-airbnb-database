# AirBnB Database Sample Data (seed.sql)

## Overview

This directory contains the sample data script for the AirBnB-style application database. The `seed.sql` file populates the database with realistic test data that reflects real-world usage patterns and scenarios.

## Purpose

The seed script serves multiple purposes:

- **Development Testing**: Provides realistic data for application development and testing
- **Demo Data**: Offers comprehensive examples for demonstrations and presentations
- **Integration Testing**: Enables testing of complex business logic with varied data scenarios
- **Performance Testing**: Supplies sufficient data volume for performance analysis

## Prerequisites

Before running the seed script, ensure:

1. **Database Schema**: The database schema must be created first using `../database-script-0x01/schema.sql`
2. **Database Connection**: You have a working MySQL/MariaDB database connection
3. **Permissions**: Your database user has INSERT, UPDATE, and DELETE permissions
4. **Foreign Key Support**: The database supports foreign key constraints

## Data Overview

### Sample Data Volume

- **13 Users** (5 hosts, 7 guests, 1 admin)
- **10 Properties** across different locations and price ranges
- **12 Bookings** (8 confirmed, 2 pending, 2 canceled)
- **8 Payments** for confirmed bookings
- **10 Reviews** with varied ratings and detailed comments
- **16 Messages** showing realistic guest-host communication

### User Profiles

#### Hosts (5)

- **Alice Johnson** - NYC properties (downtown apartment, luxury penthouse)
- **Robert Smith** - Miami properties (beach house, studio loft)
- **Maria Garcia** - Denver & San Francisco (mountain cabin, Victorian home)
- **David Lee** - Chicago properties (industrial loft, lakefront cottage)
- **Sarah Wilson** - Wine country & Phoenix (villa, desert adobe)

#### Guests (7)

- Michael Brown, Emily Davis, James Miller, Jessica Anderson, Christopher Taylor, Amanda Thomas, Daniel Jackson

#### Admin (1)

- System administrator account

### Property Portfolio

| Location          | Property Type      | Price Range | Host   |
| ----------------- | ------------------ | ----------- | ------ |
| New York, NY      | Downtown Apartment | $150/night  | Alice  |
| New York, NY      | Luxury Penthouse   | $450/night  | Alice  |
| Miami, FL         | Beach House        | $300/night  | Robert |
| Miami, FL         | Studio Loft        | $120/night  | Robert |
| Denver, CO        | Mountain Cabin     | $180/night  | Maria  |
| San Francisco, CA | Victorian Home     | $250/night  | Maria  |
| Chicago, IL       | Industrial Loft    | $200/night  | David  |
| Chicago, IL       | Lakefront Cottage  | $175/night  | David  |
| Napa Valley, CA   | Wine Villa         | $400/night  | Sarah  |
| Phoenix, AZ       | Desert Adobe       | $220/night  | Sarah  |

### Booking Scenarios

The sample data includes various booking scenarios:

#### Confirmed Bookings (8)

- Completed stays with payments and reviews
- Different duration stays (3-7 days)
- Various properties and guests

#### Pending Bookings (2)

- Future bookings awaiting confirmation
- Demonstrates booking workflow states

#### Canceled Bookings (2)

- Examples of booking cancellations
- Shows different booking lifecycle states

### Payment Methods

- **Credit Card**: Traditional card payments
- **PayPal**: Digital wallet payments
- **Stripe**: Online payment processing

### Review System

- **Ratings**: 4-5 star ratings (realistic positive feedback)
- **Comments**: Detailed, authentic guest feedback
- **Multiple Reviews**: Some properties have multiple reviews from different guests

### Message System

Sample message threads include:

- Pre-booking inquiries
- Booking confirmations
- Arrival instructions
- Post-stay thank you messages
- Host recommendations and guest questions

## Usage Instructions

### Running the Seed Script

1. **Navigate to the directory**:

   ```bash
   cd database-script-0x02
   ```

2. **Execute with MySQL client**:

   ```bash
   mysql -u your_username -p your_database_name < seed.sql
   ```

3. **Or execute with specific connection**:
   ```bash
   mysql -h localhost -u your_username -p your_database_name < seed.sql
   ```

### Alternative Execution Methods

#### Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your database
3. Open the `seed.sql` file
4. Execute the script

#### Using phpMyAdmin

1. Access phpMyAdmin
2. Select your database
3. Go to "Import" tab
4. Choose the `seed.sql` file
5. Execute import

#### Using DBeaver or Similar Tools

1. Connect to your database
2. Open SQL editor
3. Load and execute the `seed.sql` file

### Verification

After running the script, verify the data was inserted correctly:

```sql
-- Check record counts
SELECT 'Users' as table_name, COUNT(*) as count FROM User
UNION ALL
SELECT 'Properties', COUNT(*) FROM Property
UNION ALL
SELECT 'Bookings', COUNT(*) FROM Booking
UNION ALL
SELECT 'Payments', COUNT(*) FROM Payment
UNION ALL
SELECT 'Reviews', COUNT(*) FROM Review
UNION ALL
SELECT 'Messages', COUNT(*) FROM Message;
```

Expected results:

- Users: 13
- Properties: 10
- Bookings: 12
- Payments: 8
- Reviews: 10
- Messages: 16

## Important Notes

### Foreign Key Handling

- The script temporarily disables foreign key checks for easier insertion
- Foreign keys are re-enabled at the end of the script
- Data is inserted in dependency order (Users → Properties → Bookings → Payments/Reviews/Messages)

### Data Consistency

- All foreign key relationships are properly maintained
- UUIDs are used for primary keys (formatted as 36-character strings)
- Timestamps follow realistic chronological order
- Business rules are respected (e.g., end dates after start dates)

### Password Security

- All user passwords are hashed using bcrypt
- Sample hash represents the password "password123"
- In production, use proper password hashing and validation

### Data Reset

To clear existing data before re-seeding (⚠️ **WARNING: This will delete all data**):

```sql
-- Uncomment these lines in the seed.sql file
DELETE FROM Message;
DELETE FROM Review;
DELETE FROM Payment;
DELETE FROM Booking;
DELETE FROM Property;
DELETE FROM User;
```

## Customization

### Adding More Data

To add additional sample data:

1. Follow the existing UUID pattern for IDs
2. Maintain foreign key relationships
3. Use realistic dates and values
4. Ensure data consistency across tables

### Modifying Existing Data

- Update the INSERT statements in `seed.sql`
- Maintain referential integrity
- Keep realistic data patterns

### Different Scenarios

The sample data can be modified to test:

- Different booking patterns
- Various payment scenarios
- Multiple review patterns
- Complex message threads
- Different user roles and permissions

## Troubleshooting

### Common Issues

1. **Foreign Key Constraint Errors**

   - Ensure schema is created first
   - Check if foreign key checks are disabled
   - Verify data insertion order

2. **Duplicate Key Errors**

   - Clear existing data before re-running
   - Check for unique constraint violations

3. **Date Format Issues**

   - Ensure MySQL date format is correct (YYYY-MM-DD)
   - Check timestamp format compliance

4. **Connection Issues**
   - Verify database credentials
   - Check database server status
   - Ensure proper permissions

### Getting Help

If you encounter issues:

1. Check the MySQL error log
2. Verify schema compatibility
3. Test with a smaller data subset
4. Review foreign key relationships

## File Information

- **Created**: August 30, 2025
- **Last Modified**: August 30, 2025
- **Version**: 1.0
- **Database Engine**: MySQL/MariaDB
- **Character Set**: UTF-8
- **Dependencies**: `../database-script-0x01/schema.sql`

## Related Files

- `../database-script-0x01/schema.sql` - Database schema definition
- `../ERD/requirements.md` - Entity Relationship Diagram requirements
- `../normalization.md` - Database normalization documentation
