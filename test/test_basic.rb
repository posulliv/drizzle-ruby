require File.dirname(__FILE__) + '/helper'

class TestBasic < Test::Unit::TestCase

  should "retrieve libdrizzle API version" do
    drizzle = Drizzle::Drizzle.new
    assert_equal "0.7", drizzle.version
  end

  should "retrieve libdrizzle bug report url" do
    drizzle = Drizzle::Drizzle.new
    assert_equal "https://launchpad.net/libdrizzle", drizzle.bug_report_url
  end

  should "connect to drizzle successfully" do
    conn = Drizzle::Connection.new("localhost", 9306)
    assert_equal conn.class, Drizzle::Connection
  end

  should "perform a simple query and buffer all results" do
    conn = Drizzle::Connection.new("localhost", 9306, "data_dictionary")
    res = conn.query("SELECT module_name, module_author FROM MODULES where module_name = 'SchemaEngine'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 2, res.columns.size
    res.each do |row|
      assert_equal "Brian Aker", row[1]
    end
  end

  should "perform another simple query and buffer all results" do
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema", [Drizzle::NONE])
    res = conn.query("SELECT table_schema, table_name FROM TABLES WHERE table_schema = 'DATA_DICTIONARY' AND table_name = 'GLOBAL_STATUS'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 2, res.columns.size
    res.each do |row|
      assert_equal "DATA_DICTIONARY", row[0]
      assert_equal "GLOBAL_STATUS", row[1]
    end
  end

  should "perform a simple query and buffer rows" do
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema")
    res = conn.query("SELECT COUNT(*) FROM COLUMNS WHERE table_name = 'GLOBAL_STATUS'")
    assert_equal res.class, Drizzle::Result
    until (row = res.buffer_row).nil?
      assert_equal "2", row[0]
    end
  end

  should "create and drop a database" do
    conn = Drizzle::Connection.new("localhost", 9306)
    res = conn.query("CREATE DATABASE padraig")
    res = conn.query("select table_schema from information_schema.tables where table_schema = 'padraig'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 1, res.columns.size 
    res.each do |row|
      assert_equal "padraig", row[0]
    end
    res = conn.query("DROP DATABASE padraig")
    res = conn.query("select table_schema from information_schema.tables where table_schema = 'padraig'")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
    assert_equal 1, res.columns.size
    assert_equal true, res.rows.empty?
  end

  should "use different connection options" do
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema", [Drizzle::NONE])
    res = conn.query("SELECT COUNT(*) FROM COLUMNS WHERE table_name = 'GLOBAL_STATUS'")
    assert_equal res.class, Drizzle::Result
    until (row = res.buffer_row).nil?
      assert_equal "2", row[0]
    end
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema", [Drizzle::NONE, Drizzle::MYSQL])
    res = conn.query("SELECT COUNT(*) FROM COLUMNS WHERE table_name = 'GLOBAL_STATUS'")
    assert_equal res.class, Drizzle::Result
    until (row = res.buffer_row).nil?
      assert_equal "2", row[0]
    end
  end

  should "perform a query with a code block" do
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema", [Drizzle::NONE])
    conn.query("SELECT COUNT(*) FROM COLUMNS WHERE table_name = 'GLOBAL_STATUS'") do |res|
      assert_equal res.class, Drizzle::Result
      until (row = res.buffer_row).nil?
        assert_equal "2", row[0]
      end
    end
  end

  should "perform a simple show variables command" do
    conn = Drizzle::Connection.new("localhost", 9306, "information_schema", [Drizzle::NONE])
    assert_equal conn.class, Drizzle::Connection
    res = conn.query("show variables")
    assert_equal res.class, Drizzle::Result
    res.buffer_result
  end

end
