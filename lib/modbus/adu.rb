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

        def function_name
            CODES[function_code]
        end

        def value
            return EXCEPTIONS[pdu.exception_code] || "unknown error 0x#{pdu.exception_code.to_s(16)}" if exception?
            return nil unless pdu.is_a?(ResponsePDU) && READ_CODES.include?(function_code)

            bytes = pdu.get.data_length
            bin_str = pdu.get.data

            case function_name
            when :read_coils, :read_inputs
                values = []

                # extract the bits and return an array of true / false values
                bin_str.each_byte do |byte|
                    bit = 0
                    loop do
                        values << ((byte & (1 << bit)) > 0)
                        bit += 1
                        break if bit >= 8
                    end
                end
                values
            when :read_holding_registers, :read_input_registers
                # these are all 16bit integers
                bin_str.unpack('n*')
            end
        end
    end
end
