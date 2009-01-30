module HasMaintenanceMode
  def self.append_features(base) #:nodoc:
    super
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def has_maintenance_mode opts={}
      default_opts = {  :url => '/',
                        :except => nil,
                        :only => nil
                        }
      opts = default_opts.merge(opts)

      require 'yaml'
      config_file_path = [RAILS_ROOT, 'config', 'maintenance_modes.yml'].join('/')
      config_file = File.open( config_file_path )
      _maintenance_modes = YAML::load( config_file )
      
      write_inheritable_attribute(:maintenance_mode_url, opts[:url])
      write_inheritable_attribute(:maintenance_modes, _maintenance_modes)

      define_method :check_maintenance_mode do
        _modes = self.class.read_inheritable_attribute(:maintenance_modes)
        if ( _modes[:all]==:under_construction or 
             _modes[self.class.to_s.underscore.to_sym]==:under_construction or
             (_modes[self.class.to_s.underscore.to_sym].is_a?(Hash) and 
              _modes[self.class.to_s.underscore.to_sym][self.action_name]==:under_construction) )
          redirect_to self.class.read_inheritable_attribute(:maintenance_mode_url)
          return false
        end
        
        return true
      end
      
      self.send(:before_filter, :check_maintenance_mode, :except=>opts[:except], :only=>opts[:only])
    end
    
  end

end
