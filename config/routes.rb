Rails.application.routes.draw do
  resources :amazon_products
  resources :url_to_crawls
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'url_to_crawls#index'
end
