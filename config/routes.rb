Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ], path: "acesso", controllers: { sessions: "users/sessions", passwords: "users/passwords", omniauth_callbacks: "users/omniauth_callbacks" }
  root "pages#home"
  get "sitemap.xml", to: "sitemaps#show", defaults: { format: :xml }
  get "escola", to: "pages#school"
  get "agenda", to: "pages#agenda"
  resources :articles, path: "noticias", only: [ :index, :show ] do
    get "capa", on: :member, to: "covers#show", as: :cover
  end
  get "fect", to: "pages#fect", as: :fect
  scope "/fect", as: :fect do
    get "agenda", to: "pages#agenda"
    resources :articles, path: "noticias", only: [ :index, :show ] do
      get "capa", on: :member, to: "covers#show", as: :cover
    end
  end
  [ "", "/fect" ].each do |prefix|
    post "#{prefix}/noticias/:id/curtir", to: "interactions#like"
    post "#{prefix}/noticias/:id/comentarios", to: "interactions#comment"
    post "#{prefix}/noticias/:id/comentarios/:comment_id/denunciar", to: "interactions#report"
    get "#{prefix}/eventos/:id/imagem", to: "event_images#show"
    get "#{prefix}/logo", to: "logos#show"
    get "#{prefix}/envio-qr", to: "qr_codes#show"
    get "#{prefix}/galeria", to: "photos#index"
    get "#{prefix}/enviar-fotos", to: "photos#new"
    post "#{prefix}/enviar-fotos", to: "photos#create"
    get "#{prefix}/fotografias/:id", to: "photos#show"
  end
  namespace :admin do
    resources :settings, only: [ :index, :update ]
    resources :categories, only: [ :index, :create, :destroy ]
    resources :users, only: [ :index, :create, :update ]
    resources :likes, only: :index
    resources :comments, only: [ :index, :update, :destroy ]
    resources :events, except: :show
    resources :photos, only: [ :index, :update, :destroy, :show ]

    root "dashboard#index"
    resources :articles, except: :show do
      post :preview, on: :collection
      patch :publish, on: :member
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
