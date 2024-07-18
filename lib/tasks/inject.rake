require 'csv'

namespace :data do
  desc "imports data from transactional-sample.csv"
  task inject: :environment do
    filename = "./vendor/transactional-sample.csv"

    parsed_transactions = CSV.read(filename)[1 .. -1].map do |row|
      {
        transaction_id: row[0].to_i,
        merchant_id: row[1].to_i,
        user_id: row[2].to_i,
        card_number: row[3],
        transaction_date: Date.parse(row[4]),
        transaction_amount: row[5].to_d,
        device_id: row.fetch(6,nil),
        has_cbk: row[7] === 'TRUE'
      }
    end

    # ready_transactions = parsed_transactions.map do |transaction|
    #   Transaction.new(transaction)
    # end

    Transaction.insert_all(parsed_transactions)
  end
end
