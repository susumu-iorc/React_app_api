Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :v1 do
    mount_devise_token_auth_for "User", at: "auth"
      # 住所関連
      get  "userbase/check" , to:"userbase#check"
      get  "userbase/get"   , to:"userbase#get"
      post "userbase/update", to:"userbase#update"

      # shoplist関連     
      get  "shoplist/get", to:"shoplist#get"

      # memo関連
      get  "memo/get"    , to:"memo#get"
      post  "memo/update", to:"memo#update"
  end
end
