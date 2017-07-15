$(document).ready(function () {
  $('#broadcast').click(function () {
    var args = {}
    columns = [
      'channel',
      '_match_id',
      '_halves_match_id',
      'offer',
      'h_odd',
      'a_odd',
      'd_odd',
      'parlay_h_odd',
      'parlay_a_odd',
      'parlay_d_odd',
      'last_updated',
      'channel_action',
      'handicapped-head',
      'handicapped-proportion',
      'handicapped-modifier'
    ]
    for (var i = 0, l = columns.length; i < l; i++) {
      var v = columns[i]
      args[v] = $('#' + v).val()
    }
    $.post('/broadcast', args)
    $('#ok').css('opacity', 1)
    setTimeout(function () {
      $('#ok').css('opacity', 0)
    }, 500)
  })
})
