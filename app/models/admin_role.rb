class AdminRole < ApplicationRecord
  belongs_to :admin, class_name: "Admin"
  belongs_to :role, class_name: "Role"
end
