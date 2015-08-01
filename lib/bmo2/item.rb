module Bmo2
  class Item
    attr_accessor :name
    attr_accessor :value

    def initialize(name,value)
      @name = name
      @value = value
    end

    def short_name
      name.length > 15 ? "#{name[0..14]}…" : name[0..14]
    end

    def spacer
      name.length > 15 ? '' : ' '*(15-name.length+1)
    end

    def url
      @url ||= value.split(/\s+/).detect { |v| v =~ %r{\A[a-z0-9]+:\S+}i } || value
    end

    def to_hash
      { @name => @value }
    end
  end
end