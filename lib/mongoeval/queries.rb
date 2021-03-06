module MongoEval
  class Queries
    attr_accessor :database, :collection, :words
  
    def initialize(dbobj, options = {})
      @database = dbobj
      collection = (!options[:collection].nil?) ? options[:collection] : 'mongobench_test_data'
      @collection = @database.collection(collection)
    end
  
    def self.tests
      MongoQueries.public_instance_methods.select {|x| x.match(/^(\w+)_test$/) }.map {|y| y.gsub(/\_test/,'') }
    end
  
    def populate_collection(num_documents)
      # Example document:
      # { _id: 12345, k: 12345, c: 'random', tags: [ 'rand', 'rand' 'rand' ] emb: [ { k: 12345, c: 'random', tags: [ 'rand', 'rand' 'rand' ] } ] }
      num_documents.times do |doc|
        document = { 
          :k => doc, :c => random_word, :tags => generate_tags(rand(5)), 
          :emb => [ :k => doc, :c => random_word, :tags => generate_tags(rand(5)) ]
        }
        @collection.insert(document)
      end
      # Create necessary indexes
      @collection.create_index('k') # Index the k column. Why not?
    end
  
    def purge_collection
      @collection.drop()
    end
  
    def simple_test(id)
      document = @collection.find_one()
    end
  
    def indexed_find_test(id)
      documents = @collection.find( { "k" => 12345 })
    end
  
    def nonindexed_find_test(id)
      documents = @collection.find( { "c" => 'lorem' })
    end
  
    def indexed_mapreduce_test(id)
      map_fn = "function(){ emit(this.k, 1)}"
      reduce_fn ="function(k,vals) { return 1; }"
      mr_collection = @collection.map_reduce(map_fn, reduce_fn, { :query => { 'k' => { '$gt' => 10 } } } )
      mr_collection.drop()
    end  
  
    def nonindexed_mapreduce_test(id)
      map_fn = "function(){ this.tags.forEach(function(z){ emit(z, { count : 1 }); });};"
      reduce_fn ="function(key, values) { var total = 0; for (var i=0; i<values.length; i++) {total += values[i].count; } return { count : total };};"
      mr_collection = @collection.map_reduce(map_fn, reduce_fn)
      mr_collection.drop()
    end

  
    private 
  
    def generate_tags(length)
      tags = Array.new
      length.times { tags << random_word }
      tags
    end
  
    def random_word
      @words ||= %w{ 
        lorem ipsum dolor sit amet consectetur adipiscing elit donec tristique ullamcorper sapien non porttitor 
        baoreet fringilla suspendisse et metus aliquam consectetur augue lacus non dapibus arcu cum sociis natoque 
        penatibus magnis dis parturient montes nascetur ridiculus mus donec eu luctus arcu 
      }
      @words[rand(@words.length)]
    end
  end
end