require 'dashboard'

class Schools::SimulationsController < ApplicationController
  include SchoolAggregation
  include NewSimulatorChartConfig

  before_action :authorise_school
  before_action :set_simulation, only: [:show, :edit, :destroy, :update]
  before_action :set_show_charts, only: :show

  def index
    @simulations = Simulation.where(school: @school)
    create if @simulations.empty?
  end

  # ALSO used by simulation detail controller
  def show
    @simulation_configuration = @simulation.configuration
    local_school = aggregate_school(@school)

    simulator = ElectricitySimulator.new(local_school)
    simulator.simulate(@simulation_configuration)
    chart_manager = ChartManager.new(local_school, false)

    @number_of_charts = @charts.size

    respond_to do |format|
      format.html { render :show }
      format.json do
        # Allows for single run with all charts, or parallel
        @output = @charts.map do |this_chart_type|
          { chart_type: this_chart_type, data: chart_manager.run_chart_group(this_chart_type) }
        end

        @output = sort_out_group_charts(@output)
        @number_of_charts = @output.size
        render 'schools/analysis/chart_data'
      end
    end
  end

  def new
    #TODO sort this out including method renames ;)
    @simulation = Simulation.new
    @local_school = aggregate_school(@school)
    @actual_simulator = ElectricitySimulator.new(@local_school)
    default_appliance_configuration = @actual_simulator.default_simulator_parameters

    @simulation_configuration = default_appliance_configuration
    sort_out_simulation_stuff
  end

  def new_fitted
    #TODO sort this out including method renames ;)
    @simulation = Simulation.new
    @local_school = aggregate_school(@school)
    @actual_simulator = ElectricitySimulator.new(@local_school)
    default_appliance_configuration = @actual_simulator.default_simulator_parameters
    @simulation_configuration = @actual_simulator.fit(default_appliance_configuration)
  end

  # def new_exemplar
  #   #TODO sort this out including method renames ;)
  #   @simulation = Simulation.new
  #   @local_school = aggregate_school(@school)
  #   @actual_simulator = ElectricitySimulator.new(@local_school)
  #   default_appliance_configuration = @actual_simulator.default_simulator_parameters

  # end

  def create
    simulation_configuration = ElectricitySimulatorConfiguration.new

    # If we have parameters, use them, else create using the defaults
    if params[:simulation]
      simulation_configuration = merge_into_existing_configuration(simulation_params, simulation_configuration)

      default = false
      title = simulation_params[:title]
      notes = simulation_params[:notes]
    else
      default = true
      title = "Default appliance configuration"
      notes = "This simulation has been run with the default appliance configurations, you can create a new simulation with your own configurations."
    end
    @simulation = Simulation.create(user: current_user, school: @school, configuration: simulation_configuration, default: default, title: title, notes: notes)

    redirect_to school_simulation_path(@school, @simulation)
  end

  def destroy
    @simulation.delete
    respond_to do |format|
      format.html { redirect_to school_simulations_path(@school), notice: 'Simulation was deleted.' }
      format.json { head :no_content }
    end
  end

  def update
    simulation_configuration = @simulation.configuration
    simulation_configuration = merge_into_existing_configuration(simulation_params, simulation_configuration)

    if @simulation.update(configuration: simulation_configuration, title: simulation_params[:title], notes: simulation_params[:notes])
      redirect_to school_simulation_path(@school, @simulation)
    else
      render :edit
    end
  end

  def edit
    #TODO sort this out including method renames ;)
    @local_school = aggregate_school(@school)
    @actual_simulator = ElectricitySimulator.new(@local_school)
    @simulation_configuration = @simulation.configuration
    sort_out_simulation_stuff
  end

private

  def set_simulation
    @simulation = Simulation.find(params[:id])
  end

  def authorise_school
    @school = School.find_by_slug(params[:school_id])
    authorize! :show, @school
  end

  def set_show_charts
    @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:simulator][:charts]
  end

  def sort_out_group_charts(output)
    results = []
    output.each do |chart|
      if chart[:data].key?(:charts)
        chart[:data][:charts].each do |c|
          results << c
        end
      else
        results << chart
      end
    end
    results
  end

  # TODO works but is messy
  def merge_into_existing_configuration(simulation_params, simulation_configuration)
    updated_simulation_configuration = simulation_params.to_h.deep_symbolize_keys
    updated_simulation_configuration.each do |appliance, configuration_hash|
      break unless configuration_hash.is_a? Hash
      current_applicance = simulation_configuration[appliance]
      configuration_hash.each do |config, value|
        if current_applicance.key?(config) && config != :title
          if value.is_a? Hash
            value.each do |more_config, more_value|
              current_applicance[config][more_config] = convert_to_correct_format(more_config, more_value)
            end
          else
            current_applicance[config] = convert_to_correct_format(config, value)
          end
        end
      end
    end
    simulation_configuration
  end

  def sort_out_simulation_stuff
    if params.key?(:simulation)
      @simulation_configuration = merge_into_existing_configuration(simulation_params, @simulation_configuration)
    end

    @actual_simulator.simulate(@simulation_configuration)

    @charts = [:intraday_line_school_days_6months, :intraday_line_school_days_6months]
    chart_type = :intraday_line_school_days_6months

    @number_of_charts = @charts.size

    respond_to do |format|
      format.html
      format.json do
        chart_manager = ChartManager.new(@local_school, false)
        winter_config_for_school = chart_config_for_school.deep_dup
        winter_config_for_school[:timescale] = [{ schoolweek: -20 }]
        winter_config_for_simulator = chart_config_for_simulator.deep_dup
        winter_config_for_simulator[:timescale] = [{ schoolweek: -20 }]

        @output = [
          { chart_type: chart_type, data: sort_out_chart_data(chart_manager, chart_type, chart_config_for_school, chart_config_for_simulator) },
          { chart_type: chart_type, data: sort_out_chart_data(chart_manager, chart_type, winter_config_for_school, winter_config_for_simulator) },
        ]
        render 'schools/analysis/chart_data'
      end
    end
  end

  def sort_out_chart_data(chart_manager, chart_type, chart_config_for_school, chart_config_for_simulator)
    school_chart_info = chart_manager.run_chart(chart_config_for_school, chart_type)
    simulator_chart_info = chart_manager.run_chart(chart_config_for_simulator, chart_type)

    school_data = school_chart_info[:x_data]
    simulator_data = simulator_chart_info[:x_data]

    school_values = school_data[school_data.keys.first]
    simulator_values = simulator_data[simulator_data.keys.first]

    school_chart_info[:x_data] = { 'Actual school energy usage' => school_values, 'Simulated energy usage' => simulator_values }
    school_chart_info
  end

  def is_float?(string)
    true if Float(string) rescue false
  end

  def is_integer?(string)
    true if Integer(string) rescue false
  end

  def convert_to_correct_format(key, value)
    return value if key == :title
    return TimeOfDay.new(Time.parse(value).getlocal.hour, Time.parse(value).getlocal.min) if key.to_s.include?('time')
    return value.to_sym if [:type, :control_type].include? key
    return true if value == 'true'
    return false if value == 'false'
    return value.to_i if is_integer?(value)
    is_float?(value) ? value.to_f : value
  end

  def simulation_params
    config = ElectricitySimulatorConfiguration.new
    editable = config.keys.map { |key| { key => config.dig(key, :editable) }}

    editable.push(:title)
    editable.push(:notes)

    params.require(:simulation).permit(editable)
  end
end
