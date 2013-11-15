def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::Labrea.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.install_dir(@new_resource.install_dir)
  @current_resource.version("0.0.0")
  @current_resource.override_path(@new_resource.override_path)
  if ::File.exists?(@current_resource.base_path)
    raise "Evaluation of package will fail since #{@current_resource.base_path} is not a symlink." unless ::File.symlink?(@current_resource.base_path)
    current_ver_dir = ::File.join(@current_resource.install_dir,::File.readlink(@current_resource.base_path))
    prefix = "#{@current_resource.base_path}#{@current_resource.separator}"
    Chef::Log.info prefix
    Chef::Log.info @current_resource.base_path
    Chef::Log.info current_ver_dir
    version = /#{prefix}([0-9\.]+)/.match(current_ver_dir)[1]
    @current_resource.version(version)
    Chef::Log.info("Current version of #{@current_resource.name} is #{@current_resource.version}")
    if @current_resource.version == @new_resource.version
      @current_resource.exists = true
    end
  end
end

action :install do
  @install_mode = :install
  if @current_resource.exists
    @install_mode = :verify
  elsif @current_resource.version != "0.0.0"
    cur_ver = @current_resource.version.split('.')
    new_ver = @new_resource.version.split('.')
    cur_ver.length.times do |i|
      if cur_ver[i] > new_ver[i]
        @install_mode = :downgrade
      end
    end
    @install_mode = :upgrade unless @install_mode == :downgrade
  end

  local_file = ::File.join(Chef::Config['file_cache_path'], URI.parse(@new_resource.source).path.split('/').last)

  file_source = @new_resource.source

  r = remote_file @new_resource.name do
    path local_file
    source file_source
    action :nothing
  end
  r.run_action(:create_if_missing)

  l = Chef::Recipe::LabreaModule::Labrea.new(local_file, @new_resource.install_dir, {:exclude => @new_resource.config_files})
  Chef::Log.info "DEBUG labrea object: #{l.inspect}"
  #Probably should break out upgrades into different actions, will keep here for now. 
  case @install_mode
  when :install
    Chef::Log.info "DEBUG Version Path: #{@new_resource.versioned_path}"
    path = "#{@new_resource.versioned_path}"
    l.checksum_file = "#{@new_resource.versioned_path}.checksum.json"
    Chef::Log.info "DEBUG Checksum File: #{l.checksum_file}"
    converge_by("install #{@new_resource.name}, version #{@new_resource.version}") do
      Chef::Log.info "DEBUG Run install"
      l.install
      ::File.symlink(@new_resource.versioned_path, @current_resource.base_path)
    end
  when :downgrade
    raise "Downgrade indicated but force_downgrade is not set" unless @new_resource.force_downgrade
    l.checksum_file = "#{@new_resource.versioned_path}.checksum.json"
    converge_by("downgrade #{@new_resource.name}, version #{@current_resource.version} to version #{@new_resource.version}") do
      ::File.delete(@new_resource.base_path)
      l.install
      ::File.symlink(@new_resource.versioned_path, @current_resource.base_path)
    end
  when :upgrade
    l.checksum_file = "#{@new_resource.versioned_path}.checksum.json"
    converge_by("upgrade #{@new_resource.name}, version #{@current_resource.version} to version #{@new_resource.version}") do
      ::File.delete(@new_resource.base_path)
      l.install
      ::File.symlink(@new_resource.versioned_path,@current_resource.base_path)
    end
  when :verify
    l.checksum_file = "#{@current_resource.versioned_path}.checksum.json"
    converge_by("verify #{@new_resource.name}, version #{@new_resource.version}") do
    end
    if whyrun_mode?
      changes = l.verify(true)
      if changes.length > 0
        changes.each do |change|
          Chef::Log.info("Would repair file #{change}")
	end
      end
    else
      changes = l.verify(false)
      if changes.length > 0
        changes.each do |change|
          Chef::Log.info("Repaired file #{change}")
	end
      end
    end
  end
end
