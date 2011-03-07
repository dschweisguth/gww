require 'spec_helper'

describe Answer do
  include Answer

  describe '#time_elapsed_between' do
    it 'returns the age with a precision of seconds in English' do
      time_elapsed_between(Time.utc(2000), Time.utc(2001, 2, 2, 1, 1, 1)).should ==
        '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second';
    end

    it 'pluralizes as appropriate' do
      time_elapsed_between(Time.utc(2000), Time.utc(2002, 4, 5, 5, 6, 7)).should ==
        '2&nbsp;years, 3&nbsp;months, 4&nbsp;days, 5&nbsp;hours, 6&nbsp;minutes, 7&nbsp;seconds';
    end

    it 'handles wraparound' do
      time_elapsed_between(Time.utc(2000, 2, 2, 1, 1, 1), Time.utc(2001)).should ==
        '10&nbsp;months, 28&nbsp;days, 22&nbsp;hours, 58&nbsp;minutes, 59&nbsp;seconds';
    end

  end

  describe '#ymd_elapsed_between' do
    it 'returns the age with a precision of days in English' do
      ymd_elapsed_between(Time.utc(2000), Time.utc(2001, 2, 2, 1, 1, 1)).should ==
        '1&nbsp;year, 1&nbsp;month, 1&nbsp;day';
    end

    it 'pluralizes as appropriate' do
      ymd_elapsed_between(Time.utc(2000), Time.utc(2002, 4, 5)).should ==
        '2&nbsp;years, 3&nbsp;months, 4&nbsp;days';
    end

    it 'handles wraparound' do
      ymd_elapsed_between(Time.utc(2000, 2, 2), Time.utc(2001)).should ==
        '10&nbsp;months, 29&nbsp;days';
    end

  end

end
