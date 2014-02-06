Test::Application.routes.draw do
  root :to => 'homes#index'

  get "homes/index"
  get "homes/admin"
  get "homes/default_page"

  get 'settings/edit'
  put 'settings/update'

  resources :templates
  resources :questions do
    collection do
      post :multiple
      get :print_questions
    end
    member do
      get :delete_image
    end


    resources :options
  end

  resources :exams do
    member do
      get :question_paper
      get :remove_instruction
      get :schedule
      get :regenerate
      get :instruction_order
    end
    collection do
      get :settings
      post :save_settings
      post :update_instruction_order
    end
  end

  resources :schedules do
    member do
      get :remove
    end
  end

  resources :recruitment_tests do
    collection do
      post :sent_mail
      get :feedback
    end
    member do
      get :pass_or_fail
      get :clear_answers
    end
  end
  resources :instructions
  resources :answers do
    collection do
      get :candidate_detail
      get :feed_back
      get :additional
      get :instructions
      get :blank
      get :make
      get :check_popup
      get :entry_pass
      post :entry_pass_validation
    end
    member do
      get :congrats
      get :clogin
      put :candidate_update
    end
  end
  resources :categories
  resources :users do
    member do
      put :delete
      get :profile
      get :chgpass
      put :updatepass
    end

  end

  resources :candidates do
    collection  do
      post :schedule_create
    end
    member  do
      get :resent_schedule_email
    end
    resources :experiences
    resources :qualifications
  end

  resources :sessions, only: [:new, :create, :destroy] do
    collection do
      get :signup
      get :success
      get :forgotpass
      post :sent_pass
      post :registration
    end
    member do
      get :reset_pass
    end
  end
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match 'assync_get_status' => 'controller#assync_get_status'












  # The priority is based upon order of creation:
  # first created -> highest priority.






  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
