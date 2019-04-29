Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions'}
  post 'can_access_archive', to:'access#can_access_archive'
  get 'not_allowed', to:'archives#not_allowed'
  get 'unauthenticated', to:'archives#unauthenticated'

  authenticate :user do
    resources :archives do
      get "give_user_access_form"
      get "publish_archive_settings"
      post "publish_archive"
      post "add_user_to_archive"
      post "remove_user_access"
    end
  end

  root to: 'archives#index'
end
