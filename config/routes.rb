Rails.application.routes.draw do
  get 'first/index'
  get 'test/index'
  get 'test_path/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'first/:id', to: 'first#show'
  # Defines the root path route ("/")
  # root "articles#index"
end
