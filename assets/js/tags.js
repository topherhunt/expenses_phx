import $ from 'jquery'

$(function(){
  $('.js-set-color-preview').keyup(function(e){
    let color = e.target.value
    if (color.match(/^[\w\d]{6}$/)) {
      $('.js-color-preview').css('background-color', '#'+color);
    } else {
      $('.js-color-preview').css('background-color', '#eeeeee');
    }
  })

  $('.js-set-color-preview').keyup()

  $('.js-set-tag-color').click(function(e){
    e.preventDefault()
    $('#tag_color').val($(this).data('color'))
    $('#tag_color').keyup()
  })
})
