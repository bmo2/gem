module Bmo2
  class Storage
    JSON_FILE = "#{ENV['HOME']}/.bmo2"

    def json_file
      ENV['BMO2MFILE'] || JSON_FILE
    end

    def initialize
      @lists = []
      bootstrap
      populate
    end

    attr_writer :lists

    def lists
      @lists.sort_by { |list| -list.items.size }
    end

    def list_exists?(name)
      @lists.detect { |list| list.name == name }
    end

    def items
      @lists.collect(&:items).flatten
    end

    def item_exists?(name)
      items.detect { |item| item.name == name }
    end

    def to_hash
      { :lists => lists.collect(&:to_hash) }
    end

    def bootstrap
      return if File.exist?(json_file) and !File.zero?(json_file)
      FileUtils.touch json_file
      File.open(json_file, 'w') {|f| f.write(to_json) }
      save
    end

    def populate
      file = File.new(json_file, 'r')
      storage = Yajl::Parser.parse(file)

      storage['lists'].each do |lists|
        lists.each do |list_name, items|
          @lists << list = List.new(list_name)

          items.each do |item|
            item.each do |name,value|
              list.add_item(Item.new(name,value))
            end
          end
        end
      end
    end

    def save
      File.open(json_file, 'w') {|f| f.write(to_json) }
    end

    def to_json
      Yajl::Encoder.encode(to_hash, :pretty => true)
    end
  end
end
