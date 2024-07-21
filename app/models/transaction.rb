class Transaction < ApplicationRecord
  def self.lock
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute('LOCK transactions IN ACCESS EXCLUSIVE MODE')
      yield
    end
  end
end
