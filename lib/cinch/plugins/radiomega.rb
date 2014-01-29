# -*- coding: utf-8 -*-
require 'cinch'
require 'cinch/toolbox'
require 'jist'

module Cinch::Plugins
  class Radiomega
    include Cinch::Plugin

    match /(.+) - (.+)/
    set :prefix, /\A\+\+/

    def initialize(*args)
      super
      @gist = { id:   config[:gist_id],
                user: config[:gist_user] }
    end

    def execute(m, title, artist)
      current = get_today_gist
      current << build_song_string(m, title, artist)

      Jist.gist(current.join("\n"),
                filename: "#{date_text}.txt",
                update:   @gist[:id])
    end

    private

    def build_song_string(m, title, artist)
      nick = m.user.nick
      time = m.time.strftime("%R")
      "#{time} < #{nick}> ++ #{title} - #{artist}"
    end

    def get_today_gist
      # Get the gist contents for today's list
      raw_url = Cinch::Toolbox.get_html_element(gist_url,
                                                "##{gist_file_name} a.raw-url",
                                                :css_full)
      return [] if raw_url.nil?

      raw_url = 'https://gist.github.com' + raw_url[/href=\"(.+)"\s/, 1]
      open(raw_url).read.split("\n")
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
