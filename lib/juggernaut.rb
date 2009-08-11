require "yaml"
require "socket"

module Juggernaut
  CONFIG = YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/juggernaut_hosts.yml")).result).freeze
  CR = "\0"
  
  class << self
    
    def send_to_all(data)
      fc = {
        :command   => :broadcast,
        :body      => data, 
        :type      => :to_channels,
        :channels  => []
      }
      send_data(fc)
    end
    
    def send_to_channels(data, channels)
      fc = {
        :command   => :broadcast,
        :body      => data, 
        :type      => :to_channels,
        :channels  => channels
      }
      send_data(fc)
    end
    alias send_to_channel send_to_channels
    
    def send_to_clients(data, client_ids)
      fc = {
        :command    => :broadcast,
        :body       => data, 
        :type       => :to_clients,
        :client_ids => client_ids
      }
      send_data(fc)
    end
    alias send_to_client send_to_clients
    
    def send_to_clients_on_channels(data, client_ids, channels)
      fc = {
        :command    => :broadcast,
        :body       => data, 
        :type       => :to_clients,
        :client_ids => client_ids,
        :channels   => channels
      }
      send_data(fc)
    end
    alias send_to_clients_on_channel send_to_clients_on_channels
    alias send_to_client_on_channels send_to_clients_on_channels
    
    def remove_channels_from_clients(client_ids, channels)
      fc = {
        :command    => :query,
        :type       => :remove_channels_from_client,
        :client_ids => client_ids,
        :channels   => channels
      }
      send_data(fc)
    end
    alias remove_channel_from_client remove_channels_from_clients
    alias remove_channels_from_client remove_channels_from_clients
    
    def remove_all_channels(channels)
      fc = {
        :command    => :query,
        :type       => :remove_all_channels,
        :channels   => channels
      }
      send_data(fc)
    end
    
    def show_clients
      fc = {
        :command  => :query,
        :type     => :show_clients
      }
      send_data(fc, true).flatten
    end
    
    def show_client(client_id)
      fc = {
        :command    => :query,
        :type       => :show_client,
        :client_id  => client_id
      }
      send_data(fc, true).flatten[0]
    end
    
    def show_clients_for_channels(channels)
      fc = {
        :command    => :query,
        :type       => :show_clients_for_channels,
        :channels   => channels
      }
      send_data(fc, true).flatten
    end
    alias show_clients_for_channel show_clients_for_channels

    def send_data(hash, response = false)
      hash[:channels]   = Array(hash[:channels])   if hash[:channels]
      hash[:client_ids] = Array(hash[:client_ids]) if hash[:client_ids]
      
      res = []
      hosts.each do |address|
        begin
          hash[:secret_key] = address[:secret_key] if address[:secret_key]
          
          @socket = TCPSocket.new(address[:host], address[:port])
          # the \0 is to mirror flash
          @socket.print(hash.to_json + CR)
          @socket.flush
          res << @socket.readline(CR) if response
        ensure
          @socket.close if @socket and !@socket.closed?
        end
      end
      res.collect {|r| ActiveSupport::JSON.decode(r.chomp!(CR)) } if response
    end
    
  private
    
    def hosts
      CONFIG[:hosts].select {|h| 
        !h[:environment] or h[:environment].to_s == ENV['RAILS_ENV']
      }
    end
    
  end
  
  module RenderExtension
    def self.included(base)
      base.send :include, InstanceMethods
    end
    
    module InstanceMethods
      # We can't protect these as ActionMailer complains

        def render_with_juggernaut(options = nil, extra_options = {}, &block)
          if options == :juggernaut or (options.is_a?(Hash) and options[:juggernaut])
            begin
              if @template.respond_to?(:_evaluate_assigns_and_ivars, true)
                @template.send(:_evaluate_assigns_and_ivars)
              else
                @template.send(:evaluate_assigns)
              end
              
              generator = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@template, &block)            
              render_for_juggernaut(generator.to_s, options.is_a?(Hash) ? options[:juggernaut] : nil)
            ensure
              erase_render_results
              reset_variables_added_to_assigns
            end
          else
            render_without_juggernaut(options, extra_options, &block)
          end
        end

        def render_juggernaut(*args)
          juggernaut_options = args.last.is_a?(Hash) ? args.pop : {}
          render_for_juggernaut(render_to_string(*args), juggernaut_options)
        end

        def render_for_juggernaut(data, options = {})
          if !options or !options.is_a?(Hash)
            return Juggernaut.send_to_all(data)
          end
          
          case options[:type]
            when :send_to_all
              Juggernaut.send_to_all(data)
            when :send_to_channels
              juggernaut_needs options, :channels
              Juggernaut.send_to_channels(data, options[:channels])
            when :send_to_channel
              juggernaut_needs options, :channel
              Juggernaut.send_to_channel(data, options[:channel])
            when :send_to_client
              juggernaut_needs options, :client_id
              Juggernaut.send_to_client(data, options[:client_id])
            when :send_to_clients
              juggernaut_needs options, :client_ids
              Juggernaut.send_to_clients(data, options[:client_ids])
            when :send_to_client_on_channel
              juggernaut_needs options, :client_id, :channel
              Juggernaut.send_to_clients_on_channel(data, options[:client_id], options[:channel])
            when :send_to_clients_on_channel
              juggernaut_needs options, :client_ids, :channel
              Juggernaut.send_to_clients_on_channel(data, options[:client_ids], options[:channel])
            when :send_to_client_on_channels
              juggernaut_needs options, :client_ids, :channels
              Juggernaut.send_to_clients_on_channel(data, options[:client_id], options[:channels])
            when :send_to_clients_on_channels
              juggernaut_needs options, :client_ids, :channels
              Juggernaut.send_to_clients_on_channel(data, options[:client_ids], options[:channels])
          end
        end

        def juggernaut_needs(options, *args)
          args.each do |a|
            raise "You must specify #{a}" unless options[a]
          end
        end
        
    end
  end
end
