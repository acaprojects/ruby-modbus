# encoding: ASCII-8BIT
# frozen_string_literal: true

class Modbus
    READ_CODES = [0x01, 0x02, 0x03, 0x04].freeze
    WRITE_CODES = [0x05, 0x06].freeze
    MULTIPLE_CODES = [0x0F, 0x10].freeze

    class RequestPDU < BinData::Record
        endian :big

        # This field is used for intra-system routing purpose (default to 0xFF)
        uint8 :unit_identifier
        uint8 :function_code

        struct :get, onlyif: -> { READ_CODES.include? function_code } do
            uint16 :address
            uint16 :quantity
        end

        struct :put, onlyif: -> { WRITE_CODES.include? function_code } do
            uint16 :address
            uint16 :data
        end

        struct :put_multiple, onlyif: -> { MULTIPLE_CODES.include? function_code } do
            uint16 :address
            uint16 :quantity

            uint8 :data_length, value: -> { put_multiple.data.bytesize }
            string :data, read_length: -> { put_multiple.data_length }
        end
    end
end
