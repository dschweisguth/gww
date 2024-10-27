describe 'SearchDataParamsParser' do
  describe '#model_params' do
    # See search_data_params_parser_spec for examples that are common to the two parsers

    it "returns model search parameters including defaults not present in the segments" do
      parser_parses('page/1').into \
        did: 'posted',
        sorted_by: 'last-updated',
        direction: '-',
        page: 1,
        per_page: 30
    end

    # When there are no segments params[:segments] is nil, not ''.
    it "adds the default page to the segments" do
      parser_canonicalizes(nil).into 'page/1'
    end

    it "removes an invalid page number from the segments" do
      parser_canonicalizes('page/x').into 'page/1'
    end

    # This guards against per-page leaking in to the URL from Photo#search_defaults
    it "removes a per-page count from the segments" do
      parser_canonicalizes('page/1/per-page/1').into 'page/1'
    end

    def parser_parses(segments)
      ModelParamsResultAsserter.new segments
    end

    ModelParamsResultAsserter = Struct.new(:segments) do
      include RSpec::Matchers

      def into(params)
        expect(SearchDataParamsParser.new.model_params(segments)).to eq(params)
      end

    end

    def parser_canonicalizes(segments)
      ModelParamsErrorAsserter.new segments
    end

    ModelParamsErrorAsserter = Struct.new(:segments) do
      include RSpec::Matchers

      def into(canonical_uri)
        expect { SearchDataParamsParser.new.model_params segments }.
          to raise_error(SearchDataParamsParser::NonCanonicalSegmentsError, canonical_uri)
      end

    end

  end

  # This test doesn't test any functionality that isn't already tested; it just completes coverage
  describe '#transform_keys' do
    it "transforms the given map's keys with the given block" do
      expect(SearchDataParamsParser.new.transform_keys(x: 1, &:to_s)).to eq('x' => 1)
    end
  end

end
