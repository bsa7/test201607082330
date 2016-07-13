include ProxyHelper
# Proxy model
class Proxy < ApplicationRecord
  def self.get_list(length)
    count = Proxy.count(:id)
    percent = length / count.to_f * 100
    if percent < 1
      read_list("SELECT id, ip_port FROM proxies TABLESAMPLE BERNOULLI(#{[percent * 2, 100].min}) LIMIT #{length}")
    else
      read_list("SELECT id, ip_port FROM proxies ORDER BY RANDOM() LIMIT #{length}")
    end
  end

  def self.mark_as(options)
    proxy = Proxy.find_by_ip_port(options[:ip_port])
    if proxy
      proxy.success_attempts_count += 1 if options[:state] == :good
      proxy.total_attempts_count += 1
      proxy.save
    end
    proxy.total_attempts_count
  end

  def self.mark_all(options)
    return unless options[:proxy_list].length == options[:contents].length
    ActiveRecord::Base.transaction do
      options[:contents].each_with_index do |content, index|
        Proxy.mark_as(ip_port: options[:proxy_list][index], state: content ? :good : :bad)
      end
    end
  end

  def self.update
    proxy_list = load_new_proxies.uniq - Proxy.all.pluck(:ip_port)
    Proxy.add_list(proxy_list) if proxy_list.present?
    proxy_list
  end

  private_class_method

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
