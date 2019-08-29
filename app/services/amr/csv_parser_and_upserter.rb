module Amr
  class CsvParserAndUpserter
    attr_reader :inserted_record_count

    def initialize(config_to_parse_file, file_name_to_import)
      @file_name = file_name_to_import
      @config = config_to_parse_file
    end

    def perform
      Rails.logger.info "Loading: #{@config.local_bucket_path}/#{@file_name}"
      amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @config.id, file_name: @file_name, import_time: DateTime.now.utc)

      @inserted_record_count = if @config.row_per_reading
                                 row_per_reading(amr_data_feed_import_log)
                               else
                                 row_per_day(amr_data_feed_import_log)
                               end

      Rails.logger.info "Loaded: #{@config.local_bucket_path}/#{@file_name} records inserted: #{@inserted_record_count}"
      amr_data_feed_import_log.update(records_imported: @inserted_record_count)
      @inserted_record_count
    end

    private

    def row_per_day(amr_data_feed_import_log)
      array_of_rows = CsvParser.new(@config, @file_name).perform
      array_of_rows = DataFeedValidator.new(@config, array_of_rows).perform
      array_of_data_feed_reading_hashes = DataFeedTranslator.new(@config, array_of_rows).perform
      DataFeedUpserter.new(array_of_data_feed_reading_hashes, amr_data_feed_import_log.id).perform
    end

    def row_per_reading(amr_data_feed_import_log)
    end
  end
end
