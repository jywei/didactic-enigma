$(document).ready(function () {
  if (parlay == true) {
    var match_id = $('#match').attr('data-match-id')
    var offer_type = $('.offer').attr('data-type')

    App.player = App.cable.subscriptions.create('Player::MatchesChannel',
      {
        connected: function () {
          console.log('遊戲端已連線')
        },
        received: function (data) {
          console.log(data)
          switch (data.action) {
            case 'odd':
              if (data.team == 'asian') {
                $('.asian').text(data.odd)
              } else {
                $('.' + data.team + '-odd').text(data.odd)
              };
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
      createItems()
      var team = $(this).attr('data-type')
      items = createItems()
      App.player.order({
        amount: parseInt($('#amount').val()),
        prize: parseInt(parseInt($('#amount').val()) * parseFloat($('.' + team + '-odd').text())),
        rate_mode: 'any',
        serial: Math.random().toString(36).substring(7),
        parlay_serial: Math.random().toString(36).substring(7),
        cookie: Cookies.get('user'),
        items: items
      })
    })

    function createItems () {
      var items = []
      var count = 0
      var length = $('.match').length
      $('.match').each(function (i, match) {
        var is_asian = match.getElementsByClassName('offer')[0].childNodes[1].getAttribute('data-asian')
        var team = match.getElementsByClassName('team')[0].getAttribute('data-team')
        items.push({
          match_id: match.getAttribute('data-match-id'),
          team: team,
          offer: match.childNodes[3].getAttribute('data-type'),
          odd: match.getElementsByClassName(team + '-odd')[0].innerText
        })
        if (is_asian == 'true') {
          items[count].asia_proportion = match.getElementsByClassName('head')[0].innerText
        }
        count++
      })
      return items
    }
  };
})
