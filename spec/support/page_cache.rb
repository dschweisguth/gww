def mock_clear_page_cache(times = 1)
  mock(PageCache).clear.times(times)
end
