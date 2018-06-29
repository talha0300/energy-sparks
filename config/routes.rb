Rails.application.routes.draw do
  root to: 'home#index'

  get 'for-teachers', to: 'home#for_teachers'
  get 'for-pupils', to: 'home#for_pupils'

  get 'contact', to: 'home#contact'
  get 'enrol', to: 'home#enrol'
  get 'datasets', to: 'home#datasets'
  get 'team', to: 'home#team'
  get 'getting-started', to: 'home#getting_started'
  get 'scoring', to: 'home#scoring'

  resources :data_feeds

  get 'help/(:help_page)', to: 'home#help', as: :help

  resources :activity_types
  resources :activity_categories
  resources :calendars do
    scope module: :calendars do
      resources :calendar_events
    end
  end

  resources :schools do
    resources :activities
    scope module: :schools do
      resources :contacts
      resources :alerts

      get :chart, to: 'chart_data#chart'
      get :dashboard, to: 'chart_data#dashboard'
      get :main_dashboard_electric, to: 'chart_data#main_dashboard_electric'
      get :electricity_detail, to: 'chart_data#electricity_detail'
      get :gas_detail, to: 'chart_data#gas_detail'
      get :main_dashboard_electric_and_gas, to: 'chart_data#main_dashboard_electric_and_gas'
      get :boiler_control, to: 'chart_data#boiler_control'
      get :simulator, to: 'chart_data#simulator'


      # get :electricity_year, to: 'chart_data#electricity_year'
      # get :electricity_longterm, to: 'chart_data#electricity_longterm'
      # get :recent_electric, to: 'chart_data#recent_electric'
      #  get :gas_thermostatic, to: 'chart_data#gas_thermostatic'
      # get :recent_electric_and_gas, to: 'chart_data#recent_electric_and_gas'
      # get :electric_and_gas_year, to: 'chart_data#electric_and_gas_year'


      get :excel, to: 'chart_data#excel'
      get :holidays, to: 'chart_data#holidays'
      get :temperatures, to: 'chart_data#temperatures'
      get :solar_pv, to: 'chart_data#solar_pv'
      get :solar_irradiance, to: 'chart_data#solar_irradiance'
      get :electricity_meters, to: 'chart_data#electricity_meters'
      get :gas_meters, to: 'chart_data#gas_meters'
      get :aggregated_electricity_meters, to: 'chart_data#aggregated_electricity_meters'
      get :aggregated_gas_meters, to: 'chart_data#aggregated_gas_meters'

    end

    get :scoreboard, on: :collection
    member do
      get 'awards'
      get 'suggest_activity'
      get 'data_explorer'
      get 'usage'
      get 'compare_daily_usage', to: 'stats#compare_daily_usage'
      get 'compare_hourly_usage', to: 'stats#compare_hourly_usage'

#     get 'daily_usage', to: 'stats#daily_usage'
#     get 'hourly_usage', to: 'stats#hourly_usage'
    end
  end

  devise_for :users, controllers: {sessions: "sessions"}

  devise_for :users, skip: :sessions
  scope :admin do
    resources :users
    get 'reports', to: 'reports#index'
    get 'reports/loading', to: 'reports#loading'
    get 'reports/amr_data_index', to: 'reports#amr_data_index'
 #   get 'reports/data_feed_index', to: 'reports#data_feed_index'
    get 'reports/data_feeds/:id/show/:feed_type', to: 'reports#data_feed_show', as: :reports_data_feed_show
    get 'reports/:meter_id/show', to: 'reports#amr_data_show', as: :reports_amr_data_show
  end

  match '*unmatched', to: 'application#route_not_found', via: :all
end
