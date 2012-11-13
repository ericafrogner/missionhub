class Ccc::Crs2AdditionalInfoItem < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_additional_info_item'
  belongs_to :crs2_conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
end
