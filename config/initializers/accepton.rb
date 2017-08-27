accepton = AcceptOn::Client.new(api_key: 'pkey_018d891bf8954014', environment: :production)
print("----------------")
response = accepton.create_token(amount: 1_00, description: "Cool Accepton Test")
print(response.id)