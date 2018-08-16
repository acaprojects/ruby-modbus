# encoding: ASCII-8BIT
# frozen_string_literal: true

require 'bindata'

require 'modbus/tcp_header'
require 'modbus/request'
require 'modbus/response'
require 'modbus/exception'
require 'modbus/adu'

class Modbus
    CODES = {
        read_coils: 0x01,
        read_inputs: 0x02,
        read_holding_registers: 0x03,
        read_input_registers: 0x04,
        write_coil: 0x05,
        write_register: 0x06,
        write_multiple_coils: 0x0F,
        write_multiple_registers: 0x10,

        # Serial only
        read_exception_status: 0x07,
        diagnostics: 0x08,
        get_event_counter: 0x0B,
        get_event_log: 0x0C,
        get_server_id: 0x11,

        # unsupported
        read_file_record: 0x14,
        write_file_record: 0x15,
        mask_write_register: 0x16,
        read_write_registers: 0x17,
        read_fifo_queue: 0x17,
        encapsulated_interface_transport: 0x2B,
        canopen_general_request: 0x0D,
        read_device_identification: 0x0E
    }.freeze

    def initialize
        @transaction = 0
    end

    # Decodes an ADU from wire format and sets the attributes of this object.
    #
    # @param data [String] The bytes to decode.
    def read(data)
        @buffer ||= String.new
        @buffer << data

        error = nil

        loop do
            # not enough data in buffer to know the length
            break if @buffer.bytesize < 6

            header = TCPHeader.new
            header.read(@buffer[0..5])

            # the headers unit identifier is included in the length
            total_length = header.request_length + 6

            # Extract just the request from the buffer
            break if @buffer.bytesize < total_length
            request = @buffer.slice!(0...total_length)
            function_code = request.getbyte(7)

            # Yield the complete responses
            begin
                if function_code <= 0x80
                    response = ResponsePDU.new
                    response.read(request[6..-1])
                else # Error response
                    response = ExceptionPDU.new
                    response.read(request[6..-1])
                    function_code = function_code - 0x80
                end

                yield ADU.new header, function_code, response
            rescue => e
                error = e
            end
        end

        raise error if error
    end

    [:read_coils, :read_inputs, :read_holding_registers, :read_input_registers].each do |function|
        define_method function do |address, count = 1|
            adu = request_adu function
            request = adu.pdu
            request.get.address = address.to_i
            request.get.quantity = count.to_i
            adu
        end
    end

    def write_coils(address, *values)
        values = values.flatten

        if values.length > 1
            write_multiple_coils(address, *values)
        else
            adu = request_adu :write_coil
            request = adu.pdu
            request.put.address = address.to_i
            request.put.data = values.first ? 0xFF00 : 0x0
            adu
        end
    end

    def write_registers(address, *values)
        values = values.flatten.map! { |value| value.to_i }

        if values.length > 1
            adu = request_adu :write_multiple_registers
            request = adu.pdu
            request.put_multiple.address = address.to_i
            request.put_multiple.quantity = values.length
            request.put_multiple.data = values.pack('n*')
            adu
        else
            adu = request_adu :write_register
            request = adu.pdu
            request.put.address = address.to_i
            request.put.data = values.first
            adu
        end
    end

    protected

    def write_multiple_coils(address, *values)
        size = values.length

        bytes = []
        byte = 0
        bit = 0
        loop do
            value = values.shift
            if value
                byte = byte | (1 << bit)
            end
            break if values.empty?
            bit += 1
            if bit >= 8
                bytes << byte
                byte = 0
                bit = 0
            end
        end
        bytes << byte

        adu = request_adu :write_multiple_coils
        request = adu.pdu
        request.put_multiple.address = address.to_i
        request.put_multiple.quantity = size
        request.put_multiple.data = bytes.pack('C*')
        adu
    end

    def next_id
        id = @transaction
        @transaction += 1
        @transaction = 0 if @transaction > 0xFFFF
        id
    end

    def new_header
        header = TCPHeader.new
        header.transaction_identifier = next_id
        header.protocol_identifier = 0
        header
    end

    def request_pdu(code)
        request = RequestPDU.new
        # This seems to be the default
        request.unit_identifier = 0xFF
        request.function_code = code
        request
    end

    def request_adu(function)
        code = CODES[function]
        ADU.new(new_header, code, request_pdu(code))
    end
end
