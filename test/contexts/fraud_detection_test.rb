require "test_helper"

class FraudDetectionTest < ActiveSupport::TestCase
  test "possible_fraud? returns false when do not have transactions saved" do
    transaction_to_validate = {
      transaction_date: DateTime.now,
      transaction_amount: 0
    }

    assert_not FraudDetection.possible_fraud?([], transaction_to_validate)
  end

  test "possible_fraud? returns true when have something unsafe" do
    transaction_to_validate = {
      transaction_date: DateTime.now,
      user_id: 42,
      transaction_amount: 10.0
    }
    transactions = FactoryBot.create(:transaction, has_cbk: true)

    assert FraudDetection.possible_fraud?([transactions], transaction_to_validate)
  end

  test "too_many_transactions_in_a_row? returns false when don't have transactions saved" do
    transaction_to_validate = {transaction_date: DateTime.now.to_s}
    assert_not FraudDetection.too_many_transactions_in_a_row?([], transaction_to_validate)
  end

  test "too_many_transactions_in_a_row? returns false when don't have much transactions in a row" do
    transaction_to_validate = {transaction_date: DateTime.now.to_s, user_id: 42}

    transactions = FactoryBot.create_list(
      :transaction,
      3,
      user_id: transaction_to_validate[:user_id]
    )

    assert_not FraudDetection.too_many_transactions_in_a_row?(
      transactions,
      transaction_to_validate
    )
  end

  test "too_many_transactions_in_a_row? returns true when do have much transactions in a row" do
    transactions_in_a_row_limit = 10
    transaction_to_validate = {transaction_date: DateTime.now.to_s, user_id: 42}

    transactions = FactoryBot.create_list(
      :transaction,
      transactions_in_a_row_limit + 1,
      transaction_date: DateTime.now,
      user_id: transaction_to_validate[:user_id]
    )

    assert FraudDetection.too_many_transactions_in_a_row?(
      transactions,
      transaction_to_validate
    )
  end

  test "exceeds_daily_limit? returns false when don't have transactions saved" do
    daily_limit = 10_000.0
    transaction_to_validate = {
      user_id: 42,
      transaction_date: DateTime.now,
      transaction_amount: daily_limit - 1
    }

    assert_not FraudDetection.exceeds_daily_limit?([], transaction_to_validate)
  end

  test "exceeds_daily_limit? returns true when transaction_to_validate exceeds the limit" do
    daily_limit = 10_000.0
    transaction_to_validate = {
      user_id: 42,
      transaction_date: DateTime.now,
      transaction_amount: daily_limit + 1
    }

    assert FraudDetection.exceeds_daily_limit?([], transaction_to_validate)
  end

  test "exceeds_daily_limit? returns false when the amount of daily transactions is safe" do
    transaction_to_validate = {
      user_id: 42,
      transaction_date: DateTime.now,
      transaction_amount: 1
    }

    transactions = FactoryBot.create_list(
      :transaction,
      10,
      user_id: transaction_to_validate[:user_id]
    )

    assert_not FraudDetection.exceeds_daily_limit?(transactions, transaction_to_validate)
  end

  test "exceeds_daily_limit? returns true when the amount of daily transactions is unsafe" do
    transaction_to_validate = {
      user_id: 42,
      transaction_date: DateTime.now,
      transaction_amount: 1_000
    }

    transactions = FactoryBot.create_list(
      :transaction,
      10,
      transaction_amount: 1_000,
      user_id: transaction_to_validate[:user_id]
    )

    assert FraudDetection.exceeds_daily_limit?(transactions, transaction_to_validate)
  end

  test "had_chargeback_before? returns false when don't have transactions saved" do
    assert_not FraudDetection.had_chargeback_before?([])
  end

  test "had_chargeback_before? returns false when don't have chargeback in the saved transactions" do
    transactions = FactoryBot.create_list(:transaction, 2, has_cbk: false)
    assert_not FraudDetection.had_chargeback_before?(transactions)
  end

  test "had_chargeback_before? returns true when do have chargeback in the saved transactions" do
    transactions = FactoryBot.create_list(:transaction, 2, has_cbk: true)
    assert FraudDetection.had_chargeback_before?(transactions)
  end
end
