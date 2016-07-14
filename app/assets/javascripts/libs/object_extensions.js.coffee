'use strict'
TestApp.Lib || {}
TestApp.Lib.ObjectExtensions = class ObjectExtensions

  constructor: (@options = {}) ->
    @name = 'object extensions'
    return

  # private

  hasOwnProperty = Object::hasOwnProperty
  propIsEnumerable = Object::propertyIsEnumerable

  isObj = (entity) ->
    (entity == null) || (entity && typeof entity == 'object')

  toObject = (value) ->
    if value == null || value == undefined
      throw new TypeError('Sources musts be defined!')
    Object(value)

  assignKey = (to, from, key) ->
    value = from[key]
    if value == undefined || value == null
      return
    if hasOwnProperty.call(to, key)
      if to[key] == undefined || to[key] == null
        throw new TypeError "Can't convert undefined or null to object (#{key})"
    if !hasOwnProperty.call(to, key) || !isObj(value)
      to[key] = value
    else
      to[key] = assign(Object(to[key]), from[key])
    return

  assign = (to, from) ->
    if to == from
      return to
    from = Object(from)
    for key of from
      if hasOwnProperty.call(from, key)
        assignKey(to, from, key)
    if Object.getOwnPropertySymbols
      symbols = Object.getOwnPropertySymbols(from)
      i = 0
      while i < symbols.length
        if propIsEnumerable.call(from, symbols[i])
          assignKey(to, from, symbols[i])
        i++
    to

  # public

  # Клонирование объектов
  clone_object: (object) ->
    JSON.parse(JSON.stringify(object))

  # Рекурсивное слияние двух ассоциативных массивов
  deep_assign: (target) ->
    target = toObject(JSON.parse(JSON.stringify(target)))
    s = 1
    while s < arguments.length
      assign(target, arguments[s])
      s++
    target

  # Из url достаёт search и если она есть, превращает в хэш
  url_search_to_hash: (url = null) ->
    unless url
      url = "#{window.location.pathname}#{window.location.search}"
    search_items_hash = {}
    search_str = url.split(/\?/)[1]
    if search_str
      search_str.split(/[&]/).map (item) ->
        item_elements = item.split('=')
        item_key = item_elements[0]
        item_value = item_elements[1]
        search_items_hash[item_key] = item_value
    search_items_hash

  # из хэша генерит полный урл
  hash_to_url: (search_items_hash, path = window.location.pathname) ->
    "#{path.replace(/\?.+$/, '')}?#{decodeURIComponent(getUrlFromHash(search_items_hash))}"

  # Получить значение фильтра в window.location.search или установить его.
  # Если на входе хэш - назначаются фильры и делается переход
  # Если на входе строка - читается фильтр с таким ключом
  window_location_search: (options) ->
    search_items_hash = @url_search_to_hash(window.location.search)
    if typeof(options) == 'string'
      search_items_hash[options]
    else
      for key, value of options
        if value
          search_items_hash[key] = value
        else
          delete search_items_hash[key]
      location_search_string = decodeURIComponent(getUrlFromHash(search_items_hash))
      window.location.search = "?#{location_search_string}"
      null

  # Взвращает значения элементов объекта как массив
  object_values: (object) ->
    Object.keys(object).map (key) ->
      object[key]

  # При смене параметров search делает ajax подмену контента блока content_area_selector
  on_filters_change: (content_area_selector, changes, success_callback = null) ->
    search_hash = @url_search_to_hash(window.location.search)
    $.map changes, (value, key) ->
      search_hash[key] = value
    url = @hash_to_url(search_hash)
    history.pushState('', '', url);
    if success_callback
      $.ajax
        url: url
        data:
          layout: false
        success: (html, status) ->
          if status == 'success'
            element = document.querySelector(content_area_selector)
            element.outerHTML = html
            if success_callback
              success_callback()

  # Возвращает размеры окна браузера
  window_size: ->
    width: $(window).width()
    height: $(window).height()
