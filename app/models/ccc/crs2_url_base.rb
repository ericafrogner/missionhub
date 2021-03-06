class Ccc::Crs2UrlBase < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_url_base'
  has_many :crs2_conferences, class_name: 'Ccc::Crs2Conference'
  has_many :crs2_configurations, class_name: 'Ccc::Crs2Configuration'
end
