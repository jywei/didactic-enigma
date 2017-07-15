puts 'User seeds importing...'
require 'faker'
I18n.reload!
include AncestorUpdate

def api_create(tier, agent = nil)
  params = {
    username:             agent.nil? ? "tier#{tier}" : "tier8-#{tier}",
    password:             "12345678",
    bank_id:              agent.nil? ? (tier == 0 ? nil : User.last.id) : agent.id,
    # bank_id:              agent.nil? ? User.last.id : agent.id,
    tier:                 tier,
    access_token:         User.generate_token,
    user_profile: {
      nickname:           Faker::Name.last_name,
      note:               Faker::Name.first_name,
      quota:              100,
      delay_original:     0,
      delay_running:      0,
      parlay:             10,
      status:             '正常',
      accessable:         true
    }
  }

  if tier == 0
    user = User.new.create_user(params)
  else

    if !agent.nil?
      user = User.find(agent.id)
    else
      user = User.where(tier: tier - 1).last
    end

    user = user.create_user(params)
  end
  # puts "User created, tier #{user.id} "
  update_ancestors(user)
end

(0..7).each{ |tier| api_create(tier) }

agent = User.find_by(tier: 7)
(1..4).each{ |tier| api_create(tier, agent) }


# users = User.where(tier == 0)
# user.each do |user|
#     User::Allotter.create_default(user.id)
# end

# operators = [8, 11, 34, 38, 41]
# players = [9, 31, 35, 36, 37, 42]
# User.where.not(id: operators + players).delete_all
#
# non_default_users = User.where("id in (?)", operators)
# non_default_users.each do |user|
#   user.create_default_setting
# end
#
#
# operators.each do |id|
#   moderator = User.create(
#                   # email: Faker::Internet.email,
#                   encrypted_password: "12345678",
#                   username: "tier1",
#                   bank_id: id,
#                   total_quota: 100,
#                   tier: 1
#                   )
#   supervisor = User.create(
#                 # email: Faker::Internet.email,
#                 encrypted_password: "12345678",
#                 username: "tier2",
#                 bank_id: moderator.id,
#                 total_quota: 100,
#                 tier: 2
#                 )
#   director = User.create(
#                   # email: Faker::Internet.email,
#                   encrypted_password: "12345678",
#                   username: "tier3",
#                   bank_id: supervisor.id,
#                   total_quota: 100,
#                   tier: 3
#                   )
#   major_shareholder = User.create(
#                 # email: Faker::Internet.email,
#                 encrypted_password: "12345678",
#                 username: "tier4",
#                 bank_id: director.id,
#                 total_quota: 100,
#                 tier: 4
#                 )
#   shareholder = User.create(
#                   # email: Faker::Internet.email,
#                   encrypted_password: "12345678",
#                   username: "tier5",
#                   bank_id: major_shareholder.id,
#                   total_quota: 100,
#                   tier: 5
#                   )
#   general_agent = User.create(
#                   # email: Faker::Internet.email,
#                   encrypted_password: "12345678",
#                   username: "tier6",
#                   bank_id: shareholder.id,
#                   total_quota: 100,
#                   tier: 6
#                   )
#   agent = User.create(
#                   # email: Faker::Internet.email,
#                   encrypted_password: "12345678",
#                   username: "tier7",
#                   bank_id: general_agent.id,
#                   total_quota: 100,
#                   tier: 7
#                   )
#
#   i = 1
#   until i > 4 do
#     User.create(
#                   # email: Faker::Internet.email,
#                   encrypted_password: "12345678",
#                   username: "tier8-#{i}",
#                   bank_id: agent.id,
#                   total_quota: 100,
#                   tier: 8
#                   )
#     i += 1
#   end
#
#   User.where("username LIKE ? AND tier = ?", "%tier%", 8).each do |user|
#     AncestorUpdate.update_ancestors(user)
#   end
# end







# agent = User.find_by(tier: 7)
#
# (1..4).each do |tier|
#   User.create(
#                 encrypted_password: "12345678",
#                 username: "tier8-#{tier}",
#                 bank_id: agent.id,
#                 total_quota: 100,
#                 tier: 8
#               )
# end
