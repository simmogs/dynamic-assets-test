Rails.application.routes.draw do
  resource :custom_theme, controller: :custom_theme

  root to: 'visitors#index'
end
