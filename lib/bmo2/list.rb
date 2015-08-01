module Bmo2
  class List
  
    def initialize(name)
      @items = []
      @name  = name
    end

    def self.storage
      Bmo2.storage
    end

    attr_accessor :items

    attr_accessor :name

    def add_item(item)
      delete_item(item.name) if find_item(item.name)
      @items << item
    end

    def self.find(name)
      storage.lists.find { |list| list.name == name } 
    end

    def self.delete(name)
      previous = storage.lists.size
      storage.lists = storage.lists.reject { |list| list.name == name }
      previous != storage.lists.size
    end

    def delete_item(name)
      previous = items.size
      items.reject! { |item| item.name == name}
      previous != items.size
    end

    def find_item(name)
      items.find do |item|
        item.name == name ||
        item.short_name.gsub('…','') == name.gsub('…','')
      end
    end

    def to_hash
      { name => items.collect(&:to_hash) }
    end

  end
end
