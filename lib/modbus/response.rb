# encoding: ASCII-8BIT
# frozen_string_literal: true

class Modbus
    class ResponsePDU < BinData::Record
        endian :big

        # This field is used for intra-system routing purpose (default to 0xFF)
        uint8 :unit_identifier
        uint8 :function_code

        struct :get, onlyif: -> { READ_CODES.include? function_code } do
            uint8 :data_length, value: -> { get.data.bytesize }
            string :data, read_length: -> { get.data_length }
        end

        struct :put, onlyif: -> { WRITE_CODES.include?(function_code) || MULTIPLE_CODES.include?(function_code) } do
            uint16 :address
            uint16 :data
        end
    end
end
