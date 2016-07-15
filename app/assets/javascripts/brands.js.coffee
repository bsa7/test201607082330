render_handlebars_template = (options) ->
  success_status = false
  rendered = HandlebarsTemplates[options.template_file](options.data)
  document.querySelector('.wait-please').remove()
  document.querySelector('.section--center').innerHTML = rendered

query_data = (options) ->
  url = options.href
  delete(options['href'])
  $.ajax
    url: url
    data: options
    dataType: 'json'
    success: (data) ->
      render_handlebars_template
        data: data
        template_file: options.template_file
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

$(document).on 'ready page:load turbolinks:load', ->
  ready()
