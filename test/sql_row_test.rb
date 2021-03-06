require "test_helper"
require 'bigdecimal'

class TestSqlRow < Minitest::Test

  def test_invalid_field
    row = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :string))
    assert_raises(ArgumentError) { row[:non_existent_field] = 12 }
  end

  def test_integer_value
    row      = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :string))
    row[:id] = 12
    assert_equal '12', row.sql_for(:id, :postgresql)
  end

  def test_numeric_value
    row       = SqlRow.new(SqlRowType.new('table', :id => :integer, :num => :numeric))
    row[:num] = 12.123
    assert_equal '12.123', row.sql_for(:num, :postgresql)
  end

  def test_numeric_string
    row       = SqlRow.new(SqlRowType.new('table', :id => :integer, :num => :numeric))
    row[:num] = '12.123'
    assert_equal '12.123', row.sql_for(:num, :postgresql)
  end

  def test_large_numeric
    row       = SqlRow.new(SqlRowType.new('table', :id => :integer, :num => :numeric))
    row[:num] = BigDecimal('288910.76024400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000289827')
    # assert_equal '288910.760244', row.sql_for(:num, :postgresql)
    assert_equal '0.288910760244E6', row.sql_for(:num, :postgresql)
  end

  def test_large_numeric_string
    row       = SqlRow.new(SqlRowType.new('table', :id => :integer, :num => :numeric))
    row[:num] = '288910.76024400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000289827'
    # assert_equal '288910.760244', row.sql_for(:num, :postgresql)
    assert_equal '0.288910760244E6', row.sql_for(:num, :postgresql)
  end

  def test_numeric_value_alt
    row       = SqlRow.new(SqlRowType.new('table', :id => :integer, :num => :numeric))
    row.set_value(:num, 12.123)
    assert_equal '12.123', row.sql_for(:num, :postgresql)
  end

  def test_string_value
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :string))
    row[:text] = 12
    assert_equal "'12'", row.sql_for(:text, :postgresql)
  end

  def test_quoted_string_value
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :string))
    row[:text] = "1 o'clock"
    assert_equal "'1 o''clock'", row.sql_for(:text, :postgresql)
  end
  # VALID_FIELD_TYPES = [:integer, :numeric, :string, :date, :time, :boolean]

  def test_date_value
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :date))
    row[:text] = Date.parse('2015-01-01')
    assert_equal "'2015-01-01'", row.sql_for(:text, :postgresql)
  end

  def test_time_value
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :text => :time))
    tm         = Time.now
    row[:text] = tm
    assert_equal "'#{tm.iso8601}'", row.sql_for(:text, :postgresql)
  end

  def test_postgres_boolean_values
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :bool => :boolean))
    bool_vals = {1 => true, 0 => false, true => true, false => false, 'true' => true, 'false' => false,
                 't' => true, 'f' => false, 'y' => true, 'n' => false, '0' => false, '1' => true}
    bool_vals.each do |val, res|
      row[:bool] = val
      expect = res ? "'t'" : "'f'"
      assert_equal expect, row.sql_for(:bool, :postgresql)
    end
  end

  def test_sql_server_boolean_values
    row        = SqlRow.new(SqlRowType.new('table', :id => :integer, :bool => :boolean))
    bool_vals = {1 => true, 0 => false, true => true, false => false, 'true' => true, 'false' => false,
                 't' => true, 'f' => false, 'y' => true, 'n' => false, '0' => false, '1' => true}
    bool_vals.each do |val, res|
      row[:bool] = val
      expect = res ? "1" : "0"
      assert_equal expect, row.sql_for(:bool, :sql_server)
    end
  end

  def test_insert_sql
    exp =  <<EOS
INSERT INTO lists (id, text, num, dt, tm, bool)
VALUES (12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00', 1);
EOS
    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time, :bool => :boolean))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    row[:bool] = true
    assert_equal exp, row.insert_sql(:sql_server)
  end

  def test_insert_pg
    exp =  <<EOS
INSERT INTO lists (id, text, num, dt, tm, bool)
VALUES (12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00', 't');
EOS
    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time, :bool => :boolean))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    row[:bool] = true
    assert_equal exp, row.insert_sql(:postgresql)
  end

  def test_copy_fields
    row_type   = SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time, :bool => :boolean)
    row        = SqlRow.new(row_type)
    row[:id]   = 12
    row[:text] = 'A String'
    row[:dt]   = Date.parse('2015-01-01')
    row[:bool] = true

    new_row = SqlRow.new(row_type)
    row.copy_values_to(new_row)

    exp = {:id => '12', :text => "'A String'", :num => 'NULL', :dt => "'2015-01-01'", :tm => 'NULL', :bool => "'t'"}
    exp.each do |field, value|
      assert_equal value, new_row.sql_for(field, :postgresql)
    end
  end
end

