# encoding: ASCII-8BIT
# frozen_string_literal: true

require 'modbus'

# Example captures
# http://www.pcapr.net/browse?q=modbus

describe 'modbus protocol helper' do
    before :each do
        @modbus = Modbus.new
        @response = nil
    end

    it "should parse and generate the same string" do
        data = "\x0\x0\x0\x0\x0\x4\x1\x1\x1\x1"
        @modbus.read(data) { |adu| @response = adu }
        expect(@response.to_binary_s).to eq(data)
        @response = nil

        data = "\x0\x0\x0\x0\x0\x4\x1\x2\x1\x1"
        @modbus.read(data) { |adu| @response = adu }
        expect(@response.to_binary_s).to eq(data)
        @response = nil
    end

    it "should generate a read coil request" do
        data = @modbus.read_coils(0).to_binary_s
        expect(data).to eq("\x0\x0\x0\x0\x0\x6\xFF\x1\x0\x0\x0\x1")
    end

    it "should generate a read inputs request" do
        data = @modbus.read_inputs(0).to_binary_s
        expect(data).to eq("\x0\x0\x0\x0\x0\x6\xFF\x2\x0\x0\x0\x1")
    end

    it "should generate a write coils request" do
        data = @modbus.write_coils(4, true).to_binary_s
        expect(data).to eq("\x00\x00\x00\x00\x00\x06\xFF\x05\x00\x04\xFF\x00")

        data = @modbus.write_coils(3, false).to_binary_s
        expect(data).to eq("\x00\x01\x00\x00\x00\x06\xFF\x05\x00\x03\x00\x00")

        data = @modbus.write_coils(4, true, true).to_binary_s
        expect(data).to eq("\x00\x02\x00\x00\x00\x08\xFF\x0F\x00\x04\x00\x02\x1\x3")

        data = @modbus.write_coils(4, false, true).to_binary_s
        expect(data).to eq("\x00\x03\x00\x00\x00\x08\xFF\x0F\x00\x04\x00\x02\x1\x2")

        data = @modbus.write_coils(4, true, true, true, true, true, true, true, true, false, true).to_binary_s
        expect(data).to eq("\x00\x04\x00\x00\x00\x09\xFF\x0F\x00\x04\x00\x0A\x2\xFF\x2")
    end

    it "should generate a write registers request" do
        data = @modbus.write_registers(5, [1, 2, 3, 4]).to_binary_s
        expect(data).to eq("\x00\x00\x00\x00\x00\x0F\xFF\x10\x00\x05\x00\x04\x8\x00\x01\x00\x02\x00\x03\x00\x04")

        data = @modbus.write_registers(5, 4).to_binary_s
        expect(data).to eq("\x00\x01\x00\x00\x00\x06\xFF\x06\x00\x05\x00\x04")
    end

    it "should return the response values" do
        data = "\x00\x00\x00\x00\x00\x04\xFF\x01\x1\x3"
        @modbus.read(data) { |adu| @response = adu }
        expect(@response.value).to eq([true, true, false, false, false, false, false, false])
        expect(@response.function_name).to eq(:read_coils)

        data = "\x00\x00\x00\x00\x00\x07\xFF\x03\x4\x0\x3\x1\x00"
        @modbus.read(data) { |adu| @response = adu }
        expect(@response.value).to eq([3, 256])
        expect(@response.function_name).to eq(:read_holding_registers)
    end

    it "should generate a serial line request" do
        data = @modbus.read_inputs(0).to_binary_s serial: true
        expect(data).to eq("\xFF\x02\x00\x00\x00\x01\x14\xAC")
    end

    it "should parse a serial line response" do
        serial_data = "\x1\x2\x3\xac\xdb\x35\x88\x22"
        @modbus.read(serial_data, serial: true) { |adu| @response = adu }
        expect(@response.to_binary_s serial: true).to eq(serial_data)
    end
end
