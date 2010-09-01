# FwControll
module FwControll
  @@cmd_options = {
    :table          => "filter",
    :action         => :include,
    :proto          => 'tcp',
    :dest           => nil,
    :source         => nil,
    :target         => nil,
    :in_interface   => nil,
    :out_interface  => nil,
    :dport          => nil,
    :sport          => nil,
    :options        => nil
  }
  mattr_reader :cmd_options

  @@fw_actions = {
    :include  => "-I",
    :delete   => "-D",
    :zero     => "-Z",
    :flush    => "-F",
    :append   => "-A"
  }
  mattr_reader :fw_actions

  @@fw_targets = {
    :reject   => "REJECT",
    :redirect => "REDIRECT",
    :accept   => "ACCEPT",
    :drop     => "DROP",
    :queue    => "QUEUE",
    :return   => "RETURN"
  }
  mattr_reader :fw_targets

  @@options_switches = {
    :source         => '-s',
    :dest           => '-d',
    :in_interface   => '-i',
    :out_interface  => '-o',
    :dport          => '--dport',
    :sport          => '--sport'
  }
  mattr_reader :options_switches

  def self.included(base)
    base.extend(ClassMethods)
  end

  # I'm using the configuration mechanics as seen on comatose. Maybe an overkill at the moment, 
  # but, as I have plans for this project, a good thing in my eyes
  def self.config
    @@config ||= Configuration.new
  end

  def self.configure(&block)
    raise "#configure must be sent a block" unless block_given?
    yield config
    config.validate!
  end

  module ClassMethods
    def fw_rules_list chain = nil
      #inits
      result = {}
      actual_chain = ""
  
      ports = `sudo #{FwControll.config.command} -L #{chain} -n --line-numbers`.each do |x|
        case x
        when /^Chain/ # a new Chain begin
          actual_chain = x.split[1]
          result.store(actual_chain, [])
        when /^num*/ # discard declarative rows
        else
          rule = x.split
          unless rule.empty? # discard empty rows
            result[actual_chain] << { :num    => rule[0],
                                      :target => rule[1],
                                      :proto  => rule[2],
                                      :source => rule[4],
                                      :dest   => rule[5],
                                      :opts   => rule[6,rule.length-7],
                                      :raw    => x
                                    }
          end
        end
      end
      result
    end

    def fw_cmd chain, options = {}
      options = options.symbolize_keys.reverse_merge FwControll.cmd_options
      
      cmd = "sudo #{FwControll.config.command} -t #{options[:table]} #{FwControll.fw_actions[options[:action]]} #{chain} -p #{options[:proto]}"
      FwControll.options_switches.each_key do |k|
        cmd << " #{FwControll.options_switches[k]} #{options[k].to_s} " unless options[k].nil?
      end
      cmd << " -j #{FwControll.fw_targets[options[:target]]} " unless options[:target].nil?
      cmd << options[:options] unless options[:options].nil?
      `#{cmd}`
    end
  end

  class Configuration

     attr_accessor_with_default :command,     '/sbin/iptables'
     attr_accessor_with_default :sudo_options,     ''

     def validate!
       raise ConfigurationError.new( "command must exist") unless File.file?(@command)
       true
     end

     class ConfigurationError < StandardError; end

  end

end

require 'dispatcher' unless defined?(::Dispatcher)
::Dispatcher.to_prepare :fw_controll do
    FwControll.config
end
