# -*- coding: utf-8 -*-
require 'cinch'
require 'cinch/toolbox'
require 'jist'

module Cinch::Plugins
  # Cinch plugin to gist songs
  class Radiomega
    include Cinch::Plugin

    match /(.+) - (.+)/,  prefix: /\A\+\+\s/,
                          method: :log_song
    match /setlist/,      method: :setlist

    def initialize(*args)
      super
      @gist = { id:   config[:gist_id],
                user: config[:gist_user] }
    end

    def setlist(m)
      url = [gist_url, gist_file_name].join('#')
      m.user.notice "The setlist for today is at #{url}"
    end

    def log_song(m, title, artist)
      current = get_today_gist
      current << build_song_string(m, title, artist)

      Jist.gist(current.join("\n"),
                filename: "#{date_text}.txt",
                update:   @gist[:id])
    end

    private

    def build_song_string(m, title, artist)
      nick = m.user.nick
      time = m.time.strftime('%R')
      [time, "<#{nick}>", '++', title, '-', artist].join(' ')
    end

    def get_today_gist
      # Get the gist contents for today's list
      raw_url = Cinch::Toolbox.get_html_element(gist_url,
                                                "##{gist_file_name} a.raw-url",
                                                :css_full)

      raw_url = 'https://gist.github.com' + raw_url[/href=\"(.+)"\s/, 1]
      open(raw_url).read.split("\n")
    rescue NoMethodError
      []
    end

    def gist_url
      "https://gist.github.com/#{@gist[:user]}/#{@gist[:id]}"
    end

    def gist_file_name(date = date_text)
      "file-#{date.gsub(/\./, '-')}-txt"
    end

    def date_text
      Time.now.strftime('%Y.%m.%d')
    end
  end
end
