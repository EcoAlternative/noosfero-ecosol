require 'fast_gettext'

class Object
  include FastGettext::Translation
  alias :gettext :_
  alias :ngettext :n_
  alias :c_ :_
  alias :cN_ :N_
end


custom_locale_dir = Rails.root.join('custom_locales', Rails.env)
repos = []
if File.exists?(custom_locale_dir)
  repos << FastGettext::TranslationRepository.build('environment', :type => 'po', :path => custom_locale_dir)
end

Dir.glob('{baseplugins,config/plugins}/*/locale') do |plugin_locale_dir|
  plugin = File.basename(File.dirname(plugin_locale_dir))
  repos << FastGettext::TranslationRepository.build(plugin, :type => 'mo', :path => plugin_locale_dir)
end

# translations in place?
locale_dir = Rails.root.join('locale')
if File.exists?(locale_dir)
  repos << FastGettext::TranslationRepository.build('noosfero', :type => 'mo', :path => locale_dir)
  repos << FastGettext::TranslationRepository.build('iso_3166', :type => 'mo', :path => locale_dir)
end

FastGettext.add_text_domain 'noosfero', :type => :chain, :chain => repos
FastGettext.default_text_domain = 'noosfero'
