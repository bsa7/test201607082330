include ProxyHelper
class Proxy < ApplicationRecord
  def self.fetch_proxy_list(length = 1)
    proxy_list = get_proxy_list(length)
    if proxy_list.length < length
      proxy_list = update_proxy_list[0..length-1]
    end
    proxy_list
  end

  private

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
    if proxy_list.length > 0
      new_proxies = proxy_list.map { |ip_port| "('#{ip_port}', 0, 0, '#{Time.now}', '#{Time.now}')" }
      column_list = %w(ip_port success_attempts_count total_attempts_count updated_at created_at)
      ActiveRecord::Base.connection.execute <<-SQL
        INSERT INTO proxies (#{column_list.join(', ')})
        VALUES #{new_proxies.join(", ")}
      SQL
    else
      []
    end
    proxy_list
  end
end
