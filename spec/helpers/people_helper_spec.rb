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
end
