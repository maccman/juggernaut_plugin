module Juggernaut # :nodoc:
  module JuggernautHelper

    def juggernaut(options = {})
      hosts = Juggernaut::CONFIG[:hosts].select {|h| !h[:environment] or h[:environment] == ENV['RAILS_ENV'].to_sym }
      random_host = hosts[rand(hosts.length)]
      options = {
        :host                 => (random_host[:public_host] || random_host[:host]),
        :port                 => (random_host[:public_port] || random_host[:port]),
        :width                => '0px',
        :height               => '0px',
        :session_id           => session.session_id,
        :swf_address          => "/juggernaut/juggernaut.swf",
        :ei_swf_address       => "/juggernaut/expressinstall.swf",
        :flash_version        => 8,
        :flash_color          => "#fff",
        :swf_name             => "juggernaut_flash",
        :bridge_name          => "juggernaut",
        :debug                => (RAILS_ENV == 'development'),
        :reconnect_attempts   => 3,
        :reconnect_intervals  => 3
      }.merge(options)
      javascript_tag "new Juggernaut(#{options.to_json});"
    end
    
    def expand_javascript_sources(sources, recursive = false)
      if sources.include?(:juggernaut)
        sources = sources[0..(sources.index(:juggernaut))] + 
          ['juggernaut/swfobject', 'juggernaut/juggernaut'] + 
          sources[(sources.index(:juggernaut) + 1)..sources.length]
        sources.delete(:juggernaut)
      end
      super(sources)
    end
    
  end
end
