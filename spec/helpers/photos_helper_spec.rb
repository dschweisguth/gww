require 'spec_helper'

describe PhotosHelper do
  without_transactions

  describe '#list_path' do
    it 'returns the URI to the list sorted by the given criterion' do
      list_path_returns 'date-added', '+', 'username', '/photos/list/sorted-by/username/order/+/page/1'
    end

    it 'reverses the sort order if the list is already sorted by the given criterion' do
      list_path_returns 'username', '+', 'username', '/photos/list/sorted-by/username/order/-/page/1'
    end

    it 'restores the sort order if the list is already reverse-sorted by the given criterion' do
      list_path_returns 'username', '-', 'username', '/photos/list/sorted-by/username/order/+/page/1'
    end

    def list_path_returns(current_criterion, current_order, requested_criterion, expected_uri)
      params[:sorted_by] = current_criterion
      params[:order] = current_order
      helper.list_path(requested_criterion).should == expected_uri
    end

  end

end
