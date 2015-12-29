#!/usr/bin/env ruby
#
# check-ipmi-sensors.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-plugin/check/cli'
require 'rubyipmi'
require 'json'
require 'socket'

class CheckIPMISensors < Sensu::Plugin::Check::CLI
  option :user,
         :description => "IPMI username",
         :short => "-u <USER>",
         :long => "--user <USER>",
         :required => true

  option :password,
         :description => "IPMI password",
         :short => "-p <PASSWORD>",
         :long => "--password <PASSWORD>",
         :required => true

  option :host,
         :description => "IPMI host (default: localhost)",
         :short => "-H <HOST>",
         :long => "--host <HOST>",
         :default => "localhost"

  option :provider,
         :description => "IPMI provider (default: auto)",
         :long => "--provider <PROVIDER>",
         :in => ["any", "freeipmi", "openipmi"],
         :default => "any"

  option :driver,
         :description => "IPMI driver (default: auto)",
         :long => "--driver <driver>",
         :in => ["auto", "lan15", "lan20", "open"],
         :default => "auto"

  option :sensor,
         :description => "Comma separated list of IPMI sensors (default: ALL)",
         :long => "--sensor <SENSOR>",
         :proc => proc { |a| a.split(',') },
         :default => []

  option :sensor_regex,
         :description => "Comma separated list of IPMI sensors (regex)",
         :long => "--sensor-regex <SENSOR>",
         :proc => proc { |a| a.split(',') },
         :default => []

  option :ignore_sensor,
         :description => "Comma separated list of IPMI sensors to ignore",
         :long => "--ignore-sensor <SENSOR>",
         :proc => proc { |a| a.split(',') },
         :default => []

  option :ignore_sensor_regex,
         :description => "Comma separated list of IPMI sensors to ignore (regex)",
         :long => "--ignore-sensor-regex <SENSOR>",
         :proc => proc { |a| a.split(',') },
         :default => []

  option :warn,
         :description => "Warn instead of throwing a critical failure",
         :short => "-w",
         :long => "--warn",
         :boolean => false

  def initialize()
    super
    @ipmi = Rubyipmi.connect(config[:user], config[:password], config[:host], config[:provider], {:driver => config[:driver]})
  end

  def send_client_socket(data)
    sock = UDPSocket.new
    sock.send(data + "\n", 0, "127.0.0.1", 3030)
  end

  def send_ok(check_name, msg)
    event = {"name" => check_name, "status" => 0, "output" => "OK: #{msg}", "handler" => config[:handler]}
    send_client_socket(event.to_json)
  end

  def send_warning(check_name, msg)
    event = {"name" => check_name, "status" => 1, "output" => "WARNING: #{msg}", "handler" => config[:handler]}
    send_client_socket(event.to_json)
  end

  def send_critical(check_name, msg)
    event = {"name" => check_name, "status" => 2, "output" => "CRITICAL: #{msg}", "handler" => config[:handler]}
    send_client_socket(event.to_json)
  end

  def send_unknown(check_name, msg)
    event = {"name" => check_name, "status" => 3, "output" => "UNKNOWN: #{msg}", "handler" => config[:handler]}
    send_client_socket(event.to_json)
  end

  def get_ipmi_sensors()
    sensors = {}

    @ipmi.sensors.list.each do |name, sensor|
      if config[:ignore_sensor].size > 0
        next if config[:ignore_sensor].include?(name)
      end

      if config[:ignore_sensor_regex].size > 0
        b = false
        config[:ignore_sensor_regex].each do |sensor|
          if name =~ Regexp.new(sensor)
            b = true
            break
          end
        end
        next if b
      end

      if config[:sensor].size > 0
        next unless config[:sensor].include?(name)
      end

      if config[:sensor_regex].size > 0
        b = true
        config[:sensor_regex].each do |sensor|
          if name =~ Regexp.new(sensor)
            b = false
            break
          end
        end
        next if b
      end

      sensors[name] = sensor
    end

    sensors
  end

  def run
    problems = 0

    ipmi_sensors = get_ipmi_sensors()
    ipmi_sensors.each do |name, sensor|
      check_name = "ipmi-sensor-#{name}"
      case sensor[:unit].downcase
        when "n/a", "nominal"
          # life's good
          send_ok(check_name, "IPMI sensor #{name} is healthy (State: #{sensor[:state]})")
          next

        when "warning"
          send_critical(check_name, "IPMI sensor #{name} is not healthy (State: #{sensor[:state]})")
          problems += 1

        when "critical"
          send_critical(check_name, "IPMI sensor #{name} is not healthy (State: #{sensor[:state]})")
          problems += 1

        else
          send_unknown(check_name, "IPMI sensor #{name} is unknown (State: #{sensor[:state]})")

      end
    end

    if problems > 0
      message "Found #{problems} problems"
      warning if config[:warn]
      critical
    else
      ok "All IPMI sensors (#{ipmi_sensors.keys.join(', ')}) are OK"
    end
  end
end
