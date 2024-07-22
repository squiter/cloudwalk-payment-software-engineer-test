require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "check returns 422 when missing required attributes" do
    params = {
      transaction: {
        transaction_date: DateTime.now
      }
    }

    post transactions_check_url, params: params, as: :json

    assert_response :unprocessable_entity
    assert_equal "Missing required params", JSON.parse(@response.body)["error"]
  end

  test "check returns 200 and approve when everything goes right" do
    params = {
      transaction: {
        transaction_id: 42,
        merchant_id: 23,
        card_number: "number",
        transaction_date: DateTime.now,
        transaction_amount: 42.0,
        user_id: rand(1..1000)
      }
    }

    post transactions_check_url, params: params, as: :json

    assert_response :success
    assert_equal(
      JSON.parse(@response.body)["transaction_id"],
      params[:transaction][:transaction_id]
    )
    assert_equal JSON.parse(@response.body)["recommendation"], "approve"
  end

  test "check returns 200 and deny when everything goes wrong" do
    params = {
      transaction: {
        transaction_id: 42,
        merchant_id: 23,
        card_number: "number",
        transaction_date: DateTime.now,
        transaction_amount: 42.0,
        user_id: rand(1..1000)
      }
    }

    FactoryBot.create(
      :transaction,
      user_id: params[:transaction][:user_id],
      has_cbk: true
    )

    post transactions_check_url, params: params, as: :json

    assert_response :success
    assert_equal(
      JSON.parse(@response.body)["transaction_id"],
      params[:transaction][:transaction_id]
    )
    assert_equal JSON.parse(@response.body)["recommendation"], "deny"
  end

end
