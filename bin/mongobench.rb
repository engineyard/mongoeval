#!/usr/bin/env ruby
#
# == Synopsis
# Test load for reading and writing from a MongoDB Database
# Waits a random amount of time between a specified range 
# between operations
#
# == Usage
# mongobench [options]
# where [options] is one of the following:
#   -v  --version      Show the version of the script
#   -h  --help         Show this screen
#   -r  --run <test>   Perform the test <test> (default: simple)
#   -m  --min-sleep    Minimum sleep time (default: 0)
#   -M  --max-sleep    Maximum sleep time (default: 5)
#   -t  --time         Time in seconds for each thread to run (default: 300)
#   -T  --threads      Number of threads to spin up (default: 1)
#   -H  --host         Host string for mongo (default: "localhost")
#   -p  --port         Port to connect to (default: 2217)
#   -d  --db           Database to use (default: mongobench_test)
#   -u  --user         Auth user (default: none)
#   -w  --password     Auth password (default: none)
#   -D  --documents    Number of documents for the test collection (default: 20000)
#   -i  --iterations   Number of times to run the test before quitting (default: 0)
#                      0 = infinite. Note that the --time flag has precedence
#   -P  --prepare      Only perform the prepare step
#   -C  --cleanup      Only perform the cleanup step
#   -R  --runonly      Only perform the run step
#
# == Example
# Reads from MongoDB in a loop for 300 seconds using the simple tests
#   mongobench --read simple -m 1 -M 3
#
# == Author
# Tim Gourley (mailto:tgourley@engineyard.com)


require 'rubygems'
require 'optparse' 
require 'ostruct'
require 'mongo'

require File.expand_path('../../lib/mongoeval', __FILE__)

mb = MongoEval::Benchmark.new(ARGV, STDIN)
mb.main
