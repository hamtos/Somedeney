Rails.application.routes.draw do
  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }

  devise_for :customers, skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: "public/sessions"
  }

  devise_scope :customer do
    post 'customers/guest_sign_in' => 'public/sessions#guest_sign_in'
  end

  scope module: :public do
    root :to => "homes#top"
    get 'customers/my_page' => 'customers#show'
    get 'customers/information/edit' => 'customers#edit'
    patch 'customers/information/edit' => 'customers#update'
    get 'customers/confirm' => 'customers#confirm'
    patch 'customers/leave' => 'customers#leave'
    get 'notes/customers' => 'notes#my_index'
    resources :notes, only: [:index, :new, :create, :show, :edit, :update]
    resources :tags, only: [:index, :new, :create]
    resources :plans, only: [:index, :new, :create, :show, :edit, :update]
    post '/plans/confirm' => 'plans#confirm'
  end

  namespace :admin do
    root :to =>  'homes#top'
    resources :customers, only: [:index, :show, :edit, :update]
  end

end
