module Admin
  class AmrUploadedReadingsController < AdminController
    def show
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
      @amr_uploaded_reading = AmrUploadedReading.find(params[:id])

      @valid = @amr_uploaded_reading.valid?(:validate_reading_data)
      @errors = @amr_uploaded_reading.errors.messages[:base].join(', ')
    end

    def new
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
      @amr_uploaded_reading = AmrUploadedReading.new(amr_data_feed_config: @amr_data_feed_config)
    end

    def create
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
      @csv_file = params[:amr_uploaded_reading][:csv_file]

      reading_data = Amr::CsvToReadingsHash.new(@amr_data_feed_config, @csv_file.tempfile).perform

      @amr_uploaded_reading = AmrUploadedReading.new(
        amr_data_feed_config: @amr_data_feed_config,
        file_name: @csv_file.original_filename,
        reading_data: reading_data
        )

      if @amr_uploaded_reading.save
        redirect_to admin_amr_data_feed_config_amr_uploaded_reading_path(@amr_data_feed_config, @amr_uploaded_reading)
      else
        render :new
      end
    end
  end
end
