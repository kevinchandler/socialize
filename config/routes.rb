Rails.application.routes.draw do
  get '/' => 'pages#home'
  get '/search' => 'username#search'
end
