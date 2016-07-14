Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :models, only: [:show]
  end
end
