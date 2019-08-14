PGM::Application.routes.draw do
  scope module: 'api_public' do
    root :to => 'api_public#index'

    resources :users, except: [:destroy, :update, :show, :edit, :new, :create, :index] do
      collection do
        get "by_username/:username", action: :by_username
        get "by_uuid/:uuid", action: :by_uuid
        get "check_ban/", action: :check_ban
      end
    end
  end
end
