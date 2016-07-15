Rails.application.routes.draw do
  resources :brands, only: [:index] do
    resources :models, only: [:index, :show], constraints: { id: /.*/ }
  end
end
