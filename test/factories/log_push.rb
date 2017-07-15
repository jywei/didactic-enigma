FactoryGirl.define do
  factory :log_push, class: Log::Push do
    event                   'offer'
    action                  {%w(update drop).sample}
    book_maker_id           {%w(59 67).sample}
    ot                      {%w(1 2).sample}
    head                    {%w(1.0 2.0).sample.to_f}
    # created_at              '2016-12-30'

    trait :drop do
      action                  'drop'
    end
  end
end
