# README

The answers for the questions in the part 3 of the hiring test are in the end of this file

## Considerations about the implementation

For this test I decided to build a simple Rails API with PostgreSQL. This Database is used as a cache or temporary data to enable us to define if a transaction should be approved or denied given our fraud detection rules.

### Flexible parameters

Since I don't know exactly some parameters to deny some transactions I decided to use some configurations to make the app more flexible. So, if we need to increase/decrease the daily limit of transactions amount or the time between transactions we could only change some Environment Variables, avoiding a deploy.

To setup those values we just need to export some variables:

```
export CW_TTL_TRANSC_LOCK_IN_SECONDS=600
export CW_DAILY_LIMIT=10000
```

### Dealing with too many requests from an user

In this implementation I used a simple database table lock to control this flow, forcing each query to the database be sequential and comparing the `transaction_date` of the transaction to be validated to be greater than our `ttl_transc_lock` configuration.

That same outcome could be achieved in different ways in production if the team seems fit, for example we could be saving a row at Redis with the `user_id` and a `TTL` equals to our `ttl_transc_lock` and only saving new entries when that key was gone from Redis.

## Up & Running

This project depends on some environment variables, you could use [direnv](https://direnv.net/) and run `direnv allow` or import those envvars manually running: `. .envrc` at the root of the project.

## Data injection

If you need to inject the data from `transactional-samples.csv` you could run: `rake data:inject`

```
curl http://localhost:3000/transactions/check -X POST \
    -H 'Content-Type: application/json' \
    -d '{
        "transaction_id" : 2342357,
        "merchant_id" : 29744,
        "user_id" : 97051,
        "card_number" : "434505******9116",
        "transaction_date" : "2019-11-31T23:16:32.812632",
        "transaction_amount" : 373,
        "device_id" : 285475
        }'
```

---

# Understanding the Industry

## Explain the money flow and the information flow in the acquirer market and the role of the main players.

The payment flow may differ from country to country but to make this answer reasonable I'll focus on how it works at Brazil.
The main flow of the payment is:
1. **Customer** buys a product and uses its Credit Card to pay;
2. **Merchant (POS terminal or e-commerce)** receives the purchase information with the amount and the credit card information and sent to its Acquiring Bank;
3. **Acquirer** this information was forward to the Card Network;
4. **Card Network (Mastercard, Visa, etc)** find the Issuer Bank and forward the information;
5. **Issuer Bank** will run the risk analysis, check for funds or credits and them approve or deny the payment and send this answer back to the Card Network;
6. **Card Network** returns the answer to the Acquirer Bank;
7. **Acquirer Bank** returns that answer to the merchant;
8. **Merchant** returns the answer to the Customer.

## Explain the difference between acquirer, sub-acquirer and payment gateway and how the flow explained in question 1 changes for these players.

- **Acquirer** a company that is responsible to deal with the financial transactions with credit cards, talking with Card Networks and dealing with the money in those transactions;
	- this is the flow as in the last question;
- **Sub-acquirer** are companies that makes easier to small business to connect with the Acquirers sometimes having other services to the business like fraud analysis, or payment aggregations;
	1. **Customer** buys a product and uses its Credit Card to pay;
	2. **Merchant (POS terminal or e-commerce)** receives the purchase information with the amount and the credit card information and sent to its Sub-Acquirer;
	3. **Sub-Acquirer** will forward the information to the Acquirer, and ,depending of the services provided by the sub-acquirer, it could runs a fraud detection or other processes in this step;
	4. **Acquirer** this information was forward to the Card Network;
	5. **Card Network (Mastercard, Visa, etc)** find the Issuer Bank and forward the information;
	6. **Issuer Bank** will run the risk analysis, check for funds or credits and them approve or deny the payment and send this answer back to the Card Network;
	7. **Card Network** returns the answer to the Acquirer Bank;
	8. **Acquirer Bank** returns that answer to the Sub Acquirer;
	9. **Sub Acquirer** returns the answer to the Customer
	10. **Merchant** returns the answer to the Customer.
- **Payment Gateway** is a technology to make the communication between the merchant and the acquirer ensuring that the data will be encrypted and secure during this process; 
	1. **Customer** buys a product and uses its Credit Card to pay;
	2. **Merchant (POS terminal or e-commerce)** receives the purchase information with the amount and the credit card information and sent to its Payment Gateway;
	3. **Payment Gateway** encrypts and securely transmits the transaction details to the acquirer (or sub-acquirer)
	4. **Acquirer** this information was forward to the Card Network;
	5. **Card Network (Mastercard, Visa, etc)** find the Issuer Bank and forward the information;
	6. **Issuer Bank** will run the risk analysis, check for funds or credits and them approve or deny the payment and send this answer back to the Card Network;
	7. **Card Network** returns the answer to the Acquirer Bank;
	8. **Acquirer Bank** returns that answer to the payment gateway;
	9. **Payment Gateway** sends the response to the merchant;
	10. **Merchant** returns the answer to the Customer.

## Explain what chargebacks are, how they differ from cancellations and what is their connection with fraud in the acquiring world.

Chargebacks and cancellations are flows that returns the money to the Issuer Bank (Customer). The main difference between those flows are:
- **Chargebacks** occurs when the customer reaches his Bank (Issuer) saying that he didn't do that purchase, or it'll charge with a wrong amount or anything like that;
- **Cancellations** occurs when the customer reaches merchant and the merchant triggers the cancellation with its Acquirer. This method can only happens before the settlement of the payment because it will cancel all the data on all the members the payment flow preventing the transaction from being completed.

Those two process could be trigger by the fraud system:
- **Chargebacks** when the fraud system was looking for more than one transaction comparing them to the customer habits or the frequency of those transactions;
- **Cancellations** where the fraud system gets a possible fraud before completing the payment flow;

