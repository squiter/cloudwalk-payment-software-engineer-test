module FraudDetection
  def self.possible_fraud?(transactions, transaction_to_validate)
    return true if too_many_transactions_in_a_row?(transactions, transaction_to_validate)
    return true if exceeds_daily_limit?(transactions, transaction_to_validate)
    return true if had_chargeback_before?(transactions)
    return false
  end

  def self.too_many_transactions_in_a_row?(transactions, transaction_to_validate)
    validation_datetime = transaction_to_validate[:transaction_date].to_datetime

    transactions_in_a_row = transactions.select do |transaction|
      transaction.transaction_date.between?(
        validation_datetime - 10.minutes,
        validation_datetime + 10.minutes
      )
    end

    transactions_in_a_row.count > 10
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

    daily_amount > 10_000.0
  end

  def self.had_chargeback_before?(transactions)
    transactions.find { |transaction| transaction.has_cbk }
  end
end
