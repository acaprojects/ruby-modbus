# frozen_string_literal: true, encoding: ASCII-8BIT

Gem::Specification.new do |s|
    s.name        = "modbus"
    s.version     = '1.0.0'
    s.authors     = ["Stephen von Takach"]
    s.email       = ["steve@aca.im"]
    s.licenses    = ["MIT"]
    s.homepage    = "https://github.com/acaprojects/ruby-modbus"
    s.summary     = "Modbus protocol on Ruby"
    s.description = <<-EOF
        Constructs Modbus standard datagrams that make it easy to communicate with devices on Modbus networks
    EOF


    s.add_dependency 'bindata', '~> 2.3'

    s.add_development_dependency 'rspec', '~> 3.5'
    s.add_development_dependency 'rake',  '~> 12'


    s.files = Dir["{lib}/**/*"] + %w(modbus.gemspec README.md)
    s.test_files = Dir["spec/**/*"]
    s.extra_rdoc_files = ["README.md"]

    s.require_paths = ["lib"]
end
