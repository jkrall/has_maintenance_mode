require File.dirname(__FILE__) + '/lib/has_maintenance_mode'
ActionController::Base.send(:include, HasMaintenanceMode)
