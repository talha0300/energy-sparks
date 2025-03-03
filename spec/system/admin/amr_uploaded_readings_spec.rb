require 'rails_helper'

describe AmrUploadedReading, type: :system do

  let!(:admin)              { create(:admin) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
    click_on 'AMR Data feed configuration'
  end

  describe 'normal file format' do

    let!(:config)             { create(:amr_data_feed_config) }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      click_on config.description
      click_on 'Upload file'
    end

    %w(.csv .xlsx .xls).each do |ext|
      context "previewing a valid #{ext} file" do
        before do
          attach_file('amr_uploaded_reading[data_file]', "spec/fixtures/amr_upload_data_files/banes-example-file#{ext}")
          expect { click_on 'Preview' }.to change { AmrUploadedReading.count }.by 1
        end

        it { expect(AmrUploadedReading.count).to be 1 }
        it { expect(AmrUploadedReading.first.imported).to be false }
        it { expect(page).to_not have_content('We have identified a problem') }
        it { expect(page).to have_content('Data preview') }
        it { expect(page).to have_content('2200012767323') }
        it { expect(page).to have_content('2200012030374') }
        it { expect(page).to have_content('2200040922992') }

        context "and uploading with the new loader" do
          before do
            expect { click_on "Insert this data" }.to change { ManualDataLoadRun.count }.by(1)
          end

          it { expect(page).to have_content("Processing") }
          it { expect(page).to_not have_link("Upload another file") }

          context "when complete" do
            before do
              expect_any_instance_of(ManualDataLoadRun).to receive(:complete?).at_least(:once).and_return true
              visit current_path # force / speed up page reload (that would usually happen after 5 secs anyway)
            end
            it { expect(page).to_not have_content("Processing") }

            it "has a link to upload another file" do
              expect(page).to have_link("Upload another file")
            end

            context "and clicking link" do
              before { click_link "Upload another file" }

              it "displays the manual upload page for the same configuration" do
                expect(page).to have_current_path(new_admin_amr_data_feed_config_amr_uploaded_reading_path(config))
              end
            end
          end
        end
      end
    end

    it 'produces an error message when an invalid CSV file is uploaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/not_a_csv.csv')
      expect { click_on 'Preview' }.to_not change { AmrUploadedReading.count }

      expect(AmrUploadedReading.count).to be 0

      expect(page).to have_content('Error:')
    end

    it 'produces an error message when an invalid xlsx file is uploaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/not_a_xlsx.xlsx')
      expect { click_on 'Preview' }.to_not change { AmrUploadedReading.count }

      expect(AmrUploadedReading.count).to be 0

      expect(page).to have_content('Error:')
    end

    it 'produces an error message when translator raise error' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/not_a_csv.csv')
      expect_any_instance_of(Amr::DataFileToAmrReadingData).to receive(:perform).and_raise(Amr::DataFeedException.new('bad file'))

      click_on 'Preview'

      expect(AmrUploadedReading.count).to be 0
      expect(page).to have_content('Error:')
      expect(page).to have_content('bad file')
    end


    it 'is helpful if a very different format file is loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_NO_VALID_READINGS)
    end

    it 'is helpful if a dodgy date format file is loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-date-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_NO_VALID_READINGS)
    end

    it 'is helpful if a single dodgy date format is in the file loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_BAD_DATE_FORMAT)
    end

    it 'is helpful if a dodgy mpan format file is loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-missing-mpan-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_MPAN_MPRN)
    end

    it 'is helpful if a reading is missing' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-missing-data-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_READINGS)
    end

  end

  describe 'bad sheffield file' do
    let!(:config)             { create(:amr_data_feed_config,
                                          date_format: "%d/%m/%Y",
                                          mpan_mprn_field: "MPAN",
                                          reading_date_field: "ConsumptionDate",
                                          reading_fields: ["kWh_1", "kWh_2", "kWh_3", "kWh_4", "kWh_5", "kWh_6", "kWh_7", "kWh_8", "kWh_9", "kWh_10", "kWh_11", "kWh_12", "kWh_13", "kWh_14", "kWh_15", "kWh_16", "kWh_17", "kWh_18", "kWh_19", "kWh_20", "kWh_21", "kWh_22", "kWh_23", "kWh_24", "kWh_25", "kWh_26", "kWh_27", "kWh_28", "kWh_29", "kWh_30", "kWh_31", "kWh_32", "kWh_33", "kWh_34", "kWh_35", "kWh_36", "kWh_37", "kWh_38", "kWh_39", "kWh_40", "kWh_41", "kWh_42", "kWh_43", "kWh_44", "kWh_45", "kWh_46", "kWh_47", "kWh_48"],
                                          column_separator: ",",
                                          header_example: "siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48,kVArh_1,kVArh_2,kVArh_3,kVArh_4,kVArh_5,kVArh_6,kVArh_7,kVArh_8,kVArh_9,kVArh_10,kVArh_11,kVArh_12,kVArh_13,kVArh_14,kVArh_15,kVArh_16,kVArh_17,kVArh_18,kVArh_19,kVArh_20,kVArh_21,kVArh_22,kVArh_23,kVArh_24,kVArh_25,kVArh_26,kVArh_27,kVArh_28,kVArh_29,kVArh_30,kVArh_31,kVArh_32,kVArh_33,kVArh_34,kVArh_35,kVArh_36,kVArh_37,kVArh_38,kVArh_39,kVArh_40,kVArh_41,kVArh_42,kVArh_43,kVArh_44,kVArh_45,kVArh_46,kVArh_47,kVArh_48",
                                          number_of_header_rows: 1 ) }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      click_on config.description
      click_on 'Upload file'
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-bad-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_READINGS)
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-bad-sheffield-proper-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_READING_DATE_MISSING)
    end
  end

  describe 'with row per reading' do

    let!(:config)             { create(:amr_data_feed_config,
                                          date_format: "%d %b %Y %H:%M:%S",
                                          mpan_mprn_field: "MPR",
                                          reading_date_field: "ReadDatetime",
                                          reading_fields: ["kWh"],
                                          column_separator: ",",
                                          header_example: "MPR,ReadDatetime,kWh,ReadType",
                                          row_per_reading: true,
                                          number_of_header_rows: 2 ) }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      click_on config.description
      click_on 'Upload file'
    end

    it 'handles a correct file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-highlands-file.csv')
      expect { click_on 'Preview' }.to change { AmrUploadedReading.count }.by 1

      expect(AmrUploadedReading.count).to be 1
      expect(AmrUploadedReading.first.imported).to be false

      expect(page).to_not have_content('We have identified a problem')
      expect(page).to have_content('Data preview')
      expect(page).to have_content('1712423842469')

      expect { click_on "Insert this data" }.to change { ManualDataLoadRun.count }.by(1)

      expect(page).to have_content("Processing")
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE)
    end
  end
end
