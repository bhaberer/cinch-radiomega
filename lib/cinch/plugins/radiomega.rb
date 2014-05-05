# -*- coding: utf-8 -*-
require 'cinch'
require 'cinch/toolbox'
require 'jist'
require 'net/http'
require 'uri'

module Cinch::Plugins
  # Cinch plugin to gist songs
  class Radiomega
    include Cinch::Plugin

    match /(.+) - (.+)/,  prefix: /\A\+\+\s/,
                          method: :log_song
    match /setlist/,      method: :setlist

    def initialize(*args)
      super
      @play_url = config[:play_url]
    end

    def setlist(m)
      m.user.notice 'The setlist for today is at ' +
                    'http://radiomega.herokuapp.com/setlists/today'
    end

    def log_song(m, title, artist)
      submit_play_info(artist, title, m.user.nick)
    end

    private

    def submit_play_info(artist, title, nick)
      uri = URI.parse(@play_url)
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = JSON.generate(artist: artist, title: title, nick: nick)
      request['Content-Type'] = 'application/json'
      response = http.request(request)
      debug response.body.to_s
    end

    def build_song_string(m, title, artist)
      nick = m.user.nick
      time = m.time.strftime('%R')
      [time, "<#{nick}>", '++', title, '-', artist].join(' ')
    end

    def date_text
      Time.now.strftime('%Y.%m.%d')
    end
  end
end
