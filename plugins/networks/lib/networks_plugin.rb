require_dependency "#{File.dirname __FILE__}/ext/environment"
require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/organization"

require_dependency "#{File.dirname __FILE__}/ext/sub_organizations_plugin/relation"

class NetworksPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('networks_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('networks_plugin.lib.plugin.description')
  end

  def js_files
    ['networks'].map{ |j| "javascripts/#{j}" }
  end

  def stylesheet?
    true
  end

  def control_panel_buttons
    {:title => I18n.t('networks_plugin.views.control_panel.structure'), :icon => 'networks-manage-network', :url => {:controller => :networks_plugin_network, :action => :show_structure}} if context.profile.node?
  end

  ProfileEditorFilter = proc do
    if profile.network_node?
      redirect_to :controller => :networks_plugin_node, :profile => profile.network.identifier, :action => :edit, :id => profile.id
    end
  end
  def profile_editor_controller_filters
    [
      {:type => 'before_filter', :method_name => 'networks_profile_editor',
       :options => {:only => [:edit]}, :block => ProfileEditorFilter},
    ]
  end

end
