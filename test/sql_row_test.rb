require "test_helper"

class TestSqlRow < Minitest::Test

  def test_invalid_field
    row = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :string))
    assert_raises(ArgumentError) { row[:non_existent_field] = 12 }
  end

  def test_integer_value
    row      = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :string))
    row[:id] = 12
    assert_equal '12', row.sql_for(:id)
  end

  def test_numeric_value
    row       = SqlRow.new(SqlRowType.new('table', :id => :integer, :num => :numeric))
    row[:num] = 12.123
    assert_equal '12.123', row.sql_for(:num)
  end

  def test_numeric_value_alt
    row       = SqlRow.new(SqlRowType.new('table', :id => :integer, :num => :numeric))
    row[:num] = 12.123
    assert_equal '12.123', row.sql_for(:num)
  end

  def test_string_value
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :string))
    row[:text] = 12
    assert_equal "'12'", row.sql_for(:text)
  end
  # VALID_FIELD_TYPES = [:integer, :numeric, :string, :date, :time]

  def test_date_value
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :date))
    row[:text] = Date.parse('2015-01-01')
    assert_equal "'2015-01-01'", row.sql_for(:text)
  end

  def test_time_value
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :time))
    tm         = Time.now
    row[:text] = tm
    assert_equal "'#{tm.iso8601}'", row.sql_for(:text)
  end

  def test_insert_sql
    exp =  <<EOS
INSERT INTO lists (id, text, num, dt, tm)
VALUES (12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');
EOS
    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    assert_equal exp, row.insert_sql(:sql_server)
  end

  def test_insert_pg
    exp =  <<EOS
INSERT INTO lists (id, text, num, dt, tm)
VALUES (12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');
EOS
    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    assert_equal exp, row.insert_sql(:postgresql)
  end

  def test_copy_fields
    row_type   = SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time)
    row        = SqlRow.new(row_type)
    row[:id]   = 12
    row[:text] = 'A String'
    row[:dt]   = Date.parse('2015-01-01')

    new_row = SqlRow.new(row_type)
    row.copy_values_to(new_row)

    exp = {:id => '12', :text => "'A String'", :num => 'NULL', :dt => "'2015-01-01'", :tm => 'NULL'}
    exp.each do |field, value|
      assert_equal value, new_row.sql_for(field)
    end
  end
end

