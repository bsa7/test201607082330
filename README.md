Test 20160708
=============

## Briefing

Нужно создать и деплойнуть на хероку приложение, которое из себя будет представлять 1 страницу.
На странице 2 блока:

Первый блок — выбор телефона по бренду/модели.
Первый селект — бренды отсюда: http://www.gsmarena.com/
После выбора бренда в первом селекте, появляется второй селект со списком телефонов бренда на сайте gsmarena, например, для эппла:
http://www.gsmarena.com/apple-phones-48.php
При выборе телефона во втором селекте на странице появляется спарсенная инфа со страницы конкретного телефона:
http://www.gsmarena.com/apple_iphone_6s_plus-7243.php

Второй блок — поиск по строке.
В поле для ввода можно ввести что угодно. Система должна попытаться найти такой телефон на сайте gsm арены и выдать результат / результаты.

Работать должно без перезагрузки страницы, jquery или ангуляр, на ваш выбор.
У нас на проекте точечно используется ангуляр, так что его знание будет плюсом.

Приложение не должно использовать базу данных — парсинг страниц сайта gsmarena следует производить непосредственно в момент выполнения операций в тестовом приложении. Список брендов телефонов в первом селекте первого блока можно захардкодить.

Необходимо также предусмотреть возможность расширения системы в будущем (добавление новых сайтов для парсинга, например).

## Code Status (master branch)

[![Build Status](https://travis-ci.org/r72cccp/test201607082330.svg?branch=master)](https://travis-ci.org/r72cccp/test201607082330)
[![Code Climate](https://codeclimate.com/github/r72cccp/test201607082330/badges/gpa.svg)](https://codeclimate.com/github/r72cccp/test201607082330)
[![Test Coverage](https://codeclimate.com/github/r72cccp/test201607082330/badges/coverage.svg)](https://codeclimate.com/github/r72cccp/test201607082330/coverage)
[![Issue Count](https://codeclimate.com/github/r72cccp/test201607082330/badges/issue_count.svg)](https://codeclimate.com/github/r72cccp/test201607082330)
[![CircleCI](https://circleci.com/gh/r72cccp/test201607082330.svg?style=svg)](https://circleci.com/gh/r72cccp/test201607082330)
[![codebeat badge](https://codebeat.co/badges/371ccf89-7f44-493d-bb74-185ee6fa2f20)](https://codebeat.co/projects/github-com-r72cccp-test201607082330)

## Visit this app on Heroku

[https://test201607082330.herokuapp.com/brands](https://test201607082330.herokuapp.com/brands)

## RDoc

[http://test201607082330.исчо.рф/doc/](http://test201607082330.xn--h1amiy.xn--p1ai/doc/)
