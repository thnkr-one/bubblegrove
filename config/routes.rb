# config/routes.rb

Rails.application.routes.draw do
  root 'home#index'

  namespace :thnk do
    resources :products, only: [:index] do
      collection do
        get :bulk_print
      end
    end

    get 'variants/:uuid/details', to: 'variants#details', as: 'variant_details'
  end
  namespace :scanner do
    get 'camera' => 'camera#index'
    post 'camera/scan' => 'camera#scan'          # Route for scanning QR codes via API
    get 'lookup/:uuid' => 'scanner#lookup', as: 'lookup'  # Route for looking up products by UUID
  end
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
