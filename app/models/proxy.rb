include ProxyHelper
# Proxy model
class Proxy < ApplicationRecord
  # This load array of strings like '123.234.213.132:3221' from Proxy model
  #
  # ==== Attributes
  #
  # * +:length+ - count of proxies
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call thread-safe +read_list+ method for loading proxies from table
  def self.get_list(length)
    count = Proxy.count_of_records
    percent = length / count.to_f * 100
    if percent < 10
      read_list("SELECT id, ip_port FROM proxies TABLESAMPLE BERNOULLI(#{[percent * 4, 100].min}) LIMIT #{length}")
    else
      read_list("SELECT id, ip_port FROM proxies ORDER BY RANDOM() LIMIT #{length}")
    end
  end

  # This mark proxy as good or bad
  #
  # ==== Attributes
  #
  # * *required* +:ip_port+ - string variable for identify proxy
  # * +:state+ - symbol :good or :bad (default)
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * find this proxy in table and increase attempts count. Succes increase if state are :good
  def self.mark_as(options)
    proxy = Proxy.find_by_ip_port(options[:ip_port])
    if proxy
      proxy.success_attempts_count += 1 if options[:state] == :good
      proxy.total_attempts_count += 1
      proxy.save
    end
    proxy.total_attempts_count
  end

  # This update Proxy model with new uniq proxies
  #
  # ==== Attributes
  #
  # * This methon no require attributes
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call +load_new_proxies+ method, compare list with existing proxies
  # * if new proxies are present - add this proxies to Proxy
  def self.update
    proxy_list = load_new_proxies.uniq - Proxy.all.pluck(:ip_port)
    Proxy.add_list(proxy_list) if proxy_list.present?
    proxy_list
  end

  private_class_method

  def self.count_of_records
    count = nil
    ActiveRecord::Base.connection_pool.with_connection do
      count = Proxy.count(:id)
    end
    count
  end

  def self.read_list(sql_str)
    result = []
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      records = connection.execute(sql_str).as_json
      result = records.map { |record| record['ip_port'] }
      result.uniq!
    end
    result
  end

  def self.add_list(proxy_list)
    proxies = proxy_list.map { |ip_port| "('#{ip_port}', 0, 0, '#{Time.current}', '#{Time.current}')" }
    columns = %w(ip_port success_attempts_count total_attempts_count updated_at created_at)
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.execute "INSERT INTO proxies (#{columns.join(',')}) VALUES #{proxies.join(',')}"
    end
  end
end
