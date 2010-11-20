require 'drizzle/ffidrizzle'

module Drizzle

  class Connection

    def initialize(raw_con_ptr)
      @con_ptr = raw_con_ptr
    end

    def set_tcp(host, port)
      LibDrizzle.drizzle_con_set_tcp(@con_ptr, host, port)
    end

    def set_db(db_name)
      LibDrizzle.drizzle_con_set_db(@con_ptr, db_name)
    end

  end

  class Drizzle

    def initialize()
      @handle = LibDrizzle.drizzle_create(nil)
    end

    def create_client_connection()
      con_ptr = LibDrizzle.drizzle_con_create(@handle, nil)
      Connection.new(con_ptr)
    end

    def version()
      LibDrizzle.drizzle_version
    end

    def bug_report_url()
      LibDrizzle.drizzle_bugreport
    end

  end

end
