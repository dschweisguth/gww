describe PhotosHelper do

  describe '#other_photos_path' do
    it 'returns the URI to the list sorted by the given criterion' do
      other_photos_path_returns 'date-added', '+', 'username', '/photos/sorted-by/username/order/+/page/1'
    end

    it 'reverses the sort order if the list is already sorted by the given criterion' do
      other_photos_path_returns 'username', '+', 'username', '/photos/sorted-by/username/order/-/page/1'
    end

    it 'restores the sort order if the list is already reverse-sorted by the given criterion' do
      other_photos_path_returns 'username', '-', 'username', '/photos/sorted-by/username/order/+/page/1'
    end

    def other_photos_path_returns(current_criterion, current_order, requested_criterion, expected_uri)
      controller.params[:sorted_by] = current_criterion
      controller.params[:order] = current_order
      helper.other_photos_path(requested_criterion).should == expected_uri
    end

  end

  describe '#ago' do
    it "returns 'a moment ago' if time < 1 second ago" do
      ago_returns 2011, 2011, 'a moment ago'
    end

    it "returns 'n seconds ago' if 1 second ago <= time < 1 minute ago " do
      ago_returns [ 2011, 1, 1, 0, 0, 1 ], 2011, '1 second ago'
    end

    it "pluralizes seconds" do
      ago_returns [ 2011, 1, 1, 0, 0, 2 ], 2011, '2 seconds ago'
    end

    it "returns 'n minutes ago' if 1 minute ago <= time < 1 hour ago" do
      ago_returns [ 2011, 1, 1, 0, 1, 0 ], 2011, '1 minute ago'
    end

    it "pluralizes minutes" do
      ago_returns [ 2011, 1, 1, 0, 2, 0 ], 2011, '2 minutes ago'
    end

    it "wraps minutes" do
      ago_returns 2011, [ 2010, 12, 31, 23, 59, 0 ], '1 minute ago'
    end

    it "returns 'n hours ago' if 1 hour ago <= time < 37 hours ago" do
      ago_returns [ 2011, 1, 1, 1, 0, 0 ], 2011, '1 hour ago'
    end

    it "pluralizes hours" do
      ago_returns [ 2011, 1, 1, 2, 0, 0 ], 2011, '2 hours ago'
    end

    it "wraps hours" do
      ago_returns 2011, [ 2010, 12, 31, 23, 0, 0 ], '1 hour ago'
    end

    it "returns 'n days ago' if 37 hours ago <= time < 10 days ago" do
      ago_returns [ 2011, 1, 2, 13, 0, 0 ], 2011, '2 days ago'
    end

    it "wraps days" do
      ago_returns 2011, [ 2010, 12, 30, 11, 0, 0 ], '2 days ago'
    end

    it "returns 'n weeks ago' if 10 days ago <= time < 1 month ago" do
      ago_returns [ 2011, 1, 11, 0, 0, 0 ], 2011, '2 weeks ago'
    end

    it "wraps weeks" do
      ago_returns 2011, [ 2010, 12, 22, 0, 0, 0 ], '2 weeks ago'
    end

    it "returns 'n months ago' if 1 month ago <= time" do
      ago_returns [ 2011, 2, 1, 0, 0, 0 ], 2011, '1 month ago'
    end

    it "pluralizes months" do
      ago_returns [ 2011, 3, 1, 0, 0, 0 ], 2011, '2 months ago'
    end

    it "wraps months" do
      ago_returns 2011, [ 2010, 12, 1, 0, 0, 0 ], '1 month ago'
    end

    it "incorporates years into months" do
      ago_returns 2011, 2010, '12 months ago'
    end

    def ago_returns(now, time, expected)
      # noinspection RubyArgCount
      allow(Time).to receive(:now) { Time.utc(*now) }
      helper.ago(Time.utc(*time)).should == expected
    end

  end

  describe '#highlighted' do
    it "highlights a term" do
      helper.highlighted("one two three", [['two']]).should == 'one <span class="matched">two</span> three'
    end

    it "is insensitive to term case" do
      helper.highlighted("one two three", [['TWO']]).should == 'one <span class="matched">two</span> three'
    end

    it "is insensitive to string case" do
      helper.highlighted("ONE TWO THREE", [['TWO']]).should == 'ONE <span class="matched">TWO</span> THREE'
    end

    it "ignores a term not within word boundaries" do
      helper.highlighted("onetwothree", [['two']]).should == 'onetwothree'
    end

    it "ignores a term inside a single HTML tag" do
      helper.highlighted('<a href="two">', [['two']]).should == '<a href="two">'
    end

    it "ignores a term inside a single HTML tag even if the term also appears outside any tag" do
      helper.highlighted('two <a href="two">', [['two']]).should == '<span class="matched">two</span> <a href="two">'
    end

    it "highlights all terms in a group if they all match" do
      helper.highlighted("one two three four five", [['two', 'four']]).should == 'one <span class="matched">two</span> three <span class="matched">four</span> five'
    end

    it "doesn't highlight any terms in a group if they don't all match" do
      helper.highlighted("one two three", [['two', 'four']]).should == 'one two three'
    end

    it "considers other strings that might have contributed to the match when considering whether all terms in a group match" do
      helper.highlighted("one two three", [['two', 'four']], ['four']).should == 'one <span class="matched">two</span> three'
    end

    it "highlights all terms in all groups if they all match" do
      helper.highlighted("one two three four five", [['two'], ['four']]).should == 'one <span class="matched">two</span> three <span class="matched">four</span> five'
    end

    it "highlights terms in a group even if other groups don't match" do
      helper.highlighted("one two three four five", [['two'], ['six']]).should == 'one <span class="matched">two</span> three four five'
    end

    it "handles duplicate terms in a group" do
      helper.highlighted("one two three", [['two', 'two']]).should == 'one <span class="matched">two</span> three'
    end

    it "handles duplicate terms in different groups" do
      helper.highlighted("one two three", [['two'], ['two']]).should == 'one <span class="matched">two</span> three'
    end

  end

end
