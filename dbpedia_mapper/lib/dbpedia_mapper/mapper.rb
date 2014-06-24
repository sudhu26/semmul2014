require 'yaml'
# require 'themoviedb'

class DBpediaMapper::Mapper
  Base = "http://example.com/"
  Lom = "http://www.hpi.uni-potsdam.de/semmul2014/lodofmovies.owl#"
  Schema = "http://schema.org/"
  Dbpedia = "http://dbpedia.org/ontology/"
  Dbprop = "http://dbpedia.org/property/"
  Rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  Rdfs = "http://www.w3.org/2000/01/rdf-schema#"
  Owl = "http://www.w3.org/2002/07/owl#"
  Foaf = "http://xmlns.com/foaf/spec/"

  Type = "#{Rdf}type"

  Object_mappings = {
    "#{Owl}Thing" => "#{Schema}Thing",
    "#{Dbpedia}Work" => "#{Schema}CreativeWork",
    "#{Dbpedia}Film" => "#{Schema}Movie",
    "#{Dbpedia}TelevisionShow" => "#{Schema}TVSeries",
    "#{Dbpedia}TelevisionSeason" => "#{Schema}TVSeason",
    "#{Dbpedia}TelevisionEpisode" => "#{Schema}Episode",
    "#{Foaf}Person" => "#{Schema}Person",
    "#{Dbpedia}Person" => "#{Schema}Person",
    
    "#{Dbpedia}Actor" => "#{Dbpedia}Actor",
    "#{Dbpedia}FictionalCharacter" => "#{Dbpedia}FictionalCharacter",
    
    "#{Schema}Thing" => "#{Schema}Thing",
    "#{Schema}CreativeWork" => "#{Schema}CreativeWork",
    "#{Schema}Movie" => "#{Schema}Movie",
    "#{Schema}TVSeries" => "#{Schema}TVSeries",
    "#{Schema}TVSeason" => "#{Schema}TVSeason",
    "#{Schema}Episode" => "#{Schema}Episode",
    "#{Schema}Person" => "#{Schema}Person",
  }

  def initialize
    
  end

  # def has_mapping(subject, predicate)
  #   mapping_subject = ["#{owl}Thing", "#{dbpedia}Work", "#{dbpedia}Film", "#{dbpedia}TelevisionShow", "#{dbpedia}TelevisionSeason", "#{dbpedia}TelevisionEpisode", "#{foaf}Person", "#{dbpedia}Person", "#{dbpedia}Actor", "#{dbpedia}FictionalCharacter"]
  #   mapping_predicate = ["#{dbprop}name", "#{foaf}name", "#{owl}sameAs", "#{dbpedia}releaseDate", "#{dbprop}releaseDate", "#{dbpedia}director", "#{dbprop}director", "#{dbpedia}distributor", "#{dbprop}distributor", "#{dbprop}studio", "#{dbprop}firstAired", "#{dbprop}lastAired", "#{dbpedia}numberOfSeasons", "#{dbprop}numSeasons", "#{dbpedia}numberOfEpisodes", "#{dbprop}numEpisodes", "#{dbprop}episodeList", "#{dbpedia}series", "#{dbpedia}episodeNumber", "#{dbprop}episode", "#{dbpedia}seasonNumber", "#{dbprop}season", "#{foaf}givenName", "#{foaf}surname", "#{dbpedia}birthDate", "#{dbprop}birthDate", "#{dbpedia}birthPlace", "#{dbprop}placeOfBirth", "#{dbpedia}starring", "#{dbprop}starring"]

  #   return true if mapping_subject.include? subject and mapping_predicate.include? predicate
  #   puts "Will not be mapped:\n (subject) #{subject} \n (predicate) #{predicate}"
  #   false
  # end

  def mapped_object(object)
    mo = Object_mappings["#{object}"]
    return "#{mo}"
  end

  # TODO do not take triples separately but each entity as a whole
  # TODO (Ctd) in that way, we know e.g. the ID of a cast
  # TODO therefore I have to know how the RAW data of TMDb is exactly stored in Virtuoso
  # TODO map/merge duplicated entities
  # TODO find sameAs links to existing entities (e.g. Brad Pitt on dbpedia)
  # TODO map Places or find existing places on dbpedia and define sameAs
  # TODO add "@en" to literals?
  # TODO is DateTime recognized as xsd:date? or how should we store the date in triples?
  # TODO is storing an integer/decimal as literal enough? should we add another triple to define the type?
  def map(subject, predicate, object)

    case predicate
    when Type
      mo = mapped_object(object)
      if mo != nil and mo != ""
        p "#{object}"
        p "#{mo}"
        v = DBpediaMapper::Virtuoso.new
        v.write_mapped(subject, Type, mo)
        # p "#{subject}     #{predicate}     #{object}"
      end
    end

    # case subject
    #   when "#{tmdb}Movie"
    #     case predicate
    #       when "#{tmdb}movie/title" or "#{tmdb}tv/name"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Movie", "#{schema}name", object
    #       when "#{tmdb}movie/release_date" or "#{tmdb}tv/season/air_date" or "#{tmdb}tv/season/episode/air_date"
    #         date = object.split('-')
    #         puts "Other date format: {object}" if date.length != 3
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Movie", "#{schema}datePublished", DateTime.new(date.first, date[1], date.last)
    #       when "#{tmdb}movie/production_companies"
    #         entity = "#{base}Movie/#{id}/productionCompany/#{object}"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Movie", "#{schema}productionCompany", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{schema}Organization"
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{schema}name", object
    #       when "#{tmdb}cast/character"
    #         # TODO ID of cast should be used for URIs
    #         entity = "#{base}Movie/#{id}/cast/#{object}"
    #         entity2 = "#{base}Movie/#{id}/cast/#{object}/character"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Movie", "#{lom}performance", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{lom}Performance"
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{lom}character", entity2
    #         TMDbMapper::VirtuosoWriter.new_triple entity2, "#{rdf}type", "#{dbpedia}FictionalCharacter"
    #         TMDbMapper::VirtuosoWriter.new_triple entity2, "#{schema}name", object
    #       when "#{tmdb}cast/name"
    #         # TODO ID of cast should be used for URIs (so that character and actor reference the the same performance)
    #         entity = "#{base}Movie/#{id}/cast/#{object}"
    #         entity2 = "#{base}Movie/#{id}/cast/#{object}/actor"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Movie", "#{lom}performance", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{lom}Performance"
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{lom}actor", entity2
    #         TMDbMapper::VirtuosoWriter.new_triple entity2, "#{rdf}type", "#{dbpedia}Actor"
    #         TMDbMapper::VirtuosoWriter.new_triple entity2, "#{schema}name", object
    #         name = object.split(' ')
    #           # TODO use all names (currently only first token is used as given and last token is used as family name)
    #         TMDbMapper::VirtuosoWriter.new_triple entity2, "#{schema}givenName", name.first
    #         TMDbMapper::VirtuosoWriter.new_triple entity2, "#{schema}familyName", name.last
    #       when "#{tmdb}crew/job" and object.to_s.include? "Director"
    #         entity = "#{base}Movie/#{id}/director/#{object}"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Movie", "#{schema}director", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{lom}Director"
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{schema}name", object
    #         name = object.split(' ')
    #         # TODO use all names (currently only first token is used as given and last token is used as family name)
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{schema}givenName", name.first
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{schema}familyName", name.last
    #     end

    #   when "#{tmdb}TV"
    #     case predicate
    #       when "#{tmdb}tv/first_air_date"
    #         date = object.split('-')
    #         puts "Other date format: {object}" if date.length != 3
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}TVSeries", "#{schema}startDate", DateTime.new(date.first, date[1], date.last)
    #       when "#{tmdb}tv/last_air_date"
    #         date = object.split('-')
    #         puts "Other date format: {object}" if date.length != 3
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}TVSeries", "#{schema}endDate", DateTime.new(date.first, date[1], date.last)
    #       when "#{tmdb}tv/seasons"
    #         # TODO what contains 'object' in case of season? does it make sense to name the entity like that?
    #         # TODO would be good to use ID for URI
    #         entity = "#{base}TVSeries/#{id}/season/#{object}"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}TVSeries", "#{schema}season", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{schema}TVSeason"
    #         # TODO maybe an ID or name of season should be stored in triple as well to map identical seasons later once
    #         # TODO (Ctd.) but how can we get the ID or name?
    #       when "#{tmdb}tv/number_of_seasons"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}TVSeries", "#{schema}numberOfSeasons", object
    #       when "#{tmdb}tv/number_of_episodes"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}TVSeries", "#{schema}numberOfEpisodes", object
    #     end

    #   when "#{tmdb}TV_Season"
    #     case predicate
    #       when "#{tmdb}tv/season/season_number"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}TVSeason", "#{schema}seasonNumber", object
    #       when "#{tmdb}tv/season/episodes"
    #         # TODO what contains 'object' in case of episode? does it make sense to name the entity like that?
    #         # TODO would be good to use ID for URI
    #         entity = "#{base}TVSeries/#{id}/season/episode/#{object}"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}TVSeason", "#{schema}episode", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{schema}Episode"
    #         # TODO maybe an ID or name of episode should be stored in triple as well to map identical seasons later once
    #         # TODO (Ctd.) but how can we get the ID or name?
    #     end

    #   when "#{tmdb}TV_Episode"
    #     case predicate
    #       when "#{tmdb}tv/season/episode/episode_number"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Episode", "#{schema}episodeNumber", object
    #       when "#{tmdb}tv/season/episode/season_number"
    #         entity = "#{base}TVSeries/#{id}/season/#{object}"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Episode", "#{schema}partOfSeason", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{schema}TVSeason"
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{schema}seasonNumber", object
    #     end

    #   when "#{tmdb}Person"
    #     case predicate
    #       when "#{tmdb}person/birthday"
    #         date = object.split('-')
    #         puts "Other date format: {object}" if date.length != 3
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Person", "#{schema}birthDate", DateTime.new(date.first, date[1], date.last)
    #       when "#{tmdb}person/place_of_birth"
    #         entity = "#{base}Person/#{id}/birthPlace/#{object}"
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Person", "#{dbpedia}birthPlace", entity
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdf}type", "#{dbpedia}Place"
    #         TMDbMapper::VirtuosoWriter.new_triple entity, "#{rdfs}label", object
    #       when "#{tmdb}person/name"
    #         name = object.split(' ')
    #         # TODO use all names (currently only first token is used as given and last token is used as family name)
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Person", "#{schema}givenName", name.first
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Person", "#{schema}familyName", name.last
    #         # complete name is mapped to 'name'
    #         TMDbMapper::VirtuosoWriter.new_triple "#{schema}Person", "#{schema}name", object
    #     end
    # end
  end

  private
  def secrets
    @secrets ||= YAML.load_file '../config/secrets.yml'
  end
end