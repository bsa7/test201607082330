render_model_list_template = (data) ->
  model_list_template = 'hamlbars/brands/show'
  success_status = false
  rendered = HandlebarsTemplates[model_list_template](data)
  document.querySelector('.section--center').innerHTML = rendered

query_data = (options) ->
  url = options.href
  delete(options['href'])
  $.ajax
    url: url
    data: options
    dataType: 'json'
    success: (data) ->
      render_model_list_template data
      window.history.pushState({}, options.title, url);

$(document).on 'ready page:load', ->
  $brand_link_button = $('[data-type=brand-link]')
  if $brand_link_button.length > 0
    $brand_link_button.off 'click'
    $brand_link_button.on 'click', (e) ->
      e.stopPropagation()
      e.preventDefault()
      query_data
        href: e.target.getAttribute('href')
        title: $(e.target).data('name')
