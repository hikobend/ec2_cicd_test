Rails.application.routes.draw do
  root 'test#index'
  get 'test/:id', to: 'test#show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
