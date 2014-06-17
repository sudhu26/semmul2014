# encoding: utf-8

require "linkeddata"

# Class Writer allows write access to a triple store.
class DBpediaCrawler::Writer

private

  # Create SPARQL code to insert the given triples in the triple store.
  #
  # This is a workaround. Actually, the following should work:
  #   @client.insert_data(data, graph: @graph)
  # but it does not, probably because InsertData#to_s is flawed.
  def update_query(data)
    update = "INSERT DATA INTO <" + @graph + "> {"
    update += RDF::NTriples::Writer.buffer({validate: false}) do |writer|
      writer << data
    end
    update += " }"

    return update
  end

public

  # Create a new Writer
  #   configuration: hash
  def initialize(configuration)
    @config = configuration
    @client = SPARQL::Client.new @config["endpoint"]
    @graph = @config["graph"]
  end

  # Insert all statements in the given graph into this Writer's graph of 
  # this Writer's data store.
  #   data: RDF::Graph
  #   raises: StandardError if update fails
  def insert(data)
    begin
      @client.query update_query(data)
    rescue StandardError => e
      puts "# Error while updating triple store:"
      puts e.message, e.backtrace
      raise "update failed"
    end
   end

end
