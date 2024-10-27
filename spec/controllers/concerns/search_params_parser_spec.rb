describe 'SearchParamsParser' do
  describe '#form_params' do
    before do
      allow(Person).to receive(:exists?).with(username: 'known-username') { true }
    end

    # When there are no segments params[:segments] is nil, not ''.
    it "returns form search parameters including defaults not present in the segments" do
      parser_parses(nil).into \
        'did' => 'posted',
        'sorted-by' => 'last-updated',
        'direction' => '-'
    end

    it "removes post search defaults from the segments" do
      parser_canonicalizes('did/posted/sorted-by/last-updated').into ''
    end

    it "removes a to-date that is before a from-date from the segments" do
      parser_canonicalizes('from-date/1-2-14/to-date/1-1-14').into 'from-date/1-2-14'
    end

    it "returns form search parameters for an activity search" do
      parser_parses('did/activity/done-by/known-username').into \
        'did' => 'activity',
        'done-by' => 'known-username',
        'sorted-by' => 'date-taken',
        'direction' => '-'
    end

    it "removes activity search defaults from the segments" do
      parser_canonicalizes('did/activity/done-by/known-username/sorted-by/date-taken/direction/-').
        into 'did/activity/done-by/known-username'
    end

    it "removes parameters incompatible with activity search from the segments" do
      parser_canonicalizes('did/activity/done-by/known-username/text/Fort Point/game-status/unfound/sorted-by/date-added').
        into 'did/activity/done-by/known-username'
    end

    it "removes did/activity without done-by from the segments" do
      parser_canonicalizes('did/activity').into ''
    end

    it "removes an odd number of segments from the segments" do
      parser_canonicalizes('did').into ''
    end

    it "removes an unknown parameter from the segments" do
      parser_canonicalizes('unknown/unknown').into ''
    end

    it "removes familiar but invalid parameters from the segments" do
      parser_canonicalizes('page/1/per-page/1').into ''
    end

    it "removes known parameters with invalid values from the segments" do
      parser_canonicalizes(
        'did/something/game-status/unpossible/from-date/not-a-date/to-date/not-one-either/sorted-by/gibberish/direction/nonsense').
        into ''
    end

    it "removes an unknown username from the segments" do
      allow(Person).to receive(:exists?).with(username: 'unknown-username') { false }
      parser_canonicalizes('done-by/unknown-username').into ''
    end

    def parser_parses(segments)
      FormParamsResultAsserter.new segments
    end

    FormParamsResultAsserter = Struct.new(:segments) do
      include RSpec::Matchers

      def into(params)
        expect(SearchParamsParser.new.form_params(segments)).to eq(params)
      end

    end

    def parser_canonicalizes(segments)
      FormParamsErrorAsserter.new segments
    end

    FormParamsErrorAsserter = Struct.new(:segments) do
      include RSpec::Matchers

      def into(canonical_uri)
        expect { SearchParamsParser.new.form_params segments }.
          to raise_error(SearchParamsParser::NonCanonicalSegmentsError, canonical_uri)
      end

    end

  end
end
