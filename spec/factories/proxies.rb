FactoryGirl.define do
  factory :proxy do
    ip_port '1.2.3.4:1122'
    success_attempts_count 1
    total_attempts_count 1
  end
end
