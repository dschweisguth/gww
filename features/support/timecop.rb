Around('@frozen-in-time') do |_scenario, block|
  Timecop.freeze { block.call }
end
