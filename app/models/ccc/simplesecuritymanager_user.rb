class Ccc::SimplesecuritymanagerUser < ActiveRecord::Base

  establish_connection :uscm

  self.primary_key = 'userID'
  self.table_name = 'simplesecuritymanager_user'
  has_one :sp_user, class_name: 'Ccc::SpUser'
  has_one :mpd_user, class_name: 'Ccc::MpdUser', dependent: :destroy
  has_one :infobase_user, class_name: 'Ccc::InfobaseUser', dependent: :destroy
  has_one :si_user, class_name: 'Ccc::SiUser', foreign_key: 'ssm_id'
  has_one :pr_user, class_name: 'Ccc::PrUser', dependent: :destroy, foreign_key: 'ssm_id'
  has_many :sn_user_memberships, class_name: 'Ccc::SnUserMembership'
  has_many :authentications, class_name: 'Ccc::Authentication', foreign_key: 'user_id'

  def merge(other)
    if other.mpd_user && mpd_user
      mpd_user.merge(other.mpd_user)
    elsif other.mpd_user
      other.mpd_user.update_attribute(:user_id, userID)
    end

    if other.infobase_user && infobase_user
      infobase_user.merge(other.infobase_user)

    elsif other.infobase_user
      other.infobase_user.update_attribute(:user_id, userID)
    end

    if other.pr_user && pr_user
      other.pr_user.destroy				
    elsif other.pr_user
      other.pr_user.update_attribute(:ssm_id, userID)
    end

    if other.si_user && si_user
      other.si_user.destroy				
    elsif other.si_user
      SiUser.where(["ssm_id = ? or created_by_id = ?", other.userID, other.userID]).each do |ua|
        ua.update_attribute(:ssm_id, userID) if ua.ssm_id == other.userID
        ua.update_attribute(:created_by_id, personID) if ua.created_by_id == other.userID
      end
    end

    other.sn_user_memberships.each { |ua| ua.update_attribute(:user_id, id) }

  end
end
