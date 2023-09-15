# Enumerated File Store

<div align="center">

[![Gem Version](https://badge.fury.io/rb/prometheus_enumerated_store.svg)](https://rubygems.org/gems/prometheus_enumerated_store)
[![Gem](https://img.shields.io/gem/dt/prometheus_enumerated_store.svg)](https://rubygems.org/gems/prometheus_enumerated_store/versions)
[![YARD](https://badgen.net/badge/YARD/doc/blue)](http://www.rubydoc.info/gems/prometheus_enumerated_store)


[![coverage](https://lysander.rnds.pro/api/v1/badges/enumerated_coverage.svg)](https://lysander.rnds.pro/api/v1/badges/enumerated_coverage.html)
[![quality](https://lysander.rnds.pro/api/v1/badges/enumerated_quality.svg)](https://lysander.rnds.pro/api/v1/badges/enumerated_quality.html)
[![outdated](https://lysander.rnds.pro/api/v1/badges/enumerated_outdated.svg)](https://lysander.rnds.pro/api/v1/badges/enumerated_outdated.html)
[![vulnerable](https://lysander.rnds.pro/api/v1/badges/enumerated_vuln.svg)](https://lysander.rnds.pro/api/v1/badges/enumerated_vuln.html)

</div>

`Enumerated File Store` - это гем для реализации [специального Data Store](https://github.com/prometheus/client_ruby#data-stores) для библиотеки [prometheus-client](https://github.com/prometheus/client_ruby).

Данная библиотека решает [проблему огромного числа файлов-метрик](https://github.com/prometheus/client_ruby/issues/143) при использовании стандартного [DirectFileStore](https://github.com/prometheus/client_ruby#directfilestore-caveats-and-things-to-keep-in-mind)

---

`Enumerated File Store` provides [custom Data Store](https://github.com/prometheus/client_ruby#data-stores) for [prometheus-client](https://github.com/prometheus/client_ruby) library.

It fixes issue with [too many files for long running applications](https://github.com/prometheus/client_ruby/issues/143) when using [DirectFileStore](https://github.com/prometheus/client_ruby#directfilestore-caveats-and-things-to-keep-in-mind).

<div align="left">
  <a href="https://rnds.pro/" >
    <img src="https://library.rnds.pro/repository/public-blob/logo/RNDS.svg" alt="Supported by RNDSOFT"  height="60">
  </a>
</div>

## Возможности / Features

Библиотека использует последовательное присвоение номеров файлам метрик вместо использования PID / It uses sequential numbering for metric filenames instead of PID-stamps.


## Начало работы / Getting started

```sh
gem install prometheus-enumerated-store
```

При установке `prometheus_enumerated_store` через bundler добавьте следующую строку в `Gemfile`:

---

If you'd rather install `prometheus_enumerated_store` using bundler, add a line for it in your `Gemfile`:

```sh
gem 'prometheus_enumerated_store'
```

Затем выполните / Then run:

```sh
bundle install # для установки гема / gem installation

```
## Использование / Usage

Для использования необходимо в каком-нибудь файле `config/initializers/` настроить `Data Store` для библиотеки `prometheus-client`:

---

Now you need to set `Data Store` for `prometheus-client` gem somewhere in  `config/initializers/`:


```ruby
Prometheus::Client.config.data_store = Prometheus::Enumerated::Store.new(dir: Rails.root.join('tmp', 'prometheus_metrics'))

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |_forked|
    Prometheus::Client.config.data_store.reset
  end
end


# Or somewhere in Pum config if any:

on_restart do
  Prometheus::Client.config.data_store.reset
end

on_worker_boot do
  Prometheus::Client.config.data_store.reset
end
```

## Лицензия / License

Библиотека доступна с открытым исходным кодом в соответствии с условиями [лицензии MIT](./LICENSE).

---

The gem is available as open source under the terms of the [MIT License](./LICENSE).

