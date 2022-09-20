Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :v1 do
    mount_devise_token_auth_for "User", at: "auth"
      # 住所関連
      get  "userbase/check" , to:"userbase#check"
      get  "userbase"   , to:"userbase#get"
      patch "userbase", to:"userbase#patch"

      # shoplist関連     
      get  "shoplist/:sort", to:"shoplist#get"
      get  "shoplist", to:"shoplist#get"

      # memo関連
      get  "memo/:pid" , to:"memo#get"
      get  "memo"    , to:"memo#get"
      patch  "memo", to:"memo#patch"
  end
end
