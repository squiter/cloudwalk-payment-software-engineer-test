class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions, id: false do |t|
      t.bigint :transaction_id, index: true
      t.bigint :merchant_id, null: false
      t.bigint :user_id, null: false
      t.string :card_number, null: false, limit: 17
      t.datetime :transaction_date, null: false
      t.bigint :transaction_amount, null: false
      t.bigint :device_id
      t.boolean :has_cbk, default: false

      t.timestamps
    end
  end
end
