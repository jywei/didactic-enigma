$(document).ready(function () {
  $('.search-match-search').click(function () {
    v = $('.search-match-league').val()
    location.href = '/pushes/matches/filter?league_id=' + v
  })
})
