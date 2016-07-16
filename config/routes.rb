Rails.application.routes.draw do
  root to: 'home#index'
  resources :brands, only: [:index] do
    resources :models, only: [:index, :show], constraints: { id: /.*/ }
  end
  resources :search, only: [:show], constraints: { id: /.*/ }
end
