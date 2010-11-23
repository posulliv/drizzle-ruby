require 'drizzle/ffidrizzle'

module Drizzle

  class IoWait < RuntimeError; end
  class Pause < RuntimeError; end
  class RowBreak < RuntimeError; end
  class Memory < RuntimeError; end
  class InternalError < RuntimeError; end
  class NotReady < RuntimeError; end
  class BadPacketNumber < RuntimeError; end
  class BadHandshake < RuntimeError; end
  class BadPacket < RuntimeError; end
  class ProtocolNotSupported < RuntimeError; end
  class UnexpectedData < RuntimeError; end
  class NoScramble < RuntimeError; end
  class AuthFailed < RuntimeError; end
  class NullSize < RuntimeError; end
  class TooManyColumns < RuntimeError; end
  class RowEnd < RuntimeError; end
  class LostConnection < RuntimeError; end
  class CouldNotConnect < RuntimeError; end
  class NoActiveConnections < RuntimeError; end
  class HandshakeFailed < RuntimeError; end
  class Timeout < RuntimeError; end
  class GeneralError < RuntimeError; end

  class DrizzlePtr < FFI::AutoPointer
    def self.release(ptr)
      LibDrizzle.drizzle_free(ptr)
    end
  end

  class ConnectionPtr < FFI::AutoPointer
    def self.release(ptr)
      LibDrizzle.drizzle_con_free(ptr)
    end
  end

  class Result

    attr_reader :columns, :rows

    def initialize(res_ptr)
      @columns, @rows = [], []

      loop do
        col_ptr = LibDrizzle.drizzle_column_next(res_ptr)
        break if col_ptr.null?
        @columns << LibDrizzle.drizzle_column_name(col_ptr).to_sym
      end

      loop do
        row_ptr = LibDrizzle.drizzle_row_next(res_ptr)
        break if row_ptr.null?
        @rows << row_ptr.get_array_of_string(0, @columns.size)
      end

      LibDrizzle.drizzle_result_free(res_ptr)
    end

  end

  class Connection

    attr_accessor :host, :port, :db

    def initialize(host = "localhost", port = 3306, db = nil, drizzle_ptr = nil)
      @host = host
      @port = port
      @db = db
      @drizzle_handle = drizzle_ptr || DrizzlePtr.new(LibDrizzle.drizzle_create(nil))
      @con_ptr = ConnectionPtr.new(LibDrizzle.drizzle_con_create(@drizzle_handle, nil))
      @ret_ptr = FFI::MemoryPointer.new(:int)
    end

    def set_tcp(host, port)
      @host = host
      @port = port
      LibDrizzle.drizzle_con_set_tcp(@con_ptr, @host, @port)
    end

    def set_db(db_name)
      @db = db_name
      LibDrizzle.drizzle_con_set_db(@con_ptr, @db)
    end

    def query(query)
      async_query(query)
      async_result
    end

    def async_query(query)
      LibDrizzle.drizzle_query_str(@con_ptr, nil, query, @ret_ptr)
      check_return_code
    end

    def async_result()
      res = LibDrizzle.drizzle_result_read(@con_ptr, nil, @retptr)
      check_return_code
      ret = LibDrizzle.drizzle_result_buffer(res)
      if LibDrizzle::ReturnCode[ret] != :DRIZZLE_RETURN_OK
        LibDrizzle.drizzle_result_free(res)
        raise GeneralError.new("Error: #{LibDrizzle.drizzle_error(@drizzle_handle)}")
      end
      Result.new(res)
    end

    def check_return_code
      case LibDrizzle.ReturnCode(@retptr.get_int(0))
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


  class Drizzle

    def initialize()
      @handle = DrizzlePtr.new(LibDrizzle.drizzle_create(nil))
    end

    def create_client_connection()
      Connection.new(@handle)
    end

    def version()
      LibDrizzle.drizzle_version
    end

    def bug_report_url()
      LibDrizzle.drizzle_bugreport
    end

  end

end
