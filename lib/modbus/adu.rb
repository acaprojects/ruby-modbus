# encoding: ASCII-8BIT
# frozen_string_literal: true

class Modbus
    # TCP ADU are sent via TCP to registered port 502
    Modbus::ADU = Struct.new :header, :function_code, :pdu do
        def exception?
            pdu.is_a?(ExceptionPDU)
        end

        def to_binary_s
            data = pdu.to_binary_s
            header.request_length = data.bytesize
            "#{header.to_binary_s}#{data}"
        end
    end
end
