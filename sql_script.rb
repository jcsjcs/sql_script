# Produce a script of insert statements wrapped in a transaction.
#
# Example:
# 
#    script     = SqlScript.new(:postgresql)
#    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
#    row[:id]   = 12
#    row[:text] = 'A String'
#    row[:num]  = 12.123
#    row[:dt]   = Date.parse('2015-01-01')
#    row[:tm]   = Time.parse('2015-01-01 10:01:22')
#    script.rows << row
#    puts script.to_script #=>
#      BEGIN;
#      INSERT INTO lists (id, text, num, dt, tm)
#      VALUES (12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');
#      COMMIT;
#
class SqlScript
  attr_reader :db_type
  attr_accessor :rows

  TRANSACTION_START = {:sql_server => 'BEGIN TRANSACTION',      :postgresql => 'BEGIN;'}
  TRANSACTION_END   = {:sql_server => "COMMIT TRANSACTION\nGO", :postgresql => 'COMMIT;'}

  # Create an SqlScript. The db_type parameter must be :sql_server or :postgresql.
  def initialize(db_type)
    raise ArgumentError, "Unknown database type: #{db_type}" unless [:sql_server, :postgresql].include? db_type
    @db_type = db_type
    @rows    = []
  end

  # Get insert_sql from rows (SqlRow) and wrap in a transaction.
  # Returns String - SQL script.
  def to_script
    s = TRANSACTION_START[db_type].dup
    s << "\n"
    rows.each {|r| s << r.insert_sql(db_type) }
    s << "#{TRANSACTION_END[db_type]}\n"
    s
  end
end
