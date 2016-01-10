class RevelationsController < ApplicationController
  caches_page :longest
  def longest
    @longest = Revelation.longest
  end
end
