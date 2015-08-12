require "test_helper"

class TestSqlRowType < Minitest::Test

  def test_valid_type
    assert_raises(ArgumentError) { SqlRowType.new('table', :id => :integer, :dummy => :not_a_field_type) }
  end

  def test_data_types
    types        = {:id => :integer, :num => :numeric, :text => :string, :dt => :date, :tm => :time, :bool =>:boolean}
    sql_row_type = SqlRowType.new('table', types)

    types.each do |field, data_type|
      assert_equal data_type, sql_row_type.data_type_of(field)
    end
  end

  def test_lookup_field
    skip "May need the ability to define a field as a lookup (select id from table where :fld1 = :val1 AND :fld2 = :val2)..."
  end
end
