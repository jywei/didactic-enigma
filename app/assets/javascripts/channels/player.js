$(document).ready(function () {
  if (player == true) {
    var match_id = $('#match').attr('data-match-id')
    var offer_type = $('.offer').attr('data-type')

    App.player = App.cable.subscriptions.create('Player::MatchesChannel',
      {
        connected: function () {
          console.log('遊戲端已連線')
        },
        received: function (data) {
          console.log(data)
          if (data.match_id != match_id) {
            return
          } else {
            console.log('Taking action.')
          }
          switch (data.action) {
            case 'odd_manual_change':
              $('.' + data.team + '-odd').text(data.odd)
              $('.' + data.team + '-parlay-odd').text(data.parlay_odd)
              break
          };
        },
          // afu API: 下注
        order: function (args) {
          this.perform('order', args)
        }
      }
        )

    $('.order').click(function () {
      var team = $(this).attr('data-type')
      App.player.order({
        amount: parseInt($('#amount').val()),
        prize: parseInt(parseInt($('#amount').val()) * parseFloat($('.' + team + '-odd').text())),
        serial: Math.random().toString(36).substring(7),
        cookie: Cookies.get('user'),
        rate_mode: 'normal',
        items: [
          {
            match_id: match_id,
            team: team, // 'h', 'a', 'd'
            offer: offer_type,
            odd: (parseFloat($('.' + team + '-odd').text()) + parseFloat($('.' + team + '-modifier').text()))
          }
        ]
      })
    })
  };
})
