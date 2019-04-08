Rails.application.routes.draw do
  get 'oracle_test/bind_hash'
  get 'oracle_test/bind_array'
  post 'oracle_test/bind_hash'
  post 'oracle_test/bind_array'
  post 'oracle_test/bind_array_in'
  post 'oracle_test/bind_freeform'
  get 'oracle_test/bind'
  get 'welcome/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  root 'welcome#index'
end
