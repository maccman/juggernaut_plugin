require File.dirname(__FILE__) + '/lib/juggernaut'
require File.dirname(__FILE__) + '/lib/juggernaut_helper'

ActionView::Base.send(:include, Juggernaut::JuggernautHelper)

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :juggernaut => ['juggernaut/swfobject', 'juggernaut/juggernaut']

ActionController::Base.class_eval do
  alias_method :render_without_juggernaut, :render
  include Juggernaut::RenderExtension
  alias_method :render, :render_with_juggernaut
end

ActionView::Base.class_eval do
  alias_method :render_without_juggernaut, :render
  include Juggernaut::RenderExtension
  alias_method :render, :render_with_juggernaut
end