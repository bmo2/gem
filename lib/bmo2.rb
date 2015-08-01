# coding: utf-8

begin
  require 'rubygems'
rescue LoadError
end

require 'fileutils'
require 'yajl'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'bmo2/color'
require 'bmo2/platform'
require 'bmo2/command'
require 'bmo2/item'
require 'bmo2/list'
require 'bmo2/storage'

require 'bmo2/ext/symbol'

module Bmo2
  VERSION = '0.1.0'

  def self.storage
    @storage ||= Storage.new
  end
end
