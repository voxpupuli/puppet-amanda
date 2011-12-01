module Puppet::Parser::Functions
  newfunction(:amanda_config_files, :type => :rvalue) do |args|

    config      = args[0]
    config_path = args[1]
    config_path = File.join('/etc/amanda', config) if config_path.nil?
    config_path = File.join(config_path, config)

    files_path    = String.new
    master_prefix = String.new

    [lookupvar('fqdn'), "default"].each do |subdir|
      master_prefix = File.join(subdir, config) 
      files_path = File.join(
        Puppet::Module.find('amanda', Thread.current[:environment]).file_directory,
        subdir,
        config
      )
      break if File.exists?(files_path)
    end

    files = Dir.glob(files_path + "/**/*")
    files.map! do |f|
      type = File.ftype(f) == "directory" ? "directory" : "file"
      agent_path  = f.sub(files_path, config_path)
      master_path = f.sub(files_path, master_prefix)
      type << ':' << agent_path << ':' << master_path
    end

    files

  end
end
