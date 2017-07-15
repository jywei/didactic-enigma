# WebSocket API 概覽

專案使用ActionCable作為WebSocket套件，連線路徑：

```
"/api/v1/channels"
```

## Base

- [ApplicationCable::Connection](/rdoc/ApplicationCable/Connection.html)
- [ApplicationCable::Channel](/rdoc/ApplicationCable/Channel.html)

## 所有頻道

- [GeneralChannel](/rdoc/GeneralChannel.html)
- [MatchesChannel](/rdoc/MatchesChannel.html)
- [OrdersChannel](/rdoc/OrdersChannel.html)
- [PositionsChannel](/rdoc/PositionsChannel.html)
- [Player::MatchesChannel](/rdoc/Player/MatchesChannel.html)

## ActionCable教學文章

- [Rails Guide](http://edgeguides.rubyonrails.org/action_cable_overview.html)
- [SitePoint](https://www.sitepoint.com/action-cable-and-websockets-an-in-depth-tutorial/)

## 使用範例

例如要與[GeneralChannel](/rdoc/GeneralChannel.html)建立連線，完整範例如下：

```ruby
var App     = {};
var host    = "ws://" + window.location.hostname + ":3000/api/v1/channels";
App.cable   = ActionCable.createConsumer(host);

App.general = App.cable.subscriptions.create("GeneralChannel",
  {
    connected: function(){
      console.log("已連線");
    },
    received: function(data){
      console.log(data);
    },
    sign_in: function(args){
      this.perform('sign_in', args);
    },
    sign_out: function(args){
      this.perform('sign_out', args);
    }
  }
)
```

有了這樣的宣告後，就可以於其他地方傳送訊息給server：

```ruby
$(".sign-in").click(function(){
  var username = $(".username").val();
  var password = $(".password").val();
  App.general.sign_in({
    username: username,
    password: password
  });
```

