class Transaction
    class AcceptOn < Processor

        processor_name "AcceptOn"

        def external_url
            "" # TODO: Find what this URL is
        end

        def credit_card_identifier
            nil# TODO: Rename parent method to fingerprint
        end

        def fake?
            !source.livemode
        end

        def process!
        end

        def refund!
        end
    end
end
