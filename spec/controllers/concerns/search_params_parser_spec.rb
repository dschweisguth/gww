describe 'SearchParamsParser' do
  describe '#form_params' do
    before do
      stub(Person).exists?(username: 'known-username') { true }
    end

    # When there are no segments params[:segments] is nil, not ''.
    it "returns defaults for an empty segments" do
      parser_parses(nil).into \
        'did' => 'posted',
        'sorted-by' => 'last-updated',
        'direction' => '-'
    end

    it "removes post search defaults" do
      parser_canonicalizes('did/posted/sorted-by/last-updated').into ''
    end

    it "removes backwards dates" do
      parser_canonicalizes('from-date/1-2-14/to-date/1-1-14').into ''
    end

    it "returns defaults for segments specifying activity" do
      parser_parses('did/activity/done-by/known-username').into \
        'did' => 'activity',
        'done-by' => 'known-username',
        'sorted-by' => 'date-taken',
        'direction' => '-'
    end

    it "removes activity search defaults" do
      parser_canonicalizes('did/activity/done-by/known-username/sorted-by/date-taken/direction/-').
        into 'did/activity/done-by/known-username'
    end

    it "removes parameters incompatible with activity search" do
      parser_canonicalizes('did/activity/done-by/known-username/text/Fort Point/game-status/unfound/sorted-by/date-added').
        into 'did/activity/done-by/known-username'
    end

    it "removes did/activity without done-by" do
      parser_canonicalizes('did/activity').into ''
    end

    it "removes an odd number of segments" do
      parser_canonicalizes('did').into ''
    end

    it "removes an unknown parameter" do
      parser_canonicalizes('unknown/unknown').into ''
    end

    it "removes familiar but invalid parameters" do
      parser_canonicalizes('page/1/per-page/1').into ''
    end

    it "removes known parameters with invalid values" do
      parser_canonicalizes(
        'did/something/game-status/unpossible/from-date/not-a-date/to-date/not-one-either/sorted-by/gibberish/direction/nonsense').
        into ''
    end

    it "removes an unknown username" do
      stub(Person).exists?(username: 'unknown-username') { false }
      parser_canonicalizes('done-by/unknown-username').into ''
    end

    def parser_parses(segments)
      ParseResultAsserter.new segments
    end

    class ParseResultAsserter < Struct.new(:segments)
      def into(params)
        SearchParamsParser.new.form_params(segments).should == params
      end
    end

    def parser_canonicalizes(segments)
      CanonicalizeResultAsserter.new segments
    end

    class CanonicalizeResultAsserter < Struct.new(:segments)
      include RSpec::Matchers

      def into(canonical_uri)
        lambda { SearchParamsParser.new.form_params segments }.
          should raise_error(BaseSearchParamsParser::NonCanonicalSegmentsError, canonical_uri)
      end

    end

  end
end
