def flutter_install_all_ios_pods(ios_application_path = nil)
  flutter_application_path ||= File.join(ios_application_path, '..')
  podfile_path = File.join(ios_application_path, 'Podfile')

  symlinks_dir = File.join(ios_application_path, '.symlinks')
  FileUtils.mkdir_p(symlinks_dir)

  plugins_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')
  return unless File.exist?(plugins_file)

  JSON.parse(File.read(plugins_file))['plugins']['ios'].each do |plugin|
    name = plugin['name']
    path = plugin['path']
    pod name, :path => File.join(path, 'ios')
  end
end

def flutter_additional_ios_build_settings(target)
  return unless target.platform_name == :ios
  target.build_configurations.each do |config|
    config.build_settings['ENABLE_BITCODE'] = 'NO'
  end
end
