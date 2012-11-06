Test::Application.routes.draw do
  root :to => 'homes#index'

  get "homes/index"
  get "homes/admin"


  resources :settings

  resources :templates
  resources :questions do
    collection do
      post :delete_all
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
    end
    collection do
      get :settings
      post :save_settings
    end
  end

  resources :schedules do
    member do
      get :remove
      get :onecan
    end
  end

  resources :recruitment_tests
  resources :instructions
  resources :answers do
    collection do
      get :candidate_detail
      get :instructions

      get :blank
      get :make
    end
    member do
      get :congrats
      get :clogin
      put :candidate_update
      get :feed_back
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
    resources :experiences
    resources :qualifications
  end

  resources :sessions, only: [:new, :create, :destroy] do
    collection do
      get :signup
      get :success
      get :forgotpass
      post :sent_pass
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
