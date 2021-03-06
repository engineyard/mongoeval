module MongoEval
  class Benchmark
    VERSION = '0.1.0'
    attr_accessor :options, :collection, :mq
  
    # Set up the Mongoload class with default options
    def initialize(arguments, stdin)
      @arguments = arguments
      @stdin = stdin
      @options = OpenStruct.new
      @collection = 'mongobench_test_data'
    
      parse_options

      @mq = get_test_runner(@collection)
    end
  
  
    # Load the database collection with some test data
    def prepare
      puts "Populating #{@collection} with #{@options.documents} documents"
      @mq.populate_collection(@options.documents)
    end
  
    # Our main public method; do the actual work
    def run
      threads = []
      test_start = Time.now
      puts "Starting #{options.threads} worker threads at #{test_start}"
      @options.threads.times do |thread_id|
        threads << Thread.new do
          worker_thread(thread_id)
        end
      end
      threads.each { |t| t.join }
      test_end = Time.now
      puts "Total test time: #{test_end.to_f - test_start.to_f}"
    end
  
    def cleanup
      puts "Cleaning up database"
      @mq.purge_collection
    end
  
    def main
      case @options.step
      when :prepare
        prepare()
      when :cleanup
        cleanup()
      when :run
        run()
      when :all
        prepare()
        run()
        cleanup()
      end
    end
  
    protected
  
    # Create a specific number of threads and run the test until
    # the time limit has reached.
    def worker_thread(thread_id)
      mq = get_test_runner(@collection)
      start_time = Time.now
      averages = Array.new
      loop do
        # Break out of the loop if we've exceeded the max time, or if we've exceeded the max iterations (and iterations != 0)
        break if (Time.now.to_i >= (start_time.to_i + @options.time) || (@options.iterations != 0) ? averages.length >= @options.iterations : false)
        test_start_time = Time.now.to_f
        mq.send("#{@options.test}_test".to_sym, thread_id)
        test_end_time = Time.now.to_f
        averages << test_end_time - test_start_time
        # sleeping_for = (rand(@options.max) + @options.min).to_i
        # sleep(sleeping_for)
      end
      average = averages.inject { |sum, el| sum + el}.to_f / averages.size
      puts "Worker thread #{thread_id} run time: #{Time.now.to_i - start_time.to_i} - iterations: #{averages.length} - average: #{average}"
    end
  
  
    # Parse valid command line options passed to the script.
    # This also sets up the actions to be taken for various
    # options.
    def parsed_options?
      opts = OptionParser.new
      opts.on('-v', '--version')  { output_version; exit 0 }
      opts.on('-h', '--help')     { output_usage }
    
      opts.on('-r', '--run s', String)        { |test| @options.test = test }
      opts.on('-m', '--min-sleep i', Integer) { |min| @options.min = min }
      opts.on('-M', '--max-sleep i', Integer) { |max| @options.max = max }
      opts.on('-H', '--host s', String)       { |host| @options.host = host }    
      opts.on('-d', '--db s', String)         { |db| @options.db = db }
      opts.on('-p', '--port i', Integer)      { |port| @options.port = port }
      opts.on('-u', '--user s', String)       { |user| @options.user = user }
      opts.on('-w', '--password s', String)   { |password| @options.password = password }
      opts.on('-t', '--time i', Integer)      { |time| @options.time = time }
      opts.on('-T', '--threads i', Integer)   { |threads| @options.threads = threads }
      opts.on('-D', '--documents i', Integer) { |documents| @options.documents = documents }
      opts.on('-i', '--iterations i', Integer){ |iterations| @options.iterations = iterations }
    
      opts.on('-P', '--prepare') { @options.step = :prepare }
      opts.on('-C', '--cleanup') { @options.step = :cleanup }
      opts.on('-R', '--runonly') { @options.step = :run }
      opts.on('-A', '--all')     { @options.step = :all }
    
      opts.parse!(@arguments) rescue return false
      true
    end
  
    # Sanity check the arguments
    def arguments_valid?
      valid_args = true
      valid_args = false if @options.min > @options.max
      valid_args = false if @options.user && !@options.password
      valid_args = false if @options.password && !@options.user
      valid_args
    end
  
    # Show the usage statement
    def output_usage
      output_version
      RDoc::usage_no_exit('usage') # gets usage from comments above
      puts "Available tests: #{MongoQueries.tests.join(', ')}\n"
      exit 1
    end
  
    # Output the version of the script
    def output_version
      puts "#{File.basename(__FILE__)} version #{VERSION}"
    end
  
  
    private
  
    # Load our options and make sure they are sane
    def parse_options
      set_defaults
      unless parsed_options? && arguments_valid?
        output_usage
        exit 1
      end
    end
  
    # Set the default options for the script. 
    def set_defaults    
      @options.test = 'simple'
      @options.min = 0
      @options.max = 5
      @options.host = 'localhost'
      @options.port = 27017
      @options.db = 'mongobench_test'
      @options.time = 300
      @options.threads = 1
      @options.documents = 20000
      @options.iterations = 0
      @options.step = :all
    end
  
    def get_connection
      user_string = " as user #{@options.user}" if @options.user
      puts "Connecting to MongoDB instance on #{@options.host}:#{@options.port}#{user_string}..."
      # :pool_size option removed for now -- connection pooling does not send auth credentials as of 1.2.4
      database = Mongo::Connection.new(@options.host, @options.port).db(@options.db)    

      if (@options.user && @options.password)
        auth = database.authenticate(@options.user, @options.password)
        if !auth
          puts "Invalid username/password for user #{@options.user}"
          exit 1
        end
      end
    
      database
    end
  
    def get_test_runner(collection, database=nil)
      database = get_connection() if database.nil?
      mq = ::MongoEval::Queries.new(database, :collection => collection)   
      if !mq.respond_to?("#{@options.test}_test".to_sym)
        puts "Invalid test #{@options.test}. Valid choices are: #{MongoQueries.tests.join(', ')}"
        exit 1
      end    
      mq
    end
  end
end