class CreateProxies < ActiveRecord::Migration[5.0]
  def change
    create_table :proxies do |t|
      t.string :ip_port
      t.integer :success_attempts_count
      t.integer :total_attempts_count

      t.timestamps
    end
    add_index :proxies, :success_attempts_count
    add_index :proxies, :total_attempts_count
  end
end
