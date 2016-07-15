render_handlebars_template = (options) ->
  success_status = false
  rendered = HandlebarsTemplates[options.template_file](options.data)
  wait_cover = document.querySelector('.wait-please')
  if wait_cover
    wait_cover.remove()
  document.querySelector('.section--center').innerHTML = rendered

query_data = (options) ->
  url = options.href
  template_file = options.template_file
  nofollow = options.nofollow
  $.map ['href', 'template_file', 'nofollow'], (key) ->
    delete(options[key])
  $.ajax
    url: url
    data: options
    dataType: 'json'
    success: (data) ->
      console.log
        data: data
      render_handlebars_template
        data: data
        template_file: template_file
      unless nofollow
        window.history.pushState({}, options.title, url);
      ready()

set_listener = (options) ->
  $link_button = $(options.selector)
  if $link_button.length > 0
    $link_button.off 'click'
    $link_button.on 'click', (e) ->
      e.stopPropagation()
      e.preventDefault()
      document.querySelector('.mdl-layout__content').innerHTML += '<div class="wait-please"></div>'
      query_data
        href: e.target.getAttribute('href')
        template_file: options.template_file

ready = ->
  set_listener
    selector: '[data-type=brand-link]'
    template_file: 'hamlbars/models/index'
  set_listener
    selector: '[data-type=model-link]'
    template_file: 'hamlbars/models/show'

  $text_search_input = $('#text-search')
  $text_search_input.off 'change'
  $text_search_input.on 'change', (e) ->
    console.log
      search: e.target.value
    query_data
      href: "/search/#{e.target.value}"
      template_file: 'hamlbars/models/index'
      nofollow: true

$(document).on 'ready page:load turbolinks:load', ->
  ready()
