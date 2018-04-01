Sequel.migration do
  change do
    create_table :users do |t|
      primary_key :id, :bigserial

      String :screen_name, null: false
      Integer :followers_count, null: false
      Integer :friends_count, null: false
    end

    create_table :tweets do |t|
      primary_key :id, :bigserial
      foreign_key :user_id, :users, type: :bigint, null: false, index: :true, on_delete: :cascade

      String :text, null: false
      Integer :retweet_count, null: false
      Integer :favorite_count, null: false

      timestamptz :created_at, null: false
    end

    create_table :hashtags do |t|
      foreign_key :tweet_id, :tweets, type: :bigint, null: false, index: :true, on_delete: :cascade
      String :tag, null: false
    end

    add_index :hashtags, %i(tweet_id tag), unique: true
  end
end
