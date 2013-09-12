class NetworksPluginNodeController < MyProfileController

  def create
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:id]) || @network

    @new_node = NetworksPlugin::Node.new((params[:node] || {}).merge(:environment => environment))

    if params[:commit]
      @new_node.identifier = @new_node.name.to_slug
      @new_node.as_child_relations.build :parent => @node, :child => @new_node
      if @new_node.save
        render :partial => 'suppliers_plugin_shared/pagereload'
      else
        respond_to do |format|
          format.js
        end
      end
    else
      respond_to do |format|
        format.html{ render :layout => false }
      end
    end
  end

  def show
    @node = NetworksPlugin::Node.find params[:id]
  end

  def edit
    @node = NetworksPlugin::Node.find params[:id]

    if request.post?
      @node.update_attributes params[:networks_plugin_node]
    end
  end

  def destroy
    @node = NetworksPlugin::Node.find params[:id]
    @parent = @node.parent
    @node.destroy

    redirect_to :controller => :networks_plugin_network, :action => :show_structure, :node_id => @parent.id
  end

  protected

end
