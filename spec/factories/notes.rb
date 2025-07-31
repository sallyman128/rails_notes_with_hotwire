FactoryBot.define do
  factory :note do
    title { Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 2) }
    content { Faker::Lorem.paragraph(sentence_count: 5, supplemental: false, random_sentences_to_add: 3) }
    association :user

    trait :with_long_content do
      content { Faker::Lorem.paragraphs(number: 3, supplemental: false).join("\n\n") }
    end

    trait :with_short_title do
      title { Faker::Lorem.word }
    end

    trait :with_long_title do
      title { Faker::Lorem.sentence(word_count: 10, supplemental: false, random_words_to_add: 5) }
    end
  end
end 