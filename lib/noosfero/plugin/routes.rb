plugins_root = Rails.env.test? ? 'plugins' : '{baseplugins,config/plugins}'
prefixes_by_folder = {public: 'plugin',
                      profile: 'profile(/:profile)/plugin',
                      myprofile: 'myprofile(/:profile)/plugin',
                      admin: 'admin/plugin'}

Dir.glob(Rails.root.join(plugins_root, '*', 'controllers')) do |controllers_dir|
  plugin_name = File.basename(File.dirname(controllers_dir))

  controllers_by_folder = prefixes_by_folder.keys.inject({}) do |hash, folder|
    path = "#{controllers_dir}/#{folder}/"
    hash[folder] = Dir.glob("#{path}{*.rb,#{plugin_name}_plugin/*.rb}").map do |filename|
      filename.gsub(path, '').gsub(/_controller.rb$/, '')
    end
    hash
  end

  controllers_by_folder.each do |folder, controllers|
    controllers.each do |controller|
      controller_name = controller.gsub /#{plugin_name}_plugin[_\/]/, ''
      if %w[profile myprofile].include?(folder.to_s)
        match "#{prefixes_by_folder[folder]}/#{plugin_name}/#{controller_name}(/:action(/:id))", controller: controller,
          profile: /#{Noosfero.identifier_format_in_url}/i, via: :all, as: controller.tr('/','_')
      else
        match "#{prefixes_by_folder[folder]}/#{plugin_name}/#{controller_name}(/:action(/:id))", controller: controller,
          via: :all, as: controller.tr('/','_')
      end
    end
  end

  # DEPRECATED
  begin
    match 'plugin/' + plugin_name + '(/:action(/:id))', controller: "#{plugin_name}_plugin", via: :all, as: "#{plugin_name}_plugin"
    match "profile(/:profile)/plugin/#{plugin_name}(/:action(/:id))", controller: "#{plugin_name}_plugin_profile",
      profile: /#{Noosfero.identifier_format_in_url}/i, via: :all, as: "#{plugin_name}_plugin_profile"
    match "myprofile(/:profile)/plugin/#{plugin_name}(/:action(/:id))", controller: "#{plugin_name}_plugin_myprofile",
      profile: /#{Noosfero.identifier_format_in_url}/i, via: :all, as: "#{plugin_name}_plugin_myprofile"
    match 'admin/plugin/' + plugin_name + '(/:action(/:id))', controller: "#{plugin_name}_plugin_admin",
      via: :all, as: "#{plugin_name}_plugin_admin"
  rescue ArgumentError
    # duplicate route name (as:)
  end
end
