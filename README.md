# SQL Script

Build up a script of insert statements wrapped in a transaction.

## Example


Also see `example.rb`.

```ruby
# Create a script instance
script = SqlScript.new(:postgresql)

# Define the table and row columns
row_type = SqlRowType.new('users', :id => :integer, :first_name => :string,
                                   :surname => :string, :date_added => :date)

# Create a row and populate it with values
row = SqlRow.new(row_type)
row[:first_name] = 'John'
row[:surname]    = 'Doe'
row[:date_added] = Date.today

# Add the first row to the script
script.rows << row

# Add another row to the script based on the 1st row.
nrow = SqlRow.new(row_type)
row.copy_values_to(nrow)
nrow[:first_name] = 'Jane'
script.rows << nrow

# Produce a script
puts script.to_script

puts "\n-- BULK e.g.\n"

# Produce a bulk insert script
puts script.to_bulk_insert_script
```
Output:
```sql
BEGIN;
INSERT INTO users (id, first_name, surname, date_added)
VALUES (NULL, 'John', 'Doe', '2015-04-29');
INSERT INTO users (id, first_name, surname, date_added)
VALUES (NULL, 'Jane', 'Doe', '2015-04-29');
COMMIT;

-- BULK

BEGIN;
INSERT INTO users (id, first_name, surname, date_added) VALUES
(NULL, 'John', 'Doe', '2015-04-29'),
(NULL, 'Jane', 'Doe', '2015-04-29');
COMMIT;
```
