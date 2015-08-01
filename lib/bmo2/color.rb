module Bmo2
  module Color
    extend self

    CODES = {
      :reset   => "\e[0m",
      :cyan    => "\e[36m",
      :magenta => "\e[35m",
      :red     => "\e[31m",
      :green   => "\e[32m",
      :yellow  => "\e[33m"
    }

    def self.included(other)
      if RUBY_PLATFORM =~ /win32/ || RUBY_PLATFORM =~ /mingw32/
        require 'Win32/Console/ANSI'
      end
    rescue LoadError
    end

    def colorize(string, color_code)
      if !defined?(Win32::Console) && !!(RUBY_PLATFORM =~ /win32/ || RUBY_PLATFORM =~ /mingw32/)
        return string
      end
      "#{CODES[color_code] || color_code}#{string}#{CODES[:reset]}"
    end

    self.class_eval(CODES.keys.reject {|color| color == :reset }.map do |color|
      "def #{color}(string); colorize(string, :#{color}); end"
    end.join("\n"))
  end
end
