require 'test_helper'

class Worker::Runner::BroadcastTest < ActiveSupport::TestCase
  def setup
  end

  def data(match_id = "12081430_3785026_67_1", offer_name = "ou", h_odd = 0.961)
    {
      channel: "Channel",
      data: {
        _match_id:        "378502667",
        _halves_match_id: "12081430_3785026_67_1",
        match_id:         match_id,
        offer:            offer_name,
        h_odd:            h_odd,
        a_odd:            0.961,
        d_odd:            0.0,
        last_updated:     1481195029396,
        action:           "odd_base"
      }
    }
  end

  def test_broadcast_success
    1.times { ActionCable.server.expects(:broadcast) }
    1.times { Worker::Runner::Broadcast.run_by_env(data) }
  end

  # def test_broadcast_block
  #   1.times { ActionCable.server.expects(:broadcast) }
  #   2.times { Worker::Runner::Broadcast.run_by_env(data) }
  # end

  def test_broadcast_different_match_does_not_block
    2.times { ActionCable.server.expects(:broadcast) }
    d = data("123456")
    Worker::Runner::Broadcast.run_by_env(d)
    d = data("445533")
    Worker::Runner::Broadcast.run_by_env(d)
  end

  def test_broadcast_different_offer_does_not_block
    2.times { ActionCable.server.expects(:broadcast) }
    d = data("123456", "point")
    Worker::Runner::Broadcast.run_by_env(d)
    d = data("123456", "ou")
    Worker::Runner::Broadcast.run_by_env(d)
  end

  def test_broadcast_different_odd_does_not_block
    2.times { ActionCable.server.expects(:broadcast) }
    d = data("123456", "point", 0.933)
    Worker::Runner::Broadcast.run_by_env(d)
    d = data("123456", "point", 0.922)
    Worker::Runner::Broadcast.run_by_env(d)
  end

end
