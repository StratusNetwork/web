class Transaction
    class Stripe < Processor

        processor_name "Stripe"

        # Client Token Details
        field :email, type: String
        field :token, type: String

        # Remote Stripe IDs
        field :charge_id, type: String
        field :customer_id, type: String
        field :refund_id, type: String

        attr_accessible :email, :token, :charge_id, :customer_id, :refund_id

        def external_url
            "http://stripe.com" # TODO: Find what this URL is
        end

        def charge
            ::Stripe::Charge.retrieve(charge_id) if charge_id
        end

        def source
            charge.source if charge_id
        end

        def credit_card_identifier
            external_object.source.fingerprint if charge_id # TODO: Rename parent method to fingerprint
        end

        def fake?
            !source.livemode
        end

        def process!
            request do
                # Fetch or create a customer object
                customer = if self.customer_id
                    ::Stripe::Customer.retrieve(customer_id)
                else
                    ::Stripe::Customer.create
                end
                # Save the customer_id immediately
                self.customer_id = customer.id
                # Update the customer information
                user = transaction.user
                customer.email = user.email
                customer.source = "tok_visa" # TODO: Get source from stripe.js
                customer.description = "Customer for #{user.username} | #{user.email}"
                customer.metadata = {
                    player_id: user.player_id,
                    email: user.email,
                    name: user.username
                }
                customer.save
                # Make the charge to the source account
                charge = ::Stripe::Charge.create(
                    :amount => transaction.amount_in_dollars,
                    :currency => "usd",
                    :source => "tok_visa", # TODO: Get source from stripe.js
                    #:description => "TODO: A Charge Description",
                    #:statement_descriptor => "",
                    #:receipt_email => ""
                )
                # Save the chage_id immediately
                self.charge_id = charge.id 
            end.success?
        end

        def refund!
            request do
                self.refund_id = ::Stripe::Refund.create(:charge => charge_id).id if charge_id
            end
        end

        def request
            self.success = false
            self.error_message = nil
            result = nil
            begin
                if block_given?
                    result = yield
                    self.success = true
                end
            rescue Stripe::CardError => e
                body = e.json_body
                err  = body[:error]
                if err[:type] == "card_error"
                    unless self.error_message = err[:message]
                        self.error_message = "Card Payment Error: #{[err[:code], err[:decline_code]].delete_if(&:blank?).join(" | ")}"
                    end
                else
                    self.error_message = "#{e.http_status} Error: #{err[:type]}"
                end
            rescue Stripe::RateLimitError => e
                self.error_message = "Too many requests made too quickly"
            rescue Stripe::InvalidRequestError => e
                self.error_message = "Invalid parameters were supplied"
            rescue Stripe::AuthenticationError => e
                self.error_message = "Authentication with payment provider failed"
            rescue Stripe::APIConnectionError => e
                self.error_message = "Connection to payment provider servers failed"
            rescue Stripe::StripeError => e
                self.error_message = "Exception occured with payment provider"
            rescue => e
                self.error_message = "Unknown exception occured, contact staff immediately"
            end
            save!
            return result
        end
    end
end
