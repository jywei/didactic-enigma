# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170324052113) do

  create_table "admin_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "admin_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_makers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.integer  "tx_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "slug"
    t.integer  "mgid"
    t.integer  "spid"
    t.string   "display_name"
    t.integer  "country_id"
    t.string   "country_name"
    t.index ["spid"], name: "index_categories_on_spid", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "tx_name"
    t.string   "display_name"
    t.integer  "category_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["tx_name"], name: "index_groups_on_tx_name", using: :btree
  end

  create_table "log_closes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "match_count"
    t.text     "data",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "log_errors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.integer  "user_id"
    t.text     "data",       limit: 65535
    t.string   "path"
    t.string   "uuid"
    t.text     "backtrace",  limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "message",    limit: 65535
    t.text     "params",     limit: 65535
    t.boolean  "archive",                  default: false
  end

  create_table "log_position_warnings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "match_id"
    t.integer  "offer_position_id"
    t.integer  "order_id"
    t.integer  "sport_id"
    t.string   "sport_name"
    t.integer  "category_id"
    t.string   "category_name"
    t.string   "h_team"
    t.string   "a_team"
    t.datetime "match_time"
    t.string   "warning_level"
    t.decimal  "h_position",        precision: 13, scale: 3
    t.decimal  "a_position",        precision: 13, scale: 3
    t.decimal  "d_position",        precision: 13, scale: 3
    t.decimal  "h_threshold",       precision: 13, scale: 3
    t.decimal  "a_threshold",       precision: 13, scale: 3
    t.decimal  "d_threshold",       precision: 13, scale: 3
    t.decimal  "h_distance",        precision: 13, scale: 3
    t.decimal  "a_distance",        precision: 13, scale: 3
    t.decimal  "d_distance",        precision: 13, scale: 3
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "h_team_id"
    t.integer  "a_team_id"
  end

  create_table "log_positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "offer_position_id"
    t.integer  "order_id"
    t.decimal  "h_position",        precision: 13, scale: 3
    t.decimal  "a_position",        precision: 13, scale: 3
    t.decimal  "d_position",        precision: 13, scale: 3
    t.decimal  "h_threshold",       precision: 13, scale: 3
    t.decimal  "a_threshold",       precision: 13, scale: 3
    t.decimal  "d_threshold",       precision: 13, scale: 3
    t.decimal  "h_distance",        precision: 13, scale: 3
    t.decimal  "a_distance",        precision: 13, scale: 3
    t.decimal  "d_distance",        precision: 13, scale: 3
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "user_id"
  end

  create_table "log_pushes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "ot_type"
    t.string   "action"
    t.text     "log",           limit: 16777215
    t.string   "tx_offer_id"
    t.integer  "tx_match_id"
    t.text     "data",          limit: 65535
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.integer  "ot"
    t.decimal  "head",                           precision: 7, scale: 4
    t.string   "ot_name"
    t.decimal  "h_oppo",                         precision: 7, scale: 4
    t.decimal  "a_oppo",                         precision: 7, scale: 4
    t.decimal  "d_oppo",                         precision: 7, scale: 4
    t.integer  "book_maker_id"
    t.text     "tx_offer",      limit: 65535
    t.text     "tx_match",      limit: 65535
    t.string   "tx_timestamp"
    t.boolean  "has_error",                                              default: false
    t.string   "event"
    t.string   "uuid"
    t.string   "afu_timestamp"
    t.index ["action"], name: "index_log_pushes_on_action", using: :btree
    t.index ["book_maker_id"], name: "index_log_pushes_on_book_maker_id", using: :btree
    t.index ["event"], name: "index_log_pushes_on_event", using: :btree
    t.index ["has_error"], name: "index_log_pushes_on_has_error", using: :btree
    t.index ["ot_name"], name: "index_log_pushes_on_ot_name", using: :btree
    t.index ["tx_match_id"], name: "index_log_pushes_on_tx_match_id", using: :btree
    t.index ["uuid"], name: "index_log_pushes_on_uuid", using: :btree
  end

  create_table "match_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "match_id"
    t.integer  "h_score"
    t.integer  "a_score"
    t.datetime "received_at"
    t.datetime "match_time"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "matches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "start_time"
    t.string   "leader"
    t.integer  "leader_id"
    t.integer  "hteam_id"
    t.integer  "ateam_id"
    t.integer  "category_id"
    t.boolean  "active",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "halves"
    t.integer  "h_score",       default: 0
    t.integer  "a_score",       default: 0
    t.string   "result"
    t.integer  "book_maker_id"
    t.string   "redis_id"
    t.boolean  "is_running",    default: false
    t.string   "stat"
    t.integer  "group_id"
    t.boolean  "available",     default: false
    t.index ["active"], name: "index_matches_on_active", using: :btree
    t.index ["book_maker_id"], name: "index_matches_on_book_maker_id", using: :btree
    t.index ["category_id"], name: "index_matches_on_category_id", using: :btree
    t.index ["group_id"], name: "index_matches_on_group_id", using: :btree
    t.index ["leader", "leader_id", "book_maker_id", "halves"], name: "match_leader_book_maker_index", unique: true, using: :btree
    t.index ["leader"], name: "index_matches_on_leader", using: :btree
    t.index ["leader_id"], name: "index_matches_on_leader_id", using: :btree
    t.index ["redis_id"], name: "index_matches_on_redis_id", using: :btree
  end

  create_table "offer_asians", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.integer  "offer_id"
    t.decimal  "h_odd",             precision: 7, scale: 4, default: "0.0"
    t.decimal  "a_odd",             precision: 7, scale: 4, default: "0.0"
    t.decimal  "h_modifier",        precision: 7, scale: 4, default: "0.0"
    t.decimal  "a_modifier",        precision: 7, scale: 4, default: "0.0"
    t.integer  "asian_proportion"
    t.integer  "asian_head"
    t.decimal  "asian_modifier",    precision: 7, scale: 4, default: "0.0"
    t.integer  "h_stake",                                   default: 0
    t.integer  "a_stake",                                   default: 0
    t.string   "handicapped_team"
    t.string   "asia_format"
    t.string   "orgin_asia_format"
    t.decimal  "water",             precision: 7, scale: 4, default: "0.0"
    t.boolean  "flag",                                      default: true
    t.string   "flat_head"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.decimal  "running_water",     precision: 6, scale: 3, default: "0.02"
    t.index ["offer_id"], name: "index_offer_asians_on_offer_id", using: :btree
  end

  create_table "offer_parlays", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "offer_id"
    t.string   "name"
    t.decimal  "h_odd",            precision: 7, scale: 4, default: "0.0"
    t.decimal  "a_odd",            precision: 7, scale: 4, default: "0.0"
    t.decimal  "d_odd",            precision: 7, scale: 4, default: "0.0"
    t.decimal  "h_modifier",       precision: 7, scale: 4, default: "0.0"
    t.decimal  "a_modifier",       precision: 7, scale: 4, default: "0.0"
    t.decimal  "d_modifier",       precision: 7, scale: 4, default: "0.0"
    t.string   "handicapped_team"
    t.decimal  "head",             precision: 7, scale: 4, default: "0.0"
    t.integer  "asian_proportion"
    t.integer  "asian_head"
    t.decimal  "asian_modifier",   precision: 7, scale: 4, default: "0.0"
    t.decimal  "water",            precision: 7, scale: 4, default: "0.0"
    t.boolean  "flag",                                     default: true
    t.string   "flat_head"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "match_id"
    t.decimal  "running_water",    precision: 6, scale: 3, default: "0.02"
    t.string   "type_flag"
    t.index ["offer_id"], name: "index_offer_parlays_on_offer_id", using: :btree
  end

  create_table "offer_positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.decimal  "h_position",  precision: 13, scale: 3
    t.decimal  "a_position",  precision: 13, scale: 3
    t.decimal  "d_position",  precision: 13, scale: 3
    t.decimal  "h_distance",  precision: 13, scale: 3
    t.decimal  "a_distance",  precision: 13, scale: 3
    t.decimal  "d_distance",  precision: 13, scale: 3
    t.decimal  "h_threshold", precision: 13, scale: 3
    t.decimal  "a_threshold", precision: 13, scale: 3
    t.decimal  "d_threshold", precision: 13, scale: 3
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "match_id"
    t.string   "offer_name"
  end

  create_table "offer_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_max"
    t.integer  "match_max"
    t.integer  "order_pause_point"
    t.integer  "water"
    t.integer  "leader_entrance"
    t.integer  "h_trigger"
    t.decimal  "h_trigger_percentage",       precision: 10
    t.integer  "h_total_trigger"
    t.decimal  "h_total_trigger_percentage", precision: 10
    t.boolean  "h_pause"
    t.integer  "h_pause_point"
    t.integer  "a_trigger"
    t.decimal  "a_trigger_percentage",       precision: 10
    t.integer  "a_total_trigger"
    t.decimal  "a_total_trigger_percentage", precision: 10
    t.boolean  "a_pause"
    t.integer  "a_pause_point"
    t.integer  "offer_id"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "default",                                   default: false
  end

  create_table "offer_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "name_ch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "api_filter"
    t.string   "offer_name"
    t.boolean  "running"
    t.boolean  "parlay"
  end

  create_table "offers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.decimal  "h_odd",                             precision: 7, scale: 4, default: "0.0"
    t.decimal  "a_odd",                             precision: 7, scale: 4, default: "0.0"
    t.decimal  "h_modifier",                        precision: 7, scale: 4, default: "0.0"
    t.decimal  "a_modifier",                        precision: 7, scale: 4, default: "0.0"
    t.string   "handicapped_team"
    t.decimal  "head",                              precision: 7, scale: 4, default: "0.0"
    t.integer  "asian_proportion"
    t.decimal  "asian_modifier",                    precision: 7, scale: 4, default: "0.0"
    t.string   "leader"
    t.string   "leader_id"
    t.integer  "book_maker_id"
    t.integer  "match_id"
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.integer  "h_stake",                                                   default: 0
    t.integer  "a_stake",                                                   default: 0
    t.decimal  "d_odd",                             precision: 7, scale: 4, default: "0.0"
    t.decimal  "h_oppo",                            precision: 7, scale: 4, default: "0.0"
    t.decimal  "a_oppo",                            precision: 7, scale: 4, default: "0.0"
    t.decimal  "d_oppo",                            precision: 7, scale: 4, default: "0.0"
    t.decimal  "water",                             precision: 7, scale: 4, default: "0.0"
    t.decimal  "d_modifier",                        precision: 7, scale: 4, default: "0.0"
    t.integer  "d_stake",                                                   default: 0
    t.boolean  "flag",                                                      default: true
    t.text     "incoming_request", limit: 16777215
    t.boolean  "is_running",                                                default: false
    t.boolean  "series",                                                    default: true
    t.decimal  "running_water",                     precision: 6, scale: 3, default: "0.02"
    t.string   "stat"
    t.string   "leader_timestamp"
    t.boolean  "flat",                                                      default: false
    t.string   "halves"
    t.integer  "match_leader_id"
    t.integer  "category_id"
    t.index ["flat"], name: "index_offers_on_flat", using: :btree
    t.index ["head", "name", "book_maker_id", "halves", "match_leader_id"], name: "unique_offer_index", unique: true, using: :btree
    t.index ["leader"], name: "index_offers_on_leader", using: :btree
    t.index ["leader_id"], name: "index_offers_on_leader_id", using: :btree
    t.index ["match_id"], name: "index_offers_on_match_id", using: :btree
  end

  create_table "order_ancestors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id",                                   null: false
    t.decimal  "member",            precision: 12, scale: 3
    t.decimal  "agent",             precision: 12, scale: 3
    t.decimal  "general_agent",     precision: 12, scale: 3
    t.decimal  "shareholder",       precision: 12, scale: 3
    t.decimal  "major_shareholder", precision: 12, scale: 3
    t.decimal  "director",          precision: 12, scale: 3
    t.decimal  "supervisor",        precision: 12, scale: 3
    t.decimal  "moderator",         precision: 12, scale: 3
    t.decimal  "admin",             precision: 12, scale: 3
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "result_flag"
    t.string   "sport_name"
  end

  create_table "order_item_profiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_item_id"
    t.string   "hteam_name"
    t.string   "ateam_name"
    t.string   "category_name"
    t.string   "halves"
    t.datetime "match_start_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "order_id"
    t.string   "offer_type"
    t.integer  "offer_id"
    t.decimal  "head",           precision: 6, scale: 3
    t.integer  "proportion"
    t.string   "offer_name",                                             null: false
    t.string   "result_code"
    t.decimal  "odd",            precision: 7, scale: 4, default: "0.0"
    t.string   "result_target"
    t.string   "target"
    t.integer  "match_id"
    t.string   "type_flag"
    t.string   "sport_name"
    t.integer  "sport_id"
    t.integer  "ot_id"
    t.boolean  "vigorish_split"
    t.integer  "category_id"
    t.index ["order_id"], name: "index_order_items_on_order_id", using: :btree
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "time"
    t.string   "ip"
    t.integer  "amount"
    t.integer  "user_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "stake"
    t.boolean  "settle",           default: false
    t.string   "type_flag"
    t.string   "parlay_serial"
    t.integer  "parlay_count"
    t.boolean  "is_valid",         default: true
    t.boolean  "split"
    t.integer  "effective_amount"
    t.integer  "current_quota"
    t.boolean  "vigorish_split"
    t.string   "note"
    t.string   "device"
    t.index ["parlay_serial"], name: "index_orders_on_parlay_serial", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "controller"
    t.string   "channel"
    t.string   "action"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "sports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "leader_spid"
    t.string  "name"
    t.string  "display_name"
    t.boolean "active",       default: false
  end

  create_table "teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "name_cn"
    t.integer  "category_id"
    t.integer  "tx_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["tx_id"], name: "index_teams_on_tx_id", using: :btree
  end

  create_table "total_profits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id",                                   null: false
    t.integer  "user_id"
    t.decimal  "member",            precision: 12, scale: 3
    t.decimal  "agent",             precision: 12, scale: 3
    t.decimal  "general_agent",     precision: 12, scale: 3
    t.decimal  "shareholder",       precision: 12, scale: 3
    t.decimal  "major_shareholder", precision: 12, scale: 3
    t.decimal  "director",          precision: 12, scale: 3
    t.decimal  "supervisor",        precision: 12, scale: 3
    t.decimal  "moderator",         precision: 12, scale: 3
    t.decimal  "admin",             precision: 12, scale: 3
    t.decimal  "unsplit_amount",    precision: 12, scale: 3
    t.string   "result_flag"
    t.string   "sport_name"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.decimal  "total_vigorish",    precision: 12, scale: 3
  end

  create_table "user_allotters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "sport_id"
    t.integer  "user_id"
    t.decimal  "oppo",       precision: 7, scale: 4, default: "0.0"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "name"
    t.string   "name_ch"
  end

  create_table "user_ancestors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",           null: false
    t.integer  "member"
    t.integer  "agent"
    t.integer  "general_agent"
    t.integer  "shareholder"
    t.integer  "major_shareholder"
    t.integer  "director"
    t.integer  "supervisor"
    t.integer  "moderator"
    t.integer  "admin"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "user_profiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "nickname"
    t.string   "note"
    t.decimal  "quota",             precision: 12, scale: 4
    t.integer  "delay_original"
    t.integer  "delay_running"
    t.integer  "parlay"
    t.string   "status"
    t.boolean  "accessable"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "user_id"
    t.decimal  "current_quota",     precision: 12, scale: 4
    t.string   "quota_update_time"
  end

  create_table "user_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "sport_id"
    t.integer  "user_id"
    t.integer  "rebate",      default: 0
    t.integer  "offer_quota", default: 0
    t.integer  "match_quota", default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "name"
    t.string   "otname"
    t.integer  "ot_id"
    t.string   "name_ch"
    t.string   "offer_name"
    t.string   "halves"
    t.integer  "category_id"
    t.index ["user_id"], name: "index_user_settings_on_user_id", using: :btree
  end

  create_table "user_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "content"
    t.string   "reason"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_ancestor_id"
    t.string   "encrypted_password",     default: "",       null: false
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "bank_id"
    t.integer  "tier",                   default: 0
    t.string   "identity",               default: "normal"
    t.integer  "fork_id"
    t.string   "access_token"
    t.boolean  "online",                 default: false
    t.boolean  "is_admin",               default: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "vigorish_ancestors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_item_id"
    t.decimal  "member",            precision: 12, scale: 3
    t.decimal  "agent",             precision: 12, scale: 3
    t.decimal  "general_agent",     precision: 12, scale: 3
    t.decimal  "shareholder",       precision: 12, scale: 3
    t.decimal  "major_shareholder", precision: 12, scale: 3
    t.decimal  "director",          precision: 12, scale: 3
    t.decimal  "supervisor",        precision: 12, scale: 3
    t.decimal  "moderator",         precision: 12, scale: 3
    t.decimal  "admin",             precision: 12, scale: 3
    t.string   "result_flag"
    t.string   "sport_name"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "halves"
    t.integer  "order_id"
    t.decimal  "total_vigorish",    precision: 12, scale: 3
  end

  create_table "vigorish_shares", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id",                                   null: false
    t.integer  "user_id"
    t.decimal  "member",            precision: 12, scale: 3
    t.decimal  "agent",             precision: 12, scale: 3
    t.decimal  "general_agent",     precision: 12, scale: 3
    t.decimal  "shareholder",       precision: 12, scale: 3
    t.decimal  "major_shareholder", precision: 12, scale: 3
    t.decimal  "director",          precision: 12, scale: 3
    t.decimal  "supervisor",        precision: 12, scale: 3
    t.decimal  "moderator",         precision: 12, scale: 3
    t.decimal  "admin",             precision: 12, scale: 3
    t.decimal  "total_vigorish",    precision: 12, scale: 3
    t.string   "result_flag"
    t.string   "sport_name"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

end
