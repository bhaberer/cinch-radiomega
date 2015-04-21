# -*- coding: utf-8 -*-
require 'cinch'
require 'cinch/toolbox'
require 'net/http'
require 'uri'
require 'json'

module Cinch
  module Plugins
    # Cinch plugin to gist songs
    class Radiomega
      include Cinch::Plugin

      match(/(.+) - (.+)/, prefix: /\A\+\+\s/, method: :log_song)
      match(/setlist/, method: :setlist)
      match(/email (.+)/, method: :email)

      def initialize(*args)
        super
        @host = config[:host]
        @play_url = "#{@host}/api/play"
        @nick_url = "#{@host}/api/nicks"
        @register_url = "#{@host}/api/register"
        @scratch_url = "#{@host}/api/scratch"
      end

      def setlist(m)
        m.user.notice 'The setlist for today is at '\
                      "#{@host}/setlists/today"
      end

      def log_song(m, title, artist)
        if m.channel.nil?
          if submit_scratch_track(artist, title, m.user.nick)
            m.reply "Track added to your scratchpad, see it at #{@host}/scratch"
          else
            m.reply "You're sending me a play from private, but you've not "\
                    "told me your email address on the site. Please tell me "\
                    "your email address with '.email whatever@place.com' so "\
                    "I can add this to your scratchpad."
          end
        else
          submit_play_info(artist, title, m.user.nick)
        end
      end

      def email(m, email)
        if submit_email(m.user.nick, email)
          m.reply "You're all set, you can add scratch tracks now!"
        else
          m.reply "That email's already been registered, or you don't have "\
                  "an account on #{@host}."
        end
      end

      private

      def submit_scratch_track(artist, title, nick)
        if registered_nicks.include?(nick)
          result = post_info({ artist: artist, title: title, nick: nick }, @scratch_url)
          debug "#{result.body}"
          result.code == '200'
        else
          false
        end
      end

      def post_info(data, url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)

        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = JSON.generate(data)
        request['Content-Type'] = 'application/json'
        response = http.request(request)
        response
      end

      def submit_play_info(artist, title, nick)
        post_info({ artist: artist, title: title, nick: nick }, @play_url)
      end

      def submit_email(nick, email)
        request = post_info({ email: email, nick: nick }, @register_url)
        request.code == '200'
      end

      def build_song_string(m, title, artist)
        nick = m.user.nick
        time = m.time.strftime('%R')
        [time, "<#{nick}>", '++', title, '-', artist].join(' ')
      end

      def registered_nicks
        uri = URI.parse(@nick_url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        JSON.parse(response.body)
      end

      def date_text
        Time.now.strftime('%Y.%m.%d')
      end
    end
  end
end
