$:.push File.expand_path("../../lib", __FILE__)

module MongoEval
  autoload :Benchmark, 'mongoeval/benchmark'
  autoload :Queries, 'mongoeval/queries'
  puts "============================================"
  puts Benchmark.inspect
  puts "============================================"
end
