# Ruby Modbus

Constructs [modbus standard](http://www.modbus.org/specs.php) datagrams that make it easy to communicate with devices on modbus networks.
It does not implement the transport layer so you can use it with native ruby, eventmachine, celluloid or the like.

[![Build Status](https://travis-ci.org/acaprojects/ruby-modbus.svg?branch=master)](https://travis-ci.org/acaprojects/ruby-modbus)

You'll need a gateway that supports TCP/IP.


## Install the gem

Install it with [RubyGems](https://rubygems.org/)

    gem install modbus

or add this to your Gemfile if you use [Bundler](http://gembundler.com/):

    gem 'modbus'



## Usage

```ruby
require 'modbus'

modbus = Modbus.new

# Reading input obtained from the network
# The class instance performs buffering and yields complete ADUs
modbus.read(byte_string) do |adu|
    adu.header.transaction_identifier # => 32

    # Response PDU returned
    if adu.exception?
        # Get error message
        puts adu.value
        # Error code
        puts adu.pdu.exception_code
    else
        case adu.function_name
        when :read_coils
            # raw response data
            puts adu.pdu.get.data.bytes
            # or values
            puts adu.value # => [true, false, true, false, false, false, false, false]
        when :read_input_registers
            # Grab the 16 bit values
            puts adu.value # => [1234, 8822]
        end
    end
end


# You can generate requests like so (writing multipe coils starting from 123)
request = modbus.write_coils(123, true, true, false)
byte_string = request.to_binary_s

# Read 4 coils starting from address 123
request = modbus.read_coils(123, 4)
byte_string = request.to_binary_s

# Send byte_string to the modbus gateway to execute the request

```


## License and copyright

MIT
