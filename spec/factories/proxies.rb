FactoryGirl.define do
  factory :proxy do |proxy|
    proxy.ip_port { "#{Faker::Internet.ip_v4_address}:#{Faker::Number.number(4)}" }
    proxy.success_attempts_count { 0 }
    proxy.total_attempts_count { 0 }
  end
end
