class TransactionsController < ActionController::Base
  rescue_from ActionController::UnpermittedParameters, with: :handle_unpermitted_parms

  def check
    transaction_params.inspect
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

  def handle_unpermitted_parms
    render json: { "error": "Unpermitted Parameters Found" }, status: :unprocessable_entity
  end
end
