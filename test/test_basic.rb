require File.dirname(__FILE__) + '/helper'

class TestBasic < Test::Unit::TestCase

  def setup
    @drizzle = Drizzle::Drizzle.new
  end

  should "retrieve libdrizzle API version" do
    assert_equal 0.7, @drizzle.version
  end

  should "retrieve libdrizzle bug report url" do
    @drizzle.bug_report_url
  end

end
