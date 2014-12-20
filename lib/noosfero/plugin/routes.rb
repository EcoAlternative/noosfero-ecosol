plugins_root = Rails.env.test? ? 'plugins' : '{baseplugins,config/plugins}'

Dir.glob(Rails.root.join(plugins_root, '*', 'controllers')) do |controllers_dir|
  prefixes_by_folder = {'public' => 'plugin',
                        'profile' => 'profile(/:profile)/plugin',
                        'myprofile' => 'myprofile(/:profile)/plugin',
                        'admin' => 'admin/plugin'}

  controllers_by_folder = prefixes_by_folder.keys.inject({}) do |hash, folder|
    hash.merge!({folder => Dir.glob(File.join(controllers_dir, folder, '*')).map {|full_names| File.basename(full_names).gsub(/_controller.rb$/,'')}})
  end

  plugin_name = File.basename(File.dirname(controllers_dir))

  controllers_by_folder.each do |folder, controllers|
    controllers.each do |controller|
      controller_name = controller.gsub("#{plugin_name}_plugin_",'')
      if %w[profile myprofile].include?(folder)
        match "#{prefixes_by_folder[folder]}/#{plugin_name}/#{controller_name}(/:action(/:id))", :controller => controller, :profile => /#{Noosfero.identifier_format}/
      else
        match "#{prefixes_by_folder[folder]}/#{plugin_name}/#{controller_name}(/:action(/:id))", :controller => controller
      end
    end
  end

  match 'plugin/' + plugin_name + '(/:action(/:id))', :controller => plugin_name + '_plugin'
  match 'profile(/:profile)/plugin/' + plugin_name + '(/:action(/:id))', :controller => plugin_name + '_plugin_profile', :profile => /#{Noosfero.identifier_format}/
  match 'myprofile(/:profile)/plugin/' + plugin_name + '(/:action(/:id))', :controller => plugin_name + '_plugin_myprofile', :profile => /#{Noosfero.identifier_format}/
  match 'admin/plugin/' + plugin_name + '(/:action(/:id))', :controller => plugin_name + '_plugin_admin'
end
