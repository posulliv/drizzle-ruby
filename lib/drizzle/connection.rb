require 'drizzle/ffidrizzle'
require 'drizzle/exceptions'

module Drizzle

  class ConnectionPtr < FFI::AutoPointer
    def self.release(ptr)
      LibDrizzle.drizzle_con_free(ptr)
    end
  end

  # 
  # connection options
  #
  NONE = 0
  ALLOCATED = 1
  MYSQL = 2
  RAW_PACKET = 4
  RAW_SCRAMBLE = 8
  READY = 16
  NO_RESULT_READ = 32
  INJECTION_PREVENTION = 64

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
    #   c = Drizzle::Connection.new("my_host", 4427, "my_db", [Drizzle::NONE])
    #
    def initialize(host = "localhost", port = 4427, db = nil, opts = [], drizzle_ptr = nil)
      @host = host
      @port = port
      @db = db
      @drizzle_handle = drizzle_ptr || DrizzlePtr.new(LibDrizzle.drizzle_create(nil))
      @con_ptr = ConnectionPtr.new(LibDrizzle.drizzle_con_create(@drizzle_handle, nil))
      @rand_key = ""

      opts.each do |opt|
        if opt == INJECTION_PREVENTION
          @randomize_queries = true
          next
        end
        LibDrizzle.drizzle_con_add_options(@con_ptr, LibDrizzle::ConnectionOptions[opt])
      end
      LibDrizzle.drizzle_con_set_tcp(@con_ptr, @host, @port) 
      LibDrizzle.drizzle_con_set_db(@con_ptr, @db) if @db
      @ret_ptr = FFI::MemoryPointer.new(:int)

      # 
      # if SQL injection prevention is enabled, we need to retrieve
      # the key to use for randomization from the server
      #
      if @randomize_queries == true
        query = "show variables like '%stad_key%'"
        res = LibDrizzle.drizzle_query_str(@con_ptr, nil, query, @ret_ptr)
        check_return_code(@ret_ptr, @drizzle_handle)
        Result.new(res)
        res.buffer_result
        res.each do |row|
          @rand_key = row[1]
        end
      end
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
      if @randomize_queries == false or @rand_key.empty?
        res = LibDrizzle.drizzle_query_str(@con_ptr, nil, query, @ret_ptr)
        check_return_code(@ret_ptr, @drizzle_handle)
      else
        rand_query = randomize_query(query)
        res = LibDrizzle.drizzle_query_str(@con_ptr, nil, rand_query, @ret_ptr)
        check_return_code(@ret_ptr, @drizzle_handle)
      end

      Result.new(res)
    end

    # 
    # tokenize the input query and append the randomization key to
    # keywords
    #
    def randomize_query(query)
      toks = query.split(" ")
      new_query = ""
      toks.each do |token|
        if Drizzle::keywords[token] == true
          token << @rand_key
        end
        new_query << token << " "
      end
    end

  end

end
