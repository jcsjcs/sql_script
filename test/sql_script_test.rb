require "test_helper"

class TestSqlScript < Minitest::Test

  def test_script_to_s
    sql_script = SqlScript.new(:sql_server)
    refute_empty sql_script.to_s
  end

  def test_initial_params
    assert_raises(ArgumentError) { SqlScript.new }
    assert SqlScript.new(:sql_server)
    assert SqlScript.new(:postgresql)
    assert_raises(ArgumentError) { SqlScript.new(:oracle) }
  end

  def test_transaction_syntax_sql
    s   = SqlScript.new(:sql_server)
    exp = "BEGIN TRANSACTION\nCOMMIT TRANSACTION\n"
    assert_equal exp, s.to_script
  end

  def test_transaction_syntax_pg
    s   = SqlScript.new(:postgresql)
    exp = "BEGIN;\nCOMMIT;\n"
    assert_equal exp, s.to_script
  end

  def test_insert_sql
    s   = SqlScript.new(:sql_server)
    exp = <<EOS
BEGIN TRANSACTION
INSERT INTO lists (id, text, num, dt, tm)
VALUES (12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');
COMMIT TRANSACTION
EOS
    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    s.rows << row
    assert_equal exp, s.to_script
  end

  def test_insert_pg
    s = SqlScript.new(:postgresql)
    exp =  <<EOS
BEGIN;
INSERT INTO lists (id, text, num, dt, tm)
VALUES (12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');
COMMIT;
EOS
    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    s.rows << row
    assert_equal exp, s.to_script
  end

  def test_insert_bulk_pg
    s = SqlScript.new(:postgresql)
    exp =  <<EOS
BEGIN;
INSERT INTO lists (id, text, num, dt, tm) VALUES
(12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00'),
(12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00'),
(12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');
COMMIT;
EOS
    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    s.rows << row
    s.rows << row
    s.rows << row
    assert_equal exp, s.to_bulk_insert_script
  end

  def test_insert_bulk_500_plus_pg
    s = SqlScript.new(:postgresql)
    ins_line = "INSERT INTO lists (id, text, num, dt, tm) VALUES"
    val_line = "(12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00'),"
    end_line = "(12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');"

    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    505.times { s.rows << row }
    lines = s.to_bulk_insert_script.lines
    assert_equal ins_line, lines[1].chomp
    assert_equal val_line, lines[2].chomp
    assert_equal end_line, lines[501].chomp
    assert_equal ins_line, lines[502].chomp
    assert_equal val_line, lines[503].chomp
    assert_equal end_line, lines[507].chomp
  end

  def test_insert_bulk_exactly_500_pg
    s = SqlScript.new(:postgresql)
    ins_line = "INSERT INTO lists (id, text, num, dt, tm) VALUES"
    val_line = "(12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00'),"
    end_line = "(12, 'A String', 12.123, '2015-01-01', '2015-01-01T10:01:22+02:00');"

    row        = SqlRow.new(SqlRowType.new('lists', :id => :integer, :text => :string, :num => :numeric, :dt => :date, :tm => :time))
    row[:id]   = 12
    row[:text] = 'A String'
    row[:num]  = 12.123
    row[:dt]   = Date.parse('2015-01-01')
    row[:tm]   = Time.parse('2015-01-01 10:01:22')
    500.times { s.rows << row }
    lines = s.to_bulk_insert_script.lines
    assert_equal ins_line, lines[1].chomp
    assert_equal val_line, lines[2].chomp
    assert_equal end_line, lines[501].chomp
    assert_equal 'COMMIT;', lines[502].chomp
  end

end
