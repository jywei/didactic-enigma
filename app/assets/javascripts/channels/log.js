
$(document).ready(function () {
  if (log == true) {
    var ws = new WebSocket('ws://52.192.25.216:30000')

    ws.onopen = function (msg) {
      console.log('Log Server Connected')
    }

    ws.onmessage = function (msg) {
      if (pause == false) {
        log = msg.data
        // log = log.replace("[1m[35m", "<span class='blue'>")
        // log = log.replace("[1m[34m", "</span>")
        $('.backend_log').html(log)
        $('.backend_log').scrollTop($('.backend_log').prop('scrollHeight'))
      };
    }

    ws.onerror = function () {
      $('.backend_log').text('無法與伺服器建立連線')
    }

    var pause = false
    $('.pause').click(function () {
      if (pause == false) {
        pause = true
        $(this).text('繼續')
      } else {
        pause = false
        $(this).text('暫停')
      };
    })

    var type = 'all'
    $('.type').click(function () {
      if (type == 'all') {
        type = 'channels'
        ws.send('type=channels')
        $(this).text('追蹤全部')
      } else {
        type = 'all'
        ws.send('type=all')
        $(this).text('只追蹤WebSocket')
      };
    })

    $('.restart').click(function () {
      $.post('/logs/restart').then(function (res) {
        console.log(res)
        location.reload()
      })
    })
  }
})
