require 'rubygems'
require 'ffi'

module LibDrizzle
  extend FFI::Library
  ffi_lib 'drizzle'

  # constants
  MAX_ERROR_SIZE = 2048
  MAX_USER_SIZE = 64
  MAX_PASSWORD_SIZE = 32
  MAX_DB_SIZE = 64
  MAX_INFO_SIZE = 2048
  MAX_SQLSTATE_SIZE = 5
  MAX_CATALOG_SIZE = 128
  MAX_TABLE_SIZE = 128

  # return codes
  ReturnCode = enum( :DRIZZLE_RETURN_OK, 0,
                     :DRIZZLE_RETURN_IO_WAIT,
                     :DRIZZLE_RETURN_PAUSE,
                     :DRIZZLE_RETURN_ROW_BREAK,
                     :DRIZZLE_RETURN_MEMORY,
                     :DRIZZLE_RETURN_ERRNO,
                     :DRIZZLE_RETURN_INTERNAL_ERROR,
                     :DRIZZLE_RETURN_GETADDRINFO,
                     :DRIZZLE_RETURN_NOT_READY,
                     :DRIZZLE_RETURN_BAD_PACKET_NUMBER,
                     :DRIZZLE_RETURN_BAD_HANDSHAKE_PACKET,
                     :DRIZZLE_RETURN_BAD_PACKET,
                     :DRIZZLE_RETURN_PROTOCOL_NOT_SUPPORTED,
                     :DRIZZLE_RETURN_UNEXPECTED_DATA,
                     :DRIZZLE_RETURN_NO_SCRAMBLE,
                     :DRIZZLE_RETURN_AUTH_FAILED,
                     :DRIZZLE_RETURN_NULL_SIZE,
                     :DRIZZLE_RETURN_ERROR_CODE,
                     :DRIZZLE_RETURN_TOO_MANY_COLUMNS,
                     :DRIZZLE_RETURN_ROW_END,
                     :DRIZZLE_RETURN_LOST_CONNECTION,
                     :DRIZZLE_RETURN_COULD_NOT_CONNECT,
                     :DRIZZLE_RETURN_NO_ACTIVE_CONNECTIONS,
                     :DRIZZLE_RETURN_HANDSHAKE_FAILED,
                     :DRIZZLE_RETURN_TIMEOUT,
                     :DRIZZLE_RETURN_MAX )
  
  # verbosity levels
  VerbosityLevel = enum( :DRIZZLE_VERBOSE_NEVER, 0,
                         :DRIZZLE_VERBOSE_FATAL,
                         :DRIZZLE_VERBOSE_ERROR,
                         :DRIZZLE_VERBOSE_INFO,
                         :DRIZZLE_VERBOSE_DEBUG,
                         :DRIZZLE_VERBOSE_CRAZY,
                         :DRIZZLE_VERBOSE_MAX )

  # options for the Drizzle protocol functions.
  CommandTypes = enum( :DRIZZLE_COMMAND_DRIZZLE_SLEEP, 0,
                       :DRIZZLE_COMMAND_DRIZZLE_QUIT,
                       :DRIZZLE_COMMAND_DRIZZLE_INIT_DB,
                       :DRIZZLE_COMMAND_DRIZZLE_QUERY,
                       :DRIZZLE_COMMAND_DRIZZLE_SHUTDOWN,
                       :DRIZZLE_COMMAND_DRIZZLE_CONNECT,
                       :DRIZZLE_COMMAND_DRIZZLE_PING,
                       :DRIZZLE_COMMAND_DRIZZLE_END )

  # Status flags for a drizzle connection
  ConnectionStatus = enum( :DRIZZLE_CON_STATUS_NONE, 0,
                           :DRIZZLE_CON_STATUS_IN_TRANS, (1 << 0),
                           :DRIZZLE_CON_STATUS_AUTOCOMMIT, (1 << 1),
                           :DRIZZLE_CON_STATUS_MORE_RESULTS_EXIST, (1 << 3),
                           :DRIZZLE_CON_STATUS_QUERY_NO_GOOD_INDEX_USED, (1 << 4),
                           :DRIZZLE_CON_STATUS_QUERY_NO_INDEX_USED, (1 << 5),
                           :DRIZZLE_CON_STATUS_CURSOR_EXISTS, (1 << 6),
                           :DRIZZLE_CON_STATUS_LAST_ROW_SENT, (1 << 7),
                           :DRIZZLE_CON_STATUS_DB_DROPPED, (1 << 8),
                           :DRIZZLE_CON_STATUS_NO_BACKSLASH_ESCAPES, (1 << 9),
                           :DRIZZLE_CON_STATUS_QUERY_WAS_SLOW, (1 << 10) )

  # Options for connections
  ConnectionOptions = enum( :DRIZZLE_CON_NONE, 0,
                            :DRIZZLE_CON_ALLOCATED, (1 << 0),
                            :DRIZZLE_CON_MYSQL, (1 << 1),
                            :DRIZZLE_CON_RAW_PACKET, (1 << 2),
                            :DRIZZLE_CON_RAW_SCRAMBLE, (1 << 3),
                            :DRIZZLE_CON_READY, (1 << 4),
                            :DRIZZLE_CON_NO_RESULT_READ, (1 << 5) )

  # query options
  QueryOptions = enum( :DRIZZLE_QUERY_ALLOCATED, (1 << 0) )

  # options for main drizzle structure
  Options = enum( :DRIZZLE_NONE, 0,
                  :DRIZZLE_ALLOCATED, (1 << 0),
                  :DRIZZLE_NON_BLOCKING, (1 << 1),
                  :DRIZZLE_FREE_OBJECTS, (1 << 2),
                  :DRIZZLE_ASSERT_DANGLING, (1 << 3) )

  attach_function :drizzle_create, [ :pointer ], :pointer
  attach_function :drizzle_free, [ :pointer ], :void
  attach_function :drizzle_set_verbose, [ :pointer, VerbosityLevel ], :void

  # connection related functions
  attach_function :drizzle_con_create, [ :pointer, :pointer ], :pointer
  attach_function :drizzle_con_free, [ :pointer ], :void
  attach_function :drizzle_con_set_tcp, [ :pointer, :string, :int ], :void
  attach_function :drizzle_con_set_db, [ :pointer, :string ], :void
  attach_function :drizzle_con_add_options, [ :pointer, ConnectionOptions ], :void
  attach_function :drizzle_con_fd, [ :pointer ], :int

  # query related functions
  attach_function :drizzle_query_str, [ :pointer, :pointer, :string, :pointer ], :pointer
  attach_function :drizzle_query_add, [ :pointer, :pointer, :pointer, :pointer, :string, :size_t, QueryOptions, :pointer ], :pointer
  attach_function :drizzle_result_read, [ :pointer, :pointer, :pointer ], :pointer
  attach_function :drizzle_row_buffer, [ :pointer, :pointer ], :pointer
  attach_function :drizzle_row_free, [ :pointer ], :void
  attach_function :drizzle_result_buffer, [ :pointer ], ReturnCode
  attach_function :drizzle_result_free, [ :pointer ], :void
  attach_function :drizzle_row_next, [ :pointer ], :pointer
  attach_function :drizzle_column_next, [ :pointer ], :pointer
  attach_function :drizzle_column_name, [ :pointer ], :string
  attach_function :drizzle_column_buffer, [ :pointer ], ReturnCode
  attach_function :drizzle_result_column_count, [ :pointer ], :uint16
  attach_function :drizzle_result_affected_rows, [ :pointer ], :uint64

  # miscellaneous functions
  attach_function :drizzle_version, [], :string
  attach_function :drizzle_bugreport, [], :string
  attach_function :drizzle_error, [ :pointer ], :string

end
