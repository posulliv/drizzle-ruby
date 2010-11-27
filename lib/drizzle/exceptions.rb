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

end
