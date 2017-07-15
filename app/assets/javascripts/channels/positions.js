$(document).ready(function () {
  if (position == true) {
    var match_id = $('#match').attr('data-match-id')
    var offer_type = $('.offer').attr('data-type')

    App.positions = App.cable.subscriptions.create('PositionsChannel',
      {
        connected: function () {
          console.log('部位表已連線')
        },
        received: function (data) {
          console.log(data)
        },
        threshold_adjust: function (args) {
          this.perform('threshold_adjust', args)
        }
      }
    )

    $('.threshold').click(function () {
      App.positions.threshold_adjust({
        match_id: match_id,
        offer: offer_type,
        team: 'h',
        threshold: Math.floor(Math.random() * -200),
        cookie: JSON.stringify(decodeURIComponent(document.cookie))
      })
    })
  };
})
