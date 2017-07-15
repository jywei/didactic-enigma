class PushProcessJob < ApplicationJob
  queue_as :push_process

  def perform(args)
    Operation::Odd.new(args).operate!
  end
end
