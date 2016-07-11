include ProxyHelper
# Proxy model
class Proxy < ApplicationRecord
  def self.mark_proxy_as_good(ip_port)
    proxy = Proxy.find_by_ip_port(ip_port)
    if proxy
      proxy.success_attempts_count += 1
      proxy.total_attempts_count += 1
      proxy.save
    end
    proxy.total_attempts_count
  end

  def self.mark_proxy_as_bad(ip_port)
    proxy = Proxy.find_by_ip_port(ip_port)
    if proxy
      proxy.total_attempts_count += 1
      proxy.save
    end
    proxy.total_attempts_count
  end

  def self.get_list(length)
    count = Proxy.count(:id)
    percent = length / count.to_f * 100
    if percent < 1
      read_list("SELECT id, ip_port FROM proxies TABLESAMPLE BERNOULLI(#{percent}) LIMIT #{length}", length)
    else
      read_list("SELECT id, ip_port FROM proxies ORDER BY RANDOM() LIMIT #{length}", length)
    end
  end

  def self.update
    proxy_list = load_new_proxies.uniq - Proxy.all.pluck(:ip_port)
    Proxy.add_list(proxy_list) if proxy_list.present?
    proxy_list
  end

  private_class_method

  def self.read_list(sql_str, length)
    result = []
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      3.times do
        result += connection.execute(sql_str).as_json.map { |record| record['ip_port'] }
        result.uniq!
        break if result.length >= length
      end
    end
    result[0..length - 1]
  end

  def self.add_list(proxy_list)
    proxies = proxy_list.map { |ip_port| "('#{ip_port}', 0, 0, '#{Time.now}', '#{Time.now}')" }
    columns = %w(ip_port success_attempts_count total_attempts_count updated_at created_at)
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.execute "INSERT INTO proxies (#{columns.join(',')}) VALUES #{proxies.join(',')}"
    end
  end
end
