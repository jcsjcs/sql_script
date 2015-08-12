# Represents a row of fields and their types.
#
# Used by SqlRow to build an SQL statement.
class SqlRowType
  attr_reader :table_name
  # May need to format numerics in some way....(numeric(10,2) vs numeric(10,5) and so on)

  VALID_FIELD_TYPES = [:integer, :numeric, :string, :date, :time, :boolean]

  # Create an SqlRowType.
  # Parameters are the table name and a Hash of :field_name => :data_type.
  def initialize(table_name, field_defs)
    @field_defs = field_defs
    raise ArgumentError, 'Invalid field type' if field_defs.values.any? {|v| !VALID_FIELD_TYPES.include?(v) }
    @table_name = table_name
  end

  # Returns Symbol - The data type of a given field.
  def data_type_of(field)
    @field_defs[field]
  end

  # Returns Array of Symbols - names of all fields in the row.
  def field_names
    @field_defs.keys
  end
end
