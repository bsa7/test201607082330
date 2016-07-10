include ProxyHelper
# Proxy model
class Proxy < ApplicationRecord
  def self.fetch_proxy_list(length = 1)
    proxy_list = get_proxy_list(length)
    proxy_list = update_proxy_list[0..length - 1] if proxy_list.length < length
    proxy_list
  end

  private_class_method

  def self.get_proxy_list(length)
    sql_str = <<-SQL
      SELECT
        id,
        ip_port
      FROM proxies TABLESAMPLE BERNOULLI(100)
      LIMIT #{length}
    SQL
    ActiveRecord::Base.connection.execute(sql_str).as_json.map { |record| record['ip_port'] }
  end

  def self.update_proxy_list
    proxy_list = load_new_proxies.uniq - Proxy.all.pluck(:ip_port)
    if proxy_list.present?
      proxies = proxy_list.map { |ip_port| "('#{ip_port}', 0, 0, '#{Time.now}', '#{Time.now}')" }
      columns = %w(ip_port success_attempts_count total_attempts_count updated_at created_at)
      ActiveRecord::Base.connection.execute "INSERT INTO proxies (#{columns.join(',')}) VALUES #{proxies.join(',')}"
    else
      []
    end
    proxy_list
  end
end
