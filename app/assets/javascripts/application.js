// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// = require jquery
// = require jquery_ujs
// = require_tree .

// 確認 afu/backend/app/assets/javascripts/action_cable.js 已載入
var App = {}
var host = 'ws://' + window.location.hostname + ':3000/api/v1/channels'
App.cable = ActionCable.createConsumer(host)

$(document).ready(function () {
  App.general = App.cable.subscriptions.create('GeneralChannel',
    {
      connected: function () {
        console.log('總頻道已連線')
      },
      received: function (data) {
        console.log(data)
        if (data.code == 1) {
          $.cookie('user', JSON.stringify(data.data.token))
          location.reload()
        };
        if (data.action == 'invalid_token') {
          alert('token過期')
          window.location.href = '/cookies/reset'
        };
      },
      sign_in: function (args) {
        this.perform('sign_in', args)
      },
      sign_out: function (args) {
        this.perform('sign_out', args)
      },
      update_status: function (args) {
        this.perform('update_status', args)
      }
    }
  )

  $('.sign-in').click(function () {
    var username = $('.username').val()
    var password = $('.password').val()
    App.general.sign_in({
      username: username,
      password: password
    })
  })

  $('.sign-out').click(function () {
    App.general.sign_out({})
    var r = setTimeout(function () {
      window.location.href = '/cookies/reset'
    }, 500)
  })

  $('.update').click(function () {
    App.general.update_status({
      token: JSON.parse($.cookie('user')),
      pass: true
    })
  })
})
