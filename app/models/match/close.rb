# 關盤相關
module Match::Close
  # 在把關盤行為include至 Match 後，會一併提供兩個關盤的class method：close!和unlink_redis
  def self.included(klass)
    # 把所有where出來的match都關盤，關盤動作包含：
    #
    # 1. 更新部位
    # 2. 把redis裡面的cache資料刪除
    # 3. 把active欄位改為false
    #
    def klass.close!
      matches = all
      Match.transaction do
        matches.update_positions
        matches.unlink_redis
        matches.update_all(active: false)
      end
    end

    # 把match在redis內的cache資料刪除
    def klass.unlink_redis
      match_keys = all.map(&:key)
      $redis.db.hdel($matches_key,  match_keys)
      $redis.db.hdel($matches_ref,  match_keys)
      $redis.db.hdel($matches_lock, all.map {|m| m.leader_id.to_s})
      $redis.db.hdel($matches_lock, all.ids)
    end
  end

  # 單一場次關盤，做的事情跟 Match::Close.close! 一樣
  def close!
    Match.transaction do
      update_positions
      update_column(:active, false)
    end
    unlink_redis
  end

  # 把單一match在redis內的cache資料刪除
  def unlink_redis
    $redis.db.hdel($matches_key,  key)
    $redis.db.hdel($matches_ref,  key)
    $redis.db.hdel($matches_lock, leader_id)
    $redis.db.hdel($matches_lock, id)
  end
end
