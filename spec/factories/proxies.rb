FactoryGirl.define do
  factory :proxy do
    ip_port "#{Faker::Internet.ip_v4_address}:#{Faker::Number.number(4)}"
    success_attempts_count 0
    total_attempts_count 0
  end
end
