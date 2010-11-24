require File.dirname(__FILE__) + '/helper'

class TestBasic < Test::Unit::TestCase

  def setup
    conn = Drizzle::Connection.new("localhost", 9306)
    res = conn.query("CREATE DATABASE drizzleruby")
  end

  def teardown
    conn = Drizzle::Connection.new("localhost", 9306)
    res = conn.query("DROP DATABASE drizzleruby")
  end

  should "create and drop a table" do
    conn = Drizzle::Connection.new("localhost", 9306, "drizzleruby")
    res = conn.query("select table_schema from information_schema.tables where table_schema = 'drizzleruby'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 1, res.columns.size
    res.each do |row|
      assert_equal "drizzleruby", row[0]
    end
    res = conn.query("create table t1(a int, b varchar(255))")
    res = conn.query("select table_schema, table_name from information_schema.tables where table_schema = 'drizzleruby'")
    res.buffer_result
    assert_equal 2, res.columns.size
    res.each do |row|
      assert_equal "t1", row[1]
    end
    res = conn.query("DROP TABLE t1")
    res = conn.query("select table_name from information_schema.tables where table_schema = 'drizzleruby'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 1, res.columns.size
    assert_equal true, res.rows.empty?
  end

end
