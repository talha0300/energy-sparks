require 'spec_helper'

require './handlers/uncompress_file'

describe DataPipeline::Handlers::UncompressFile do

  describe '#process_file' do

    let(:sheffield_csv) { File.open('spec/support/files/sheffield_export.csv') }
    let(:sheffield_zip) { File.open('spec/support/files/sheffield_export.zip') }
    let(:unknown_file) { File.open('spec/support/files/1x1.png') }

    let(:client) { Aws::S3::Client.new(stub_responses: true) }
    let(:environment) {
      {
        'PROCESS_BUCKET' => 'process-bucket',
        'UNPROCESSABLE_BUCKET' => 'unprocessable-bucket'
      }
    }

    before do
      client.stub_responses(
        :get_object, ->(context) {
          case context.params[:key]
          when 'sheffield/export.zip'
            { body: sheffield_zip}
          when 'sheffield/image.png'
            { body: unknown_file}
          else
            'NotFound'
          end
        }
      )
    end

    describe 'when the file is a zip' do

      let(:event){ DataPipeline::Support::Events.zip_added }

      it 'puts the unzipped file in the PROCESS_BUCKET from the environment using the key of the object added' do

        response = DataPipeline::Handlers::UncompressFile.new(event: event, client: client, environment: environment).uncompress_file

        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/4003063_9232_Export_20181108_120524_290.csv')
        expect(request[:params][:bucket]).to eq('process-bucket')
      end

      it 'returns a success code' do
        response = DataPipeline::Handlers::UncompressFile.new(event: event, client: client, environment: environment).uncompress_file
        expect(response[:statusCode]).to eq(200)
      end

    end

    describe 'when the file does not unzip' do

      let(:event){ DataPipeline::Support::Events.image_added }

      it 'puts the file in the UNPROCESSABLE_BUCKET from the environment using the key of the object added' do
        response = DataPipeline::Handlers::UncompressFile.new(event: event, client: client, environment: environment).uncompress_file

        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/image.png')
        expect(request[:params][:bucket]).to eq('unprocessable-bucket')
      end

      it 'returns a success code' do
        response = DataPipeline::Handlers::UncompressFile.new(event: event, client: client, environment: environment).uncompress_file
        expect(response[:statusCode]).to eq(200)
      end

    end

    describe 'when the file cannot be found' do

      let(:event){ DataPipeline::Support::Events.missing_file }

      it 'returns an error code' do
        response = DataPipeline::Handlers::UncompressFile.new(event: event, client: client, environment: environment).uncompress_file
        expect(response[:statusCode]).to eq(500)
      end
    end

  end

end
