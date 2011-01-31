require 'spec_helper'

describe Answer do
  before :all do
    @answer = Object.new
    @answer.extend Answer
  end

  describe '#time_elapsed_between' do
    it 'returns the duration in seconds from post to answer in English' do
      @answer.time_elapsed_between(Time.utc(2000), Time.utc(2001, 2, 2, 1, 1, 1)).should ==
        '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second';
    end

    it 'pluralizes as appropriate' do
      @answer.time_elapsed_between(Time.utc(2000), Time.utc(2002, 4, 5, 5, 6, 7)).should ==
        '2&nbsp;years, 3&nbsp;months, 4&nbsp;days, 5&nbsp;hours, 6&nbsp;minutes, 7&nbsp;seconds';
    end

  end

  describe '#ymd_elapsed_between' do
    it 'returns the duration in days from post to answer in English' do
      @answer.ymd_elapsed_between(Time.utc(2000), Time.utc(2001, 2, 2, 1, 1, 1)).should ==
        '1&nbsp;year, 1&nbsp;month, 1&nbsp;day';
    end

    it 'pluralizes as appropriate' do
      @answer.ymd_elapsed_between(Time.utc(2000), Time.utc(2002, 4, 5)).should ==
        '2&nbsp;years, 3&nbsp;months, 4&nbsp;days';
    end

  end

end
