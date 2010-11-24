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

  def check_return_code(ret_ptr, drizzle_handle)
    case LibDrizzle::ReturnCode[ret_ptr.get_int(0)]
    when :DRIZZLE_RETURN_IO_WAIT
      raise IoWait.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_PAUSE
      raise Pause.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_ROW_BREAK
      raise RowBreak.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_MEMORY
      raise Memory.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_INTERNAL_ERROR
      raise InternalError.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_NOT_READY
      raise NotReady.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_BAD_PACKET_NUMBER
      raise BadPacketNumber.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_BAD_HANDSHAKE_PACKET
      raise BadHandshake.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_BAD_PACKET
      raise BadPacket.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_PROTOCOL_NOT_SUPPORTED
      raise ProtocolNotSupported.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_UNEXPECTED_DATA
      raise UnexpectedData.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_NO_SCRAMBLE
      raise NoScramble.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_AUTH_FAILED
      raise AuthFailed.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_NULL_SIZE
      raise NullSize.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_TOO_MANY_COLUMNS
      raise TooManyColumns.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_ROW_END
      raise RowEnd.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_LOST_CONNECTION
      raise LostConnection.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_COULD_NOT_CONNECT
      raise CouldNotConnect.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_NO_ACTIVE_CONNECTIONS
      raise NoActiveConnections.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_HANDSHAKE_FAILED
      raise HandshakeFailed.new(LibDrizzle.drizzle_error(drizzle_handle))
    when :DRIZZLE_RETURN_TIMEOUT
      raise ReturnTimeout.new(LibDrizzle.drizzle_error(drizzle_handle))
    end
  end
end
