require 'rails_helper'

module Transifex
  describe Client do
    let(:api_key)     { '1/123abc' }
    let(:project)     { 'es-test' }
    let(:status)      { 200 }
    let(:success)     { true }
    let(:headers)     { { "content-type" => "application/vnd.api+json" } }
    let(:body)        { { data: {} }.to_json }
    let(:response)    { double(status: status, 'success?' => success, headers: headers, body: body) }
    let(:connection)  { double(:faraday) }

    context 'when creating connection' do
      let(:client)          { Transifex::Client.new(api_key, project) }
      let(:request_headers) { { "Authorization"=>"Bearer #{api_key}", "Content-Type"=>"application/vnd.api+json"} }

      it 'supplies headers' do
        expect(Faraday).to receive(:new).with(Transifex::Client::BASE_URL, headers: request_headers).and_return(connection)
        expect(connection).to receive(:get).and_return(response)
        client.get_languages
      end
    end

    context 'when using connection' do
      let(:client)      { Transifex::Client.new(api_key, project, connection) }

      context 'when api returns error' do
        let(:status)      { 404 }
        let(:body)        { File.read('spec/fixtures/transifex/errors.json') }

        it 'includes messages' do
          expect(connection).to receive(:get).and_return(response)
          begin
            client.get_resource_translations_async_download('123')
          rescue Transifex::Client::NotFound => e
            expect(e.message).to eq('not_found: URL `/resource_strings_async_uploads/123` does not refer to an existing endpoint')
          end
        end
      end

      context '#get_languages' do
        let(:body)          { File.read('spec/fixtures/transifex/get_languages.json') }
        let(:expected_path) { "projects/o:energy-sparks:p:#{project}/languages" }

        it 'requests url with path and returns data' do
          expect(connection).to receive(:get).with(expected_path).and_return(response)
          languages = client.get_languages
          expect(languages[0]["attributes"]["code"]).to eq('cy')
        end
      end

      context '#list_resources' do
        let(:body)          { File.read('spec/fixtures/transifex/list_resources.json') }
        let(:expected_path) { "resources?filter[project]=o:energy-sparks:p:#{project}" }

        it 'requests url with filter and returns data' do
          expect(connection).to receive(:get).with(expected_path).and_return(response)
          resources = client.list_resources
          expect(resources[0]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1')
        end
      end

      context '#get_resource_language_stats' do
        context 'for project' do
          let(:body)          { File.read('spec/fixtures/transifex/get_resource_language_stats.json') }
          let(:expected_path) { "resource_language_stats?filter[project]=o:energy-sparks:p:#{project}" }

          it 'requests url with filter and returns data' do
            expect(connection).to receive(:get).with(expected_path).and_return(response)
            resource_language_stats = client.get_resource_language_stats
            expect(resource_language_stats[0]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:cy')
            expect(resource_language_stats[1]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:en')
          end
        end

        context 'for specified resource and language' do
          let(:body)          { File.read('spec/fixtures/transifex/get_resource_language_stats_with_params.json') }
          let(:slug)          { 'slug-jh1' }
          let(:language)      { 'cy' }
          let(:expected_path) { "resource_language_stats/o:energy-sparks:p:#{project}:r:#{slug}:l:#{language}" }

          it 'adds resource and language to url' do
            expect(connection).to receive(:get).with(expected_path).and_return(response)

            resource_language_stats = client.get_resource_language_stats(slug, language)

            expect(resource_language_stats["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:cy')
            expect(resource_language_stats["attributes"]["untranslated_words"]).to eq(22)
            expect(resource_language_stats["attributes"]["translated_words"]).to eq(0)
            expect(resource_language_stats["attributes"]["total_strings"]).to eq(12)
            expect(resource_language_stats["attributes"]["reviewed_strings"]).to eq(0)
            expect(resource_language_stats["attributes"]["last_review_update"]).to eq('2022-06-15T14:30:49Z')
            expect(resource_language_stats["relationships"]["language"]["data"]["id"]).to eq('l:cy')
          end
        end
      end

      context '#create_resource_strings_async_upload' do
        let(:slug)          { 'slug-jh1' }
        let(:content)       { 'some yaml' }
        let(:body)          { File.read('spec/fixtures/transifex/create_resource_strings_async_upload.json') }
        let(:expected_path) { "resource_strings_async_uploads" }

        it 'requests url with path and returns data' do
          expect(connection).to receive(:post).with(expected_path, anything).and_return(response)
          ret = client.create_resource_strings_async_upload(slug, content)
          expect(ret["id"]).to eq('2b3d4f24-4b37-46b2-b4a1-d5365ae1d3ca')
        end
      end

      context '#create_resource_strings_async_upload' do
        let(:slug)          { 'slug-jh1' }
        let(:content)       { 'some yaml' }
        let(:body)          { File.read('spec/fixtures/transifex/create_resource_strings_async_upload.json') }
        let(:expected_path) { "resource_strings_async_uploads" }

        it 'requests url with path and returns data' do
          expect(connection).to receive(:post).with(expected_path, anything).and_return(response)
          ret = client.create_resource_strings_async_upload(slug, content)
          expect(ret["id"]).to eq('2b3d4f24-4b37-46b2-b4a1-d5365ae1d3ca')
        end
      end

      context '#get_resource_strings_async_upload' do
        let(:upload_id)     { 'abc-123' }
        let(:body)          { File.read('spec/fixtures/transifex/get_resource_strings_async_upload.json') }
        let(:expected_path) { "resource_strings_async_uploads/#{upload_id}" }

        it 'requests url with path and returns data' do
          expect(connection).to receive(:get).with(expected_path).and_return(response)
          ret = client.get_resource_strings_async_upload(upload_id)
          expect(ret["id"]).to eq('2b3d4f24-4b37-46b2-b4a1-d5365ae1d3ca')
          expect(ret["attributes"]["status"]).to eq('succeeded')
        end
      end

      context '#create_resource_translations_async_downloads' do
        let(:slug)          { 'slug-jh1' }
        let(:language)      { 'cy' }
        let(:body)          { File.read('spec/fixtures/transifex/create_resource_translations_async_downloads.json') }
        let(:expected_path) { "resource_translations_async_downloads" }

        it 'requests url with path and returns data' do
          expect(connection).to receive(:post).with(expected_path, anything).and_return(response)
          ret = client.create_resource_translations_async_downloads(slug, language)
          expect(ret["id"]).to eq('2fc50390-613e-4658-b613-077cd36af734')
          expect(ret["attributes"]["status"]).to eq('pending')
        end
      end

      context '#get_resource_translations_async_download' do
        let(:download_id)   { 'xyz-987' }
        let(:expected_path) { "resource_translations_async_downloads/#{download_id}" }

        context 'when translation has not yet completed' do
          let(:body)        { File.read('spec/fixtures/transifex/get_resource_translations_async_downloads_pending.json') }

          it 'returns file contents' do
            expect(connection).to receive(:get).with(expected_path).and_return(response)
            contents = client.get_resource_translations_async_download(download_id)
            expect(contents).to be_nil
          end
        end

        context 'when translation has completed' do
          let(:headers)     { { "content-type" => "text/yaml; charset=utf-8" } }
          let(:body)        { 'some yaml' }

          it 'returns file contents' do
            expect(connection).to receive(:get).with(expected_path).and_return(response)
            contents = client.get_resource_translations_async_download(download_id)
            expect(contents).to eq('some yaml')
          end
        end

        context 'when translation has errors' do
          let(:body)        { File.read('spec/fixtures/transifex/get_resource_translations_async_downloads_errors.json') }
          it 'raises error which includes messages' do
            expect(connection).to receive(:get).with(expected_path).and_return(response)
            begin
              client.get_resource_translations_async_download(download_id)
            rescue Transifex::Client::TranslationsDownloadError => e
              expect(e.message).to eq('parse_error: Could not decode JSON object')
            end
          end
        end
      end
    end
  end
end
