Puppet::Parser::Functions.newfunction(:create_amanda_config_files, :doc => <<-'ENDHEREDOC') do |args|
  Creates file resources in the catalog based on files in a module.

  Usage: create_amanda_config_files(CONFIG, [SOURCE, [PARAMS]])

  This function takes as arguments an amanda config name, a reference to files
  located in a module, and a hash containing basic file resource parameters.
  Files found in the path specified will be recursively found and added to the
  catalog.

  CONFIG should be a string, e.g. "example". This refers to an amanda config.

  SOURCE should be a string of the form "modules/<modulename>/path", where
  "modules" is a constant, "<modulename>" is the name of the module in which
  the files can be found, and the optional "path" is a path specifier from the
  module's file directory.

  PARAMS should be a hash containing any of the optional values:

    :ensure            => For created files, ensure absent or present
    :directory_mode    => The mode to apply to created directories
    :file_mode         => The mode to apply to created files
    :owner             => The owner to apply to created files
    :group             => The group to apply to created files
    :configs_directory => The agent path under which to install the files

  It is expected that if CONFIG is given as "example" and SOURCE is given as
  "modules/data/amanda", the module "data" exists in the modulepath and has at
  a minimum the following files:

    $modulepath
    |- data
    |  |- manifests
    .  |  '- init.pp
    .  '- files
    .     '- amanda
             '- example
                |- ...

  Any and all files located underneath $modulepath/data/files/amanda/example
  will be defined as file resources rooted at $configs_directory, which will
  by default be taken from the amanda::params manifest but can be overriden
  using the PARAMS argument.

  ENDHEREDOC

  case args.length
    when 1, 2, 3
      config = args[0]
      source = args[1] || 'modules/amanda/server'
      params = args[2] || Hash.new
      raise ArgumentError, "the params argument must be a Hash" unless params.is_a?(Hash)
    else
      raise ArgumentError, "given #{args.length} arguments; expected 1, 2 or 3"
  end

  # Ensure the params class is loaded in case we need to lookup defaults
  amanda_params_loaded = self.catalog.classes.include?('amanda::params')
  function_include('amanda::params') unless amanda_params_loaded

  default_params = {
    :ensure            => 'present',
    :directory_mode    => '0755',
    :file_mode         => '0644',
    :owner             => self.lookupvar('amanda::params::user'),
    :group             => self.lookupvar('amanda::params::group'),
    :configs_directory => self.lookupvar('amanda::params::configs_directory'),
  }

  Puppet::Util.symbolizehash!(params)
  params = default_params.merge(params)

  if params[:ensure].to_s == 'absent'
    params[:directory_mode], params[:file_mode] = 'absent'
  end

  if not source.match(%r{modules/[-\w]+($|/\w)})
    raise ArgumentError, 'The source argument must begin with modules/<modulename>'
  end

  module_name = source.split('/')[1]

  begin
    module_files_directory = Puppet::Module.find(
      module_name,
      Thread.current[:environment]
    ).file_directory
  rescue NoMethodError => e
    raise ParseError, %Q{Unable to find referenced module "#{module_name}"}
  end

  files_path = File.join(
    module_files_directory,
    source.split('/')[2..-1]
  )

  if not File.exists?(File.join(files_path, config))
    raise ParseError, "Unable to find referenced module files #{File.join(source, config)}"
  end

  files = Dir.glob(File.join(files_path, config, '**/*'))

  resources = Hash.new
  files.each do |f|
    type = File.ftype(f)
    p = Hash.new
    p[:owner] = params[:owner]
    p[:group] = params[:group]
    p[:path]  = f.sub(files_path, params[:configs_directory])
    case File.ftype(f)
      when 'directory'
        p[:ensure]  = 'directory'
        p[:mode]    = params[:directory_mode]
      when 'file'
        p[:ensure]  = 'file'
        p[:content] = File.read(f)
        p[:mode]    = params[:file_mode]
      else
        raise ParseError, "#{f} is neither directory not file. wat."
    end
    resources[p[:path]] = p
  end
  function_create_resources(['file', resources])

end
