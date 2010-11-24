require File.dirname(__FILE__) + '/helper'

class TestBasic < Test::Unit::TestCase

  should "retrieve libdrizzle API version" do
    drizzle = Drizzle::Drizzle.new
    assert_equal "0.7", drizzle.version
  end

  should "retrieve libdrizzle bug report url" do
    drizzle = Drizzle::Drizzle.new
    drizzle.bug_report_url
  end

  should "perform a simple query and buffer all results" do
    conn = Drizzle::Connection.new("localhost", 9306, "data_dictionary")
    res = conn.query("SELECT module_name, module_author FROM MODULES")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    res.each do |row|
      puts "#{row[0]} : #{row[1]}"
    end
  end

  should "perform another simple query and buffer all results" do
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema", [:DRIZZLE_CON_NONE])
    res = conn.query("SELECT table_schema, table_name FROM TABLES")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    res.each do |row|
      puts "#{row[0]} : #{row[1]}"
    end
  end

  should "perform a simple query and buffer rows" do
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema")
    res = conn.query("SELECT table_name, column_name FROM COLUMNS")
    assert_equal res.class, Drizzle::Result
    until (row = res.buffer_row).nil?
      puts "#{row[0]} : #{row[1]}"
    end
  end

  should "create and drop a database" do
    conn = Drizzle::Connection.new("localhost", 9306)
    res = conn.query("CREATE DATABASE padraig")
    res = conn.query("show databases")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    res.each do |row|
      puts "#{row[0]}"
    end
    res = conn.query("DROP DATABASE padraig")
  end

  should "create and drop a table" do
    conn = Drizzle::Connection.new("localhost", 9306)
    res = conn.query("CREATE DATABASE padraig")
    res = conn.query("show databases")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    res.each do |row|
      puts "#{row[0]}"
    end
    res = conn.query("create table padraig.t1(a int, b varchar(255))")
    res = conn.query("select table_schema, table_name from information_schema.tables where table_schema = 'padraig'")
    res.buffer_result
    res.each do |row|
      puts "#{row[0]}: #{row[1]}"
      assert_equal "t1", row[1]
    end
    res = conn.query("DROP DATABASE padraig")
    res = conn.query("show databases")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    res.each do |row|
      puts "#{row[0]}"
    end
  end

end
