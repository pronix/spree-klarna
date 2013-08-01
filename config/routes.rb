Spree::Core::Engine.routes.append do
  namespace :admin do
    resource :klarna_settings, only: [:edit, :update]
  end
end
