# Include hook code here
require 'fw_controll'

ActiveRecord::Base.send :include, FwControll
