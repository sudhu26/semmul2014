#!/usr/bin/env ruby
require 'yaml'
require 'rdf/virtuoso'

class FreebaseUpdater::VirtuosoWriter
  def initialize
    @repo = RDF::Virtuoso::Repository.new('http://localhost:8890/sparql',
                                           update_uri: 'http://localhost:8890/sparql-auth',
                                           username: secrets['databases']['virtuoso']['username'],
                                           password: secrets['databases']['virtuoso']['password'],
                                           auth_method: 'digest')
  end

  def new_triple(subject, predicate, object, graph: 'http://example.com/raw', literal: true)
    graph = RDF::URI.new(graph)
    subject = RDF::URI.new(subject)
    predicate = RDF::URI.new(predicate)
    object = RDF::URI.new(object) unless literal

    query = RDF::Virtuoso::Query.insert([subject, predicate, object]).graph(graph)
    p @repo.insert(query)
  end

  private
  def secrets
    @secrets ||= YAML.load_file '../config/secrets.yml'
  end
end