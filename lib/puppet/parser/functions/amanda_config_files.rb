module Puppet::Parser::Functions
  newfunction(:amanda_config_files, :type => :rvalue) do |args|

    config        = args[0]
    config_path   = args[1] || File.join('/etc/amanda', config)
    config_module = args[2] || 'amanda'
    config_root   = args[3] || 'server/example'

    config_path   = File.join(config_path, config)
    module_path   = Puppet::Module.find(config_module, Thread.current[:environment]).file_directory
    master_prefix = File.join('modules', config_module, config_root, config)
    files_path    = File.join(module_path, config_root, config)

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
