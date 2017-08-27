Rails.configuration.stripe = {
    :publishable_key => "pk_test_bJMjLDbQkqktm1iC4LydYlHF", #ENV['PUBLISHABLE_KEY'],
    :secret_key      => "sk_test_uKnJKFfpIs7gLnT3t2FzCrcb" #ENV['SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
