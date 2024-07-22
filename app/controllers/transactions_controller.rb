class TransactionsController < ActionController::Base
  rescue_from ActionController::UnpermittedParameters, with: :handle_unpermitted_parms

  def check
    to_check = transaction_params

    transactions = Transaction.where(user_id: to_check[:user_id]).order(:transaction_date)

    if has_required_params?(to_check)
      render json: build_response(
        to_check[:transaction_id],
        FraudDetection.possible_fraud?(transactions, to_check) ? "deny" : "approve"
      )
    else
      render json: { "error": "Missing required params" },
        status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      :transaction_id,
      :merchant_id,
      :user_id,
      :card_number,
      :transaction_date,
      :transaction_amount,
      :device_id
    )
  end

  def has_required_params?(params)
    %i[
       transaction_id
       user_id
       transaction_date
       transaction_amount
      ].all? { |attr| params.key?(attr) }
  end

  def build_response(id, recommendation)
    {
      "transaction_id": id,
      "recommendation": recommendation
    }
  end

  def handle_unpermitted_parms
    render json: { "error": "Unpermitted Parameters Found" }, status: :unprocessable_entity
  end
end
