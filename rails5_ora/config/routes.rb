Rails.application.routes.draw do
  Rails.logger.info "routes.rb: Setting routes for every controller action"
  WelcomeController.routing_actions("#{__dir__}/../app/controllers").each do |r|
    # puts "set route for #{r[:controller]}/#{r[:action]}"
    get  "#{r[:controller]}/#{r[:action]}"
    post  "#{r[:controller]}/#{r[:action]}"
  end


=begin
  get 'oracle_test/bind_hash'
  get 'oracle_test/bind_array'
  post 'oracle_test/bind_hash'
  post 'oracle_test/bind_array'
  post 'oracle_test/bind_array_in'
  post 'oracle_test/bind_freeform'
  post 'oracle_test/find_by_sql_array'
  post 'oracle_test/find_by_sql_hash'
  get 'oracle_test/bind'
=end
  get 'welcome/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  root 'welcome#index'
end
