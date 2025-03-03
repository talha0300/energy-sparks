RSpec.shared_context "school group recent usage" do
  before do
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types) { [:electricity, :gas, :storage_heaters] }
    electricity_changes = OpenStruct.new(
      change: "-16%",
      usage: '910',
      cost: '£137',
      co2: '8,540',
      change_text: "-16%",
      usage_text: '910',
      cost_text: '137',
      co2_text: '8,540',
      has_data: true
    )
    gas_changes = OpenStruct.new(
      change: "-5%",
      usage: '500',
      cost: '£200',
      co2: '4,000',
      change_text: "-5%",
      usage_text: '500',
      cost_text: '200',
      co2_text: '4,000',
      has_data: true
    )
    storage_heater_changes = OpenStruct.new(
      change: "-12%",
      usage: '312',
      cost: '£111',
      co2: '1,111',
      change_text: "-12%",
      usage_text: '312',
      cost_text: '111',
      co2_text: '1,111',
      has_data: true
    )
    allow_any_instance_of(School).to receive(:recent_usage) do
      OpenStruct.new(
        electricity: OpenStruct.new(week: electricity_changes, year: electricity_changes),
        gas: OpenStruct.new(week: gas_changes, year: gas_changes),
        storage_heaters: OpenStruct.new(week: storage_heater_changes, year: storage_heater_changes)
      )
    end
  end
end

RSpec.shared_context "school group priority actions" do
  let!(:alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
  let!(:alert_type_rating) do
    create(
      :alert_type_rating,
      alert_type: alert_type,
      rating_from: 6.1,
      rating_to: 10,
      management_priorities_active: true,
      description: "high"
    )
  end
  let!(:alert_type_rating_content_version) do
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating,
      management_priorities_title: 'Spending too much money on heating',
    )
  end
  let(:saving) do
    OpenStruct.new(
      school: school_1,
      one_year_saving_kwh: 0,
      average_one_year_saving_gbp: 1000,
      one_year_saving_co2: 1100
    )
  end
  let(:priority_actions) do
    {
      alert_type_rating => [saving]
    }
  end
  let(:total_saving) do
    OpenStruct.new(
      schools: [school_1],
      average_one_year_saving_gbp: 1000,
      one_year_saving_co2: 1100,
      one_year_saving_kwh: 2200
    )
  end
  let(:total_savings) do
    {
      alert_type_rating => total_saving
    }
  end

  before(:each) do
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:priority_actions).and_return(priority_actions)
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:total_savings).and_return(total_savings)
  end
end

RSpec.shared_context "school group comparisons" do
  before(:each) do
    allow_any_instance_of(SchoolGroup).to receive(:categorise_schools) {
      {
        electricity: {
          baseload: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => "My Cluster"
              }
            ]
          },
          electricity_long_term: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => "My Cluster"
              }
            ]
          }
        },
        gas: {
          gas_long_term: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => "My Cluster"
              }
            ]
          },
          gas_out_of_hours: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => nil
              }
            ]
          }
        }
      }
    }
  end
end

RSpec.shared_context "school group current scores" do
  before(:each) do
    allow_any_instance_of(SchoolGroup).to receive(:scored_schools) do
      OpenStruct.new(
        with_points: OpenStruct.new(
                       schools_with_positions: {
                        1 => [OpenStruct.new(name: 'School 1', sum_points: 20, school_group_cluster_name: "My Cluster"), OpenStruct.new(name: 'School 2', sum_points: 20, school_group_cluster_name: "Not set")],
                        2 => [OpenStruct.new(name: 'School 3', sum_points: 18, school_group_cluster_name: "Not set")]
                       }
                     ),
        without_points: [OpenStruct.new(name: 'School 4', school_group_cluster_name: "Not set"), OpenStruct.new(name: 'School 5', school_group_cluster_name: "Not set")]
      )
    end
  end
end
