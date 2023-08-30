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
    post 'notes/copy' => 'notes#copy_record'
    resources :notes, only: [:index, :new, :create, :show, :edit, :update]
    resources :tags, only: [:index, :new, :create]
    get 'plans/add_note' =>'plans#add_note'
    get 'plans/remove_note' =>'plans#remove_note'
    get 'plans/reset_note' =>'plans#reset_note'
    get 'plans/confirm' => 'plans#confirm'
    get 'plans/up_note' => 'plans#up_note'
    get 'plans/down_note' => 'plans#down_note'
    get 'plans/:id/edit_new' => 'plans#edit_new', as: 'edit_new_plan'
    get 'plans/:id/edit_confirm' => 'plans#edit_confirm', as: 'edit_confirm_plan'
    resources :plans, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  end

  namespace :admin do
    root :to =>  'homes#top'
    resources :customers, only: [:index, :show, :edit, :update]
    resources :notes, only: [:index, :show, :edit, :update]
  end

end
