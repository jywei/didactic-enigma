$(document).ready(function () {
  if (order == true) {
    var match_id = $('#match').attr('data-match-id')
    var offer_type = $('.offer').attr('data-type')
    App.positions = App.cable.subscriptions.create('OrdersChannel',
      {
        connected: function () {
          console.log('近期訂單已連線')
        },
        received: function (data) {
          console.log(data)
          appendNewOrder(data)
        },
        test: function (args) {
          this.perform('test', args)
        }
      }
    )

    function appendNewOrder (data) {
      var items = ''
      $.each(data.items, function (key, value) {
        items += '<p>場次' + value.id + '，下注隊伍' + value.team + '，賠率 ' + value.odd + '，金額 ' + value.amount + '</p>'
      })
      var result =
          '<tr><td>' + data.id + '</td>' +
          '<td>' + data.type_flag + '</td>' +
          '<td>' + data.offer_type + '</td>' +
          '<td>' + data.sport + '</td>' +
          '<td>' + data.order_time + '</td>' +
          '<td>' + data.account.username + '</td>' +
          '<td>' + data.ip + '</td>' +
          '<td>' + data.price + '</td>' +
          '<td>' + items + '</td></tr>'
      $(result).insertBefore('table > tbody > tr:first')
    }
  };
})
