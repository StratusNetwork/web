PGM::Application.routes.draw do
	get '/shop' => redirect('http://shop.stratus.network')
	# post '/shop/status', :to => 'shop#status'
	# post '/shop/purchase', :to => 'shop#purchase'
	# get  '/shop/thanks', :to => 'shop#thanks'
end
