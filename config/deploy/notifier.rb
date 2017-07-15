require 'slack-notifier'
notifier = Slack::Notifier.new("https://hooks.slack.com/services/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")
notifier.ping("AFU正式機佈署中 (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})")
