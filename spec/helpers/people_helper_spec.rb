require 'spec_helper'

describe PeopleHelper do
  describe '#list_path' do
    it 'returns the URI to the list sorted by the given criterion' do
      should_return 'date-added', '+', 'username', '/people/list/sorted-by/username/order/+'
    end

    it 'reverses the sort order if the list is already sorted by the given criterion' do
      should_return 'username', '+', 'username', '/people/list/sorted-by/username/order/-'
    end

    it 'restores the sort order if the list is already reverse-sorted by the given criterion' do
      should_return 'username', '-', 'username', '/people/list/sorted-by/username/order/+'
    end

    def should_return(current_criterion, current_order, requested_criterion, expected_uri)
      params[:sorted_by] = current_criterion
      params[:order] = current_order
      helper.list_path(requested_criterion).should == expected_uri
    end

  end

  describe '#position' do
    before :all do
      @person = person_with 0
    end

    it "returns the appropriate prefix for '-most': '', if the person is first" do
      helper.position([ @person ], @person).should == ''
    end

    it "returns the appropriate prefix for '-most': '', if the person is tied for first" do
      helper.position([ person_with(0), @person ], @person).should == ''
    end

    it "returns the appropriate prefix for '-most': 'second-', if the person is second" do
      helper.position([ person_with(1), @person ], @person).should == 'second-'
    end

    it "returns the appropriate prefix for '-most': 'second-', if the person is tied for second" do
      helper.position([ person_with(1), person_with(0), @person ], @person).should == 'second-'
    end

    it "returns the appropriate prefix for '-most': 'third-', if the person is third" do
      helper.position([ person_with(2), person_with(1), @person ], @person).should == 'third-'
    end

    it "returns the appropriate prefix for '-most': 'third-', if the person is behind two others tied for first" do
      helper.position([ person_with(1), person_with(1), @person ], @person).should == 'third-'
    end

    it "returns the appropriate prefix for '-most': 'fourth-', if the person is fourth" do
      helper.position([ person_with(1), person_with(1), person_with(1), @person ], @person).should == 'fourth-'
    end

    it "returns the appropriate prefix for '-most': 'fifth-', if the person is fifth" do
      helper.position([ person_with(1), person_with(1), person_with(1), person_with(1), @person ], @person).should == 'fifth-'
    end

    def person_with(score)
      person = Person.new
      person[:score] = score
      person
    end

  end

  describe '#image_for_star' do
    expected = {
      :bronze => '/images/star-bronze.gif',
      :silver => '/images/star-silver.gif',
      :gold => '/images/star-gold.gif'
    }
    expected.keys.each do |star|
      it "returns the image URI #{expected[star]} given the star :#{star}" do
        helper.image_for_star(star).should == expected[star]
      end
    end
  end

end
