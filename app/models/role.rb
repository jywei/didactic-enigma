class Role < ApplicationRecord
  has_many :admin_roles, dependent: :destroy
  has_many :admins, :through => :admin_roles, foreign_key: "admin_id", dependent: :destroy

  def self.info
    all.map do |role|
      {
        id:          role.id,
        controller:  role.controller,
        channel:     role.channel,
        action:      role.action,
        name:        role.name,
        description: role.description
      }
    end
  end
end
