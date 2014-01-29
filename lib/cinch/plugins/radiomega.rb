# -*- coding: utf-8 -*-
require 'cinch'

module Cinch::Plugins
  class Radiomega
    listen_to :channel

    match /(.+) - (.+)/
    set :prefix, /\A\+\+/

    def execute(m, title, artist)
      m.reply 'You linked ' + artist + ' - ' + title
    end
  end
end
