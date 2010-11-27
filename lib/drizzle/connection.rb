require 'drizzle/ffidrizzle'
require 'drizzle/exceptions'

module Drizzle

  class ConnectionPtr < FFI::AutoPointer
    def self.release(ptr)
      LibDrizzle.drizzle_con_free(ptr)
    end
  end

  # 
  # map of keywords that will be used with the SQL injection
  # prevention plugin in drizzle
  #
  Keywords =
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
        check_return_code
        result = Result.new(res)
        result.buffer_result
        result.each do |row|
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
        check_return_code
      else
        rand_query = randomize_query(query)
        res = LibDrizzle.drizzle_query_str(@con_ptr, nil, rand_query, @ret_ptr)
        check_return_code
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
        if Keywords[token.downcase] == true
          token << @rand_key
        end
        new_query << token << " "
      end
      new_query
    end

    def check_return_code()
      case LibDrizzle::ReturnCode[@ret_ptr.get_int(0)]
      when :DRIZZLE_RETURN_IO_WAIT
        raise IoWait.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_PAUSE
        raise Pause.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_ROW_BREAK
        raise RowBreak.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_MEMORY
        raise Memory.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_INTERNAL_ERROR
        raise InternalError.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_NOT_READY
        raise NotReady.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_BAD_PACKET_NUMBER
        raise BadPacketNumber.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_BAD_HANDSHAKE_PACKET
        raise BadHandshake.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_BAD_PACKET
        raise BadPacket.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_PROTOCOL_NOT_SUPPORTED
        raise ProtocolNotSupported.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_UNEXPECTED_DATA
        raise UnexpectedData.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_NO_SCRAMBLE
        raise NoScramble.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_AUTH_FAILED
        raise AuthFailed.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_NULL_SIZE
        raise NullSize.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_TOO_MANY_COLUMNS
        raise TooManyColumns.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_ROW_END
        raise RowEnd.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_LOST_CONNECTION
        raise LostConnection.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_COULD_NOT_CONNECT
        raise CouldNotConnect.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_NO_ACTIVE_CONNECTIONS
        raise NoActiveConnections.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_HANDSHAKE_FAILED
        raise HandshakeFailed.new(LibDrizzle.drizzle_error(@drizzle_handle))
      when :DRIZZLE_RETURN_TIMEOUT
        raise ReturnTimeout.new(LibDrizzle.drizzle_error(@drizzle_handle))
      end
    end

  end

end
