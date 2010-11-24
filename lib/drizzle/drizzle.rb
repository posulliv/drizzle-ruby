require 'drizzle/ffidrizzle'

module Drizzle

  class DrizzlePtr < FFI::AutoPointer
    def self.release(ptr)
      LibDrizzle.drizzle_free(ptr)
    end
  end

  # 
  # map of keywords that will be used with the SQL injection
  # prevention plugin in drizzle
  #
  keywords =
  {
    "add" => true,
    "all" => true,
    "alter" => true,
    "analyze" => true,
    "and" => true,
    "any" => true,
    "as" => true,
    "asc" => true,
    "before" => true,
    "between" => true,
    "by" => true,
    "count" => true,
    "distinct" => true,
    "drop" => true,
    "from" => true,
    "having" => true,
    "or" => true,
    "select" => true,
    "union" => true,
    "where" => true
  }

  # 
  # A Drizzle instance
  #
  class Drizzle

    # 
    # creates a drizzle instance
    #
    def initialize()
      @handle = DrizzlePtr.new(LibDrizzle.drizzle_create(nil))
    end

    # 
    # create a client connection
    #
    def create_client_connection(host, port, db)
      Connection.new(host, port, db, @handle)
    end

    # 
    # return the libdrizzle API version
    #
    def version()
      LibDrizzle.drizzle_version
    end

    # 
    # return the bug report URL to file libdrizzle bugs at
    #
    def bug_report_url()
      LibDrizzle.drizzle_bugreport
    end

    #
    # add a query to be run concurrently
    #
    def add_query(conn, query, query_num, opts = [])
    end

    # 
    # execute all queries concurrently
    #
    def run_all()
    end

  end

end
