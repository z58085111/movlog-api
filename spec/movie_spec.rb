# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Movie Routes' do
  before do
    VCR.insert_cassette MOVIES_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Find movie by keyword' do
    before do
      # TODO: find a better way
      DB[:movies].delete
      DB[:locations].delete
      LoadMoviesFromOMDB.call(HAPPY_MOVIE)
    end

    it '(HAPPY) should find valid keyword movies' do
      magic_word = SpecSearch.random_title_word
      get "api/v0.1/movie?search=#{magic_word[:word]}"
      puts magic_word[:word]
      last_response.status.must_equal 200
      results = JSON.parse(last_response.body)
      results['search_terms'].count.must_equal 1
    end

    it '(HAPPY) should find valid keyword combination movies' do
      magic_words = Array.new(3) { SpecSearch.random_title_word }
      keywords = magic_words.map { |magic| magic[:word] }.join('+')
      largest_count = magic_words.map { |magic| magic[:messages_count] }.max

      get "api/v0.1/movie?search=#{keywords}"
      last_response.status.must_equal 200
      results = JSON.parse(last_response.body)
      results['search_terms'].count.must_equal magic_words.count
    end
  end

  describe 'Loading and saving a new movie by movie name' do
    before do
      DB[:movies].delete
      DB[:locations].delete
    end

    it '(HAPPY) should load and save a new movie by its title' do
      LoadMoviesFromOMDB.call(HAPPY_MOVIE)
      Movie.count.must_be :>=, 1
      Location.count.must_be :>=, 1
    end

    it '(BAD) should report error if given invalid title' do
      LoadMoviesFromOMDB.call(SAD_MOVIE_URL)
      Movie.count.must_be :==, 0
    end

    it 'should report error if movie already exists' do
      LoadMoviesFromOMDB.call(HAPPY_MOVIE)
      first_count = Movie.count
      LoadMoviesFromOMDB.call(HAPPY_MOVIE)
      Movie.count.must_be :>=, first_count
    end
  end
end
