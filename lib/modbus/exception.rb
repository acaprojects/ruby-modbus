# encoding: ASCII-8BIT
# frozen_string_literal: true

class Modbus
    EXCEPTIONS = {
        0x01 => 'illegal function',
        0x02 => 'illegal data address',
        0x03 => 'illegal data value',
        0x04 => 'server device failure',
        0x05 => 'acknowledge', # processing will take some time, no need to retry
        0x06 => 'server device busy',
        0x08 => 'memory parity error',
        0x0A => 'gateway path unavailable',
        0x0B => 'gateway device failed to respond'
    }

    class ExceptionPDU < BinData::Record
        endian :big

        uint8 :unit_identifier
        uint8 :function_code
        uint8 :exception_code
    end
end
