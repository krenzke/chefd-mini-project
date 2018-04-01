require 'sequel'

DB ||= Sequel.connect(ENV['DATABASE_URL'])

class Store
  attr_accessor :input_queue

  def self.last_id
    DB[:tweets].max(:id)
  end

  def initialize(input_queue)
    @input_queue = input_queue
  end

  def run
    while true
      data = input_queue.pop
      DB.transaction do
        DB[:users].insert_ignore.insert(data[:user])
        DB[:tweets].insert_ignore.insert(data[:tweet])
        DB[:hashtags].insert_ignore.multi_insert(data[:hashtags])
      end
    end
  end
end
