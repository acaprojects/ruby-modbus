# encoding: ASCII-8BIT
# frozen_string_literal: true

class Modbus
    # TCP ADU are sent via TCP to registered port 502
    class TCPHeader < BinData::Record
        endian :big

        # used for transaction pairing
        uint16 :transaction_identifier

        # The MODBUS protocol is identified by the value 0.
        uint16 :protocol_identifier

        # byte count of the following fields, including the Unit Identifier and data fields.
        uint16 :request_length
    end
end
