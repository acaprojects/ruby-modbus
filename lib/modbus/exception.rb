# encoding: ASCII-8BIT
# frozen_string_literal: true

class Modbus
    EXCEPTIONS = {
        0x01 => :illegal_function,
        0x02 => :illegal_data_address,
        0x03 => :illegal_data_value,
        0x04 => :server_device_failure,
        0x05 => :acknowledge, # processing will take some time, no need to retry
        0x06 => :server_device_busy,
        0x08 => :memory_parity_error,
        0x0A => :gateway_path_unavailable,
        0x0B => :gateway_device_failed_to_respond
    }

    class ExceptionPDU < BinData::Record
        endian :big

        uint8 :unit_identifier
        uint8 :function_code
        uint8 :exception_code
    end
end
