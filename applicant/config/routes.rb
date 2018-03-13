Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "/applicants/new" => "applicants#new"
  post "/applicants" => "applicants#create"
end
