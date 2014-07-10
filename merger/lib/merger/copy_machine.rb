require 'set'

class Merger::CopyMachine
  attr_reader :map_db_uri, :main_db_uri

  def initialize(mapped_movie_uri, type: :generic, generate_new_uri: true)
    @map_db_uri = mapped_movie_uri
    @main_db_uri = if generate_new_uri
                     Merger::URIGenerator.new_uri for_type: type
                   else
                     mapped_movie_uri
                   end
  end

  def process
    copy_entity_with_literals @map_db_uri, @main_db_uri
    @main_db_uri
  end

  private
  def copy_entity_with_literals(map_db_uri, new_main_db_uri)
    copy_literals(map_db_uri, new_main_db_uri)
    copy_entities(map_db_uri, new_main_db_uri)
  end

  def copy_literals(map_db_uri, new_main_db_uri)
    results = virtuoso_reader.get_predicates_and_objects_for subject: map_db_uri, filter: ['isLiteral(?o)']
    results.each do |result|
      virtuoso_writer.new_triple new_main_db_uri, result[:p], result[:o]
    end
  end

  def copy_entities(map_db_uri, new_main_db_uri)
    results = virtuoso_reader.get_predicates_and_objects_for subject: map_db_uri, filter: ['isURI(?o)']
    results.each do |result|
      merged_uri = Merger::Merger.merge result[:o]
      virtuoso_writer.new_triple new_main_db_uri, result[:p], merged_uri, literal: false
    end
  end


  def take_next_uri!
    taken = @found_uris.take(1)
    @found_uris.subtract taken unless taken.empty?
    taken.first
  end

  def map_db_uri_for(uri)
    @map_db_uris[uri] ||= Merger::URIGenerator.new_uri for_type: :generic
  end

  def virtuoso_writer
    @virtuoso_writer ||= VirtuosoWriter.new
  end

  def virtuoso_reader
    @virtuoso_reader ||= VirtuosoReader.new
  end
end

# MonkeyPatch Set to add take_one!
# class Set
#   def take!(args)
#     taken = self.take args
#     self.subtract taken
#     taken
#   end
#
#   def take_one!
#     self.take!(1).first
#   end
# end