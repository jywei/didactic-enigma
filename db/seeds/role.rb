
admin = Admin.find_or_create_by(username: 'admin', password: "1234")
admin1 = Admin.find_or_create_by(username: 'admin1', password: "1234")
admin2 = Admin.find_or_create_by(username: 'admin2', password: "1234")
admin3 = Admin.find_or_create_by(username: 'admin3', password: "1234")
admin4 = Admin.find_or_create_by(username: 'admin4', password: "1234")

Rails.application.eager_load!

exception = %w(apipie_validations current_user no_token? parsed_token raw_cookie rescue_to_log token_outdated? verify_token)
Api::V1::ApplicationController.descendants.each do |controller|
  controller.action_methods.each do |action|
    next if action.in? exception
    role = Role.find_or_create_by(controller: controller.name, action: action)
    admin.add_role(role.id)
    admin1.add_role(role.id)
    admin2.add_role(role.id)
    admin3.add_role(role.id)
    admin4.add_role(role.id)
  end
end
