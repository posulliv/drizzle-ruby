require 'drizzle/ffidrizzle'

module Drizzle

  class Result

    attr_reader :columns, :rows

    def initialize(res_ptr)
      @columns, @rows = [], []
      @res_ptr = res_ptr
    end

    def buffer_result()
      ret = LibDrizzle.drizzle_result_buffer(@res_ptr)
      if LibDrizzle::ReturnCode[ret] != LibDrizzle::ReturnCode[:DRIZZLE_RETURN_OK]
        LibDrizzle.drizzle_result_free(@res_ptr)
      end

      loop do
        col_ptr = LibDrizzle.drizzle_column_next(@res_ptr)
        break if col_ptr.null?
        @columns << LibDrizzle.drizzle_column_name(col_ptr).to_sym
      end

      loop do
        row_ptr = LibDrizzle.drizzle_row_next(@res_ptr)
        break if row_ptr.null?
        @rows << row_ptr.get_array_of_string(0, @columns.size)
      end

      LibDrizzle.drizzle_result_free(@res_ptr)
    end

    def buffer_row()
      # if the columns have not been read for this result
      # set yet, then we need to do that here. If this is not
      # performed here, we will receive a bad packet error
      read_columns if @columns.empty?
      ret_ptr = FFI::MemoryPointer.new(:int)
      row_ptr = LibDrizzle.drizzle_row_buffer(@res_ptr, ret_ptr)
      if LibDrizzle::ReturnCode[ret_ptr.get_int(0)] != :DRIZZLE_RETURN_OK
        LibDrizzle.drizzle_result_free(@res_ptr)
      end
      if row_ptr.null?
        LibDrizzle.drizzle_result_free(@res_ptr)
        return nil
      end
      num_of_cols = LibDrizzle.drizzle_result_column_count(@res_ptr)
      row = row_ptr.get_array_of_string(0, @columns.size)
    end

    def read_columns
      ret = LibDrizzle.drizzle_column_buffer(@res_ptr)
      loop do
        col_ptr = LibDrizzle.drizzle_column_next(@res_ptr)
        break if col_ptr.null?
        @columns << LibDrizzle.drizzle_column_name(col_ptr).to_sym
      end
    end

    def each
      @rows.each do |row|
        yield row if block_given?
      end
    end

  end

end
