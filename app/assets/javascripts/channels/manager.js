$(document).ready(function () {
  if (manager == true) {
    var match_id = $('#match').attr('data-match-id')
    var offer_type = $('.offer').attr('data-type')

    // 建立連線和行為模式
    // 指定頻道：MatchesChannel
    App.matches = App.cable.subscriptions.create('MatchesChannel',
      {
          // 預設需要的key
        connected: function () {
          console.log('控盤端已連線')
        },
          // 預設需要的key
          // 從server端接收訊息
        received: function (data) {
          console.log(data)
          if (data.match_id != match_id) {
            return
          } else {
            console.log('Taking action.')
          };
          switch (data.action) {
            case 'odd_manual_change':
              $('.' + data.team + '-modifier').text(data.modifier)
              $('.parlay-' + data.team + '-modifier').text(data.parlay_modifier)
              break
            case 'stat':
              if (data.offer == 'all') {
                $('.all-stat').text(data.stat)
              } else {
                $('.stat').text(data.stat)
              };
              break
            case 'stake':
              $('.match-h-stake').text(data.match_h_stake)
              $('.match-a-stake').text(data.match_a_stake)
              $('.h-stake').text(data.offer_h_stake)
              $('.a-stake').text(data.offer_a_stake)
              break
            case 'update_head':
              $('.h-odd').text(data.h)
              $('.a-odd').text(data.a)
              $('.head').text(data.handicapped.head)
              $('.asian-modifier').text(data.handicapped.proportion)
              break
            case 'match_live':
              if (data.is_running) {
                running = '是'
              } else {
                running = '否'
              };
              $('.match-running').text(running)
              $('.offer-running').text(running)
              break
          };
        },
          // afu API: 送出調整賠率
        odd_adjust: function (args) {
          this.perform('odd_adjust', args)
        },
          // afu API: 送出調整賠率
        stat_change: function (args) {
          this.perform('stat_change', args)
        },
          // afu API: 賭金跳動
        stake_update: function (args) {
          this.perform('stake_update', args)
        },
          // afu API: 球頭跳動
        random_head: function (args) {
          this.perform('random_head', args)
        },
        match_live: function (args) {
          this.perform('match_live', args)
        }
      }
    )

      // API: 修改賠率及亞新盤比例
    $('.modifier').click(function () {
      var modifiers = {
        'h': parseFloat($('.h-modifier').text()),
        'a': parseFloat($('.a-modifier').text()),
        'asian': parseFloat($('.asian-modifier').text())
      }
      var type = $(this).attr('data-type')
      var modifier = $(this).attr('data-modifier')
      modifiers[type] = modifiers[type] + parseFloat(modifier)
      App.matches.odd_adjust({
        match_id: match_id,
        offer: offer_type,
        type: type,
        last_updated: new Date().getTime(),
        modifier: modifiers[type].toFixed(2),
        cookie: Cookies.get('user')
      })
    })

    // API: 停押, 停押 & 恢復
    $('.status').click(function () {
      var offer = $(this).attr('data-offer')
      var stat = $(this).attr('data-stat')
      App.matches.stat_change({
        match_id: match_id,
        offer: offer,
        last_updated: new Date().getTime(),
        // 整場比賽的話offer欄位為'all'，單一的話則為玩法名稱例如'ml', 'point', 'odd_even'等等
        stat: stat,
          // 停押的話stat欄位為'paused'
          // 停盤的話stat欄位為'disabled'
          // 從停押恢復的話stat欄位為'normal'
        cookie: Cookies.get('user')
      })
    })

    // API: 球頭跳動
    $('.random-head').click(function () {
      App.matches.random_head({
        match_id: match_id,
        offer: offer_type
      })
    })

    // API: 金額調整
    $('.stake').click(function () {
      App.matches.stake_update({
        match_id: match_id,
        offer: offer_type
      })
    })

    // 比賽開賽
    $('.match-live').click(function () {
      App.matches.match_live({
        match_id: match_id,
        offer: offer_type,
        is_running: true
      })
    })

    // 調整為比賽尚未開打
    $('.match-unlive').click(function () {
      App.matches.match_live({
        match_id: match_id,
        offer: offer_type,
        is_running: false
      })
    })
  };

  $('.select-category').click(function () {
    $('.categories').show()
  })
})
