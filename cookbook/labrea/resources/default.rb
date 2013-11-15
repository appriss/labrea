actions :install, :uninstall, :clean_old

default_action :install

attribute :package_name, :name_attribute => true, :kind_of => String, :required => true
attribute :install_dir, :kind_of => String, :required => true
attribute :version, :kind_of => String, :required => true
attribute :source, :kind_of => String 
attribute :upgrade, :kind_of => [TrueClass, FalseClass] , :default => true
attribute :config_files, :kind_of => Array
attribute :versions_to_keep, :kind_of => Fixnum, :default => 1
attribute :force_downgrade, :kind_of => [TrueClass, FalseClass], :default => false
attribute :separator, :kind_of => String, :default => "-"
attribute :override_path, :kind_of => String

attr_accessor :exists

def versioned_path
  return @override_path if @override_path
  #Have to reset attribute default, definition doesn't get loaded in time
  @separator = "-" unless @separator
  base_name = [ @name, @version ].join(@separator)
  return ::File.join(@install_dir,base_name)
end

def base_path
  ::File.join(::File.expand_path(@install_dir),@name)
end
