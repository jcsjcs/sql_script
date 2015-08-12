# Represents a row of fields and values.
#
# Uses SqlRowType to build SQL statement for SqlScript to use.
class SqlRow
  require 'time'

  attr_reader :sql_row_type

  STATEMENT_TERMINATOR = {:sql_server => ";", :postgresql => ';' }

  # Create an SqlRow. Requires an SqlRowType parameter.
  def initialize(sql_row_type)
    @sql_row_type = sql_row_type
    @row_values   = {}
  end

  # Store the value for field.
  def set_value(field, value)
    raise ArgumentError, "Field \"#{field}\" is not a valid name according to the row type." unless sql_row_type.field_names.include?(field)
    @row_values[field] = value
  end

  # Alias for set_value.
  def []=(field,value)
    set_value(field,value)
  end

  # Return String - the value for field as required in SQL statement string.
  def sql_for(field, db_type)
    val = @row_values[field]
    return 'NULL' if val.nil?

    case sql_row_type.data_type_of(field)
    when :string
      "'#{val.to_s.gsub(/'/,"''")}'"
    when :date
      "'#{val.strftime('%Y-%m-%d')}'"
    when :time
      "'#{val.iso8601}'"
    when :boolean
      if :sql_server == db_type
        convert_to_boolean(val) ? '1' : '0'
      else
        convert_to_boolean(val) ? "'t'" : "'f'"
      end
    else
      val.to_s
    end
  end

  # Converts various boolean representations to true or false
  def convert_to_boolean(val)
    if val.is_a? String
      val =~ (/^(true|t|yes|y|1)$/i)
    elsif val.is_a? Fixnum
      !val.zero?
    else
      val
    end
  end

  # Copies all non-null values to the new row.
  def copy_values_to(new_row)
    sql_row_type.field_names.each do |field|
      new_row[field] = @row_values[field] unless @row_values[field].nil?
    end
  end

  # Returns String - an INSERT statement built up using all fields and their values.
  def insert_sql(db_type)
    s = "INSERT INTO #{sql_row_type.table_name} ("
    fields = sql_row_type.field_names
    s << fields.map {|f| f.to_s }.join(', ') << ")\n"
    s << "VALUES ("
    s << fields.map {|f| sql_for(f, db_type) }.join(', ')
    s << ")#{STATEMENT_TERMINATOR[db_type]}\n"
    s
  end
end
