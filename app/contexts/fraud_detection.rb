module FraudDetection
  def self.possible_fraud?(transactions, transaction_to_validate)
    if transactions.empty?
      self.check_lock_and_save(transaction_to_validate)
    else
      return true if too_many_transactions_in_a_row?(transactions, transaction_to_validate)
      return true if exceeds_daily_limit?(transactions, transaction_to_validate)
      return true if had_chargeback_before?(transactions)
    end
  end

  def self.too_many_transactions_in_a_row?(transactions, transaction_to_validate)
    validation_datetime = transaction_to_validate[:transaction_date].to_datetime
    ttl_transc_lock = Rails.configuration.ttl_transc_lock.to_i

    if self.diff_in_seconds(validation_datetime, transactions.first.transaction_date) > ttl_transc_lock
      self.check_lock_and_save(transaction_to_validate)
    else
      true
    end
  end

  def self.exceeds_daily_limit?(transactions, transaction_to_validate)
    validation_datetime = transaction_to_validate[:transaction_date].to_datetime
    transaction_amount = transaction_to_validate[:transaction_amount]

    daily_amount = transactions.reduce(transaction_amount) do |amount, transaction|
      if transaction.transaction_date.between?(
        validation_datetime.beginning_of_day,
        validation_datetime.end_of_day
      )
        amount + transaction.transaction_amount
      else
        amount
      end
    end

    daily_amount > Rails.configuration.daily_limit.to_d
  end

  def self.had_chargeback_before?(transactions)
    transactions.find { |transaction| transaction.has_cbk }
  end

  def self.diff_in_seconds(dt1,dt2)
    ((dt1.to_datetime - dt2.to_datetime) * 24 * 60 * 60).to_i
  end

  def self.check_lock_and_save(transaction)
    locker = Locker.instance
    if locker.locked?(transaction[:user_id])
      true
    else
      Transaction.create!(transaction)
      locker.lock(transaction[:user_id])
      false
    end
  end
end
