require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require 'ostruct'

describe "when loading the config file" do

  class FakeController < ActionController::Base
  end

  describe "when loading the plugin" do
    before(:each) do
      File.stub!(:open).and_return(mock("config_file"))
      YAML.stub!(:load).and_return({})
    end
    it "should load the yml file from RAILS_ROOT/config/maintenance_modes.yml" do
      File.should_receive(:open).with([RAILS_ROOT, 'config', 'maintenance_modes.yml'].join('/')).and_return(mock("config_file"))      
      FakeController.send(:has_maintenance_mode, :url=>'/under_construction')
    end
    it "should add the before_filter" do
      FakeController.send(:has_maintenance_mode, :url=>'/under_construction')    
      FakeController.filter_chain[0].method.should == :check_maintenance_mode
    end
  end

  describe "with :all => :under_construction" do
    before(:each) do
      File.stub!(:open).and_return(mock("config_file"))
      YAML.stub!(:load).and_return({:all=>:under_construction})
      FakeController.send(:has_maintenance_mode, :url=>'/under_construction')
      @f = FakeController.new
      @f.stub!(:redirect_to)
    end
    it "should return false" do
      @f.check_maintenance_mode.should be_false
    end
    it "should redirect" do
      @f.should_receive(:redirect_to).with('/under_construction')
      @f.check_maintenance_mode
    end
  end
  describe "with :all => :normal" do
    before(:each) do
      File.stub!(:open).and_return(mock("config_file"))
      YAML.stub!(:load).and_return({:all=>:normal})
      FakeController.send(:has_maintenance_mode, :url=>'/under_construction')
      @f = FakeController.new
      @f.stub!(:redirect_to)      
    end
    it "should return true" do
      @f.check_maintenance_mode.should be_true
    end
    it "should not redirect" do
      @f.should_not_receive(:redirect_to)
      @f.check_maintenance_mode
    end
  end
  
  describe "with {:fake_controller=>:under_construction}" do
    before(:each) do
      File.stub!(:open).and_return(mock("config_file"))
      YAML.stub!(:load).and_return({:fake_controller=>:under_construction})
      FakeController.send(:has_maintenance_mode, :url=>'/under_construction')
      @f = FakeController.new
      @f.stub!(:redirect_to)      
    end
    it "should return false" do
      @f.check_maintenance_mode.should be_false
    end
    it "should redirect" do
      @f.should_receive(:redirect_to).with('/under_construction')
      @f.check_maintenance_mode
    end
  end
  describe "with {:fake_controller=>:normal}" do
    before(:each) do
      File.stub!(:open).and_return(mock("config_file"))
      YAML.stub!(:load).and_return({:fake_controller=>:normal})
      FakeController.send(:has_maintenance_mode, :url=>'/under_construction')
      @f = FakeController.new
      @f.stub!(:redirect_to)      
    end
    it "should return true" do
      @f.check_maintenance_mode.should be_true
    end
    it "should not redirect" do
      @f.should_not_receive(:redirect_to)
      @f.check_maintenance_mode
    end
  end

  describe "with {:fake_controller=>{:show=>:normal, :new=>:under_construction}}" do
    before(:each) do
      File.stub!(:open).and_return(mock("config_file"))
      YAML.stub!(:load).and_return({:fake_controller=>{:show=>:normal, :new=>:under_construction}})
      FakeController.send(:has_maintenance_mode, :url=>'/under_construction')
      @f = FakeController.new
      @f.stub!(:redirect_to)      
    end
    describe "for :new action" do
      before(:each) do
        @f.should_receive(:action_name).and_return(:new)
      end
      it "should return false" do
        @f.check_maintenance_mode.should be_false
      end
      it "should redirect" do
        @f.should_receive(:redirect_to).with('/under_construction')
        @f.check_maintenance_mode
      end
    end
    describe "for :show action" do
      before(:each) do
        @f.should_receive(:action_name).and_return(:show)
      end
      it "should return true" do
        @f.check_maintenance_mode.should be_true
      end
      it "should not redirect" do
        @f.should_not_receive(:redirect_to)
        @f.check_maintenance_mode
      end
    end
  end
  
end

