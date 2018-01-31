# frozen_string_literal: true

Rails.application.routes.draw do
  scope '/eholdings' do
    resources :vendors, only: %i[index show] do
      member do
        get 'packages'
      end
    end

    resources :providers, only: %i[index show] do
      member do
        get 'packages'
      end
    end

    resources :packages, only: %i[index show update] do
      member do
        get 'customer-resources'
      end
    end

    resources :titles, only: %i[index show] do
      member do
        get 'customer-resources'
      end
    end

    resources :customer_resources,
              path: '/customer-resources',
              only: %i[show update]

    resource :configuration, only: %i[show update]
    resource :status, only: [:show]
  end

  match '/ebsco-rmapi/*path' => 'proxy#index',
        via: %i[get post put patch delete]

  match '/admin/health' => 'health#index',
        via: [:get]
end
