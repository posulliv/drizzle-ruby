require 'drizzle/ffidrizzle'
require 'drizzle/exceptions'

module Drizzle

  class ConnectionPtr < FFI::AutoPointer
    def self.release(ptr)
      LibDrizzle.drizzle_con_free(ptr)
    end
  end

  # 
  # A drizzle connection
  #
  class Connection

    attr_accessor :host, :port, :db

    #
    # Creates a connection instance
    #
    #  == parameters
    #   
    #   * host        the hostname for the connection
    #   * port        the port number for the connection
    #   * db          the database name for the connection
    #   * opts        connection options
    #   * drizzle_ptr FFI pointer to a drizzle_st object
    #
    # Some examples :
    #
    #   c = Drizzle::Connection.new
    #   c = Drizzle::Connection.new("my_host", 4427)
    #   c = Drizzle::Connection.new("my_host", 4427, "my_db")
    #   c = Drizzle::Connection.new("my_host", 4427, "my_db", :DRIZZLE_CON_NONE)
    #
    def initialize(host = "localhost", port = 4427, db = nil, opts = [], drizzle_ptr = nil)
      @host = host
      @port = port
      @db = db
      @drizzle_handle = drizzle_ptr || DrizzlePtr.new(LibDrizzle.drizzle_create(nil))
      @con_ptr = ConnectionPtr.new(LibDrizzle.drizzle_con_create(@drizzle_handle, nil))
      opts.each do |opt|
        LibDrizzle.drizzle_con_add_options(@con_ptr, LibDrizzle::ConnectionOptions[opt])
      end
      LibDrizzle.drizzle_con_set_tcp(@con_ptr, @host, @port) 
      LibDrizzle.drizzle_con_set_db(@con_ptr, @db) if @db
      @ret_ptr = FFI::MemoryPointer.new(:int)
    end

    # 
    # set the host and port for the connection
    #
    def set_tcp(host, port)
      @host = host
      @port = port
      LibDrizzle.drizzle_con_set_tcp(@con_ptr, @host, @port)
    end

    # 
    # set the database name for the connection
    #
    def set_db(db_name)
      @db = db_name
      LibDrizzle.drizzle_con_set_db(@con_ptr, @db)
    end

    # 
    # execute a query and construct a result object
    #
    def query(query)
      res = LibDrizzle.drizzle_query_str(@con_ptr, nil, query, @ret_ptr)
      check_return_code(@ret_ptr, @drizzle_handle)
      Result.new(res)
    end

  end

end
