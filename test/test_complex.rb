require File.dirname(__FILE__) + '/helper'

class TestBasic < Test::Unit::TestCase

  def setup
    conn = Drizzle::Connection.new("localhost", PORT)
    res = conn.query("CREATE DATABASE drizzleruby")
  end

  def teardown
    conn = Drizzle::Connection.new("localhost", PORT)
    res = conn.query("DROP DATABASE drizzleruby")
  end

  should "create and drop a table" do
    conn = Drizzle::Connection.new("localhost", PORT, "drizzleruby")
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

  should "update affected rows appropriately" do
    conn = Drizzle::Connection.new("localhost", PORT, "drizzleruby")
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
    res = conn.query("insert into t1 values (1, 'padraig')")
    assert_equal 1, res.affected_rows
    assert_equal 0, res.insert_id
    res = conn.query("insert into t1 values (2, 'sarah')")
    assert_equal 1, res.affected_rows
    assert_equal 0, res.insert_id
    res = conn.query("select * from t1 where a = 2")
    res.buffer_result
    assert_equal 2, res.columns.size
    res.each do |row|
      assert_equal "2", row[0]
      assert_equal "sarah", row[1]
    end
    res = conn.query("DROP TABLE t1")
    res = conn.query("select table_name from information_schema.tables where table_schema = 'drizzleruby'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 1, res.columns.size
    assert_equal true, res.rows.empty?
  end

  should "perform a multi-insert statement correctly" do
    conn = Drizzle::Connection.new("localhost", PORT, "drizzleruby")
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
    res = conn.query("insert into t1 values (1, 'padraig'), (2, 'sarah'), (3, 'tomas')")
    assert_equal 3, res.affected_rows
    res = conn.query("select * from t1 where a = 2")
    res.buffer_result
    assert_equal 2, res.columns.size
    res.each do |row|
      assert_equal "2", row[0]
      assert_equal "sarah", row[1]
    end
    res = conn.query("DROP TABLE t1")
    res = conn.query("select table_name from information_schema.tables where table_schema = 'drizzleruby'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 1, res.columns.size
    assert_equal true, res.rows.empty?
  end

  should "insert and fetch a blob value correctly" do
    conn = Drizzle::Connection.new("localhost", PORT, "drizzleruby")
    res = conn.query("create table t1(a int, b blob)")
    res = conn.query("insert into t1 values (1, 'padraig'), (2, 'sarah'), (3, 'tomas')")
    assert_equal 3, res.affected_rows
    res = conn.query("insert into t1 values (4, null), (5, 'blahblahblah'), (6, 'southy')")
    assert_equal 3, res.affected_rows
    res = conn.query("select * from t1 where a = 2")
    res.buffer_result
    assert_equal 2, res.columns.size
    res.each do |row|
      assert_equal "2", row[0]
      assert_equal "sarah", row[1]
    end
    res = conn.query("select * from t1 where a = 4")
    res.buffer_result
    assert_equal 2, res.columns.size
    res.each do |row|
      assert_equal "4", row[0]
      assert_equal nil, row[1]
    end
    res = conn.query("DROP TABLE t1")
  end

end
