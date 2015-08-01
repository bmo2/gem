module Bmo2
  class Command
    class << self
      include Bmo2::Color

      def storage
        Bmo2.storage
      end

      def execute(*args)
        command = args.shift
        major   = args.shift
        minor   = args.empty? ? nil : args.join(' ')

        return overview unless command
        delegate(command, major, minor)
      end

      def output(s)
        puts(s)
      end

      def stdin
        $stdin
      end

      def overview
        storage.lists.each do |list|
          output "  #{list.name} (#{list.items.size})"
        end
        s =  "\e[32mYou don't have anything yet! To start out, create a new list:\e[0m"
        s << "\n$ bmo2 <list-name>"
        s << "\n\e[32mAnd then add something to your list!\e[0m"
        s << "\n$ bmo2 <list-name> <item-name> <item-value>"
        s << "\n\e[32mYou can then grab your new item:\e[0m"
        s << "\n$ bmo2 <item-name>"
        output s if storage.lists.size == 0
      end

      def all
        storage.lists.each do |list|
          output "  #{list.name}"
          list.items.each do |item|
            output "    #{item.short_name}:#{item.spacer} #{item.value}"
          end
        end
      end

      def delegate(command, major, minor)
        return all               if command == 'all'
        return edit              if command == 'edit'
        return version           if command == "-v"
        return version           if command == "--version"
        return help              if command == 'help'
        return help              if command[0] == 45 || command[0] == '-' # any - dash options are pleas for help
        return echo(major,minor) if command == 'echo' || command == 'e'
        return copy(major,minor) if command == 'copy' || command == 'c'
        return open(major,minor) if command == 'open' || command == 'o'
        return random(major)     if command == 'random' || command == 'rand' || command == 'r'

        if command == 'delete' || command == 'd'
          if minor
            return delete_item(major, minor)
          else
            return delete_list(major)
          end
        end

        if storage.list_exists?(command)
          return detail_list(command) unless major
          return add_item(command,major,minor) if minor
          return add_item(command,major,stdin.read) if stdin.stat.size > 0
          return search_list_for_item(command, major)
        end

        return search_items(command) if storage.item_exists?(command) and !major

        return create_list(command, major, stdin.read) if !minor && stdin.stat.size > 0
        return create_list(command, major, minor)
      end

      def detail_list(name)
        list = List.find(name)
        list.items.sort{ |x,y| x.name <=> y.name }.each do |item|
          output "    #{item.short_name}:#{item.spacer} #{item.value}"
        end
      end

      def echo(major, minor)
        unless minor
          item = storage.items.detect do |item|
            item.name == major
          end
          return output "#{cyan(major)} #{red("not found")}" unless item
        else
          list = List.find(major)
          item = list.find_item(minor)
          return output "#{cyan(minor)} #{red("not found in")} #{cyan(major)}" unless item
        end
        output item.value
      end

      def copy(major, minor)
        unless minor
          item = storage.items.detect do |item|
            item.name == major
          end
          return output "#{cyan(major)} #{red("not found")}" unless item
        else
          list = List.find(major)
          item = list.find_item(minor)
          return output "#{cyan(minor)} #{red("not found in")} #{cyan(major)}" unless item
        end
        Platform.copy(item)
      end

      def create_list(name, item = nil, value = nil)
        lists = (storage.lists << List.new(name))
        storage.lists = lists
        output "#{green("Bmo2")} Created a new list called #{cyan(name)}."
        save
        add_item(name, item, value) unless value.nil?
      end

      def delete_list(name)
        if storage.list_exists?(name)
          printf "You sure you want to delete everything in #{cyan(name)}? (y/n): "
          if $stdin.gets.chomp == 'y'
            List.delete(name)
            output "#{green("Bmo2")} Deleted all your #{cyan(name)}."
            save
          else
            output "Just kidding then."
          end
        else
          output "We couldn't find that list."
        end
      end

      def add_item(list,name,value)
        list = List.find(list)
        list.add_item(Item.new(name,value))
        output "#{green("Bmo2")} #{cyan(name)} in #{cyan(list.name)} is #{cyan(value)}. Got it."
        save
      end

      def delete_item(list_name,name)
        if storage.list_exists?(list_name)
          list = List.find(list_name)
          if list.delete_item(name)
            output "#{green("Bmo2")} #{cyan(name)} is gone forever."
            save
          else
            output "#{cyan(name)} #{red("not found in")} #{cyan(list_name)}"
          end
        else
          output "We couldn't find that list."
        end
      end

      def search_items(name)
        item = storage.items.detect do |item|
          item.name == name
        end

        output "#{green("Bmo2")} We just copied #{cyan(Platform.copy(item))} to your clipboard."
      end

      def search_list_for_item(list_name, item_name)
        list = List.find(list_name)
        item = list.find_item(item_name)

        if item
          output "#{green("Bmo2")} We just copied #{cyan(Platform.copy(item))} to your clipboard."
        else
          output "#{cyan(item_name)} #{red("not found in")} #{cyan(list_name)}"
        end
      end

      def save
        storage.save
      end

      def version
        output "You're running bmo2 #{Bmo::VERSION}. Congratulations!"
      end

      def edit
        output "#{green("Bmo2")} #{Platform.edit(storage.json_file)}"
      end

      def help
        text = %{\e[32m----------------------------------------------------------------------------\e[0m
          bmo2                          display high-level overview
          bmo2 all                      show all items in all lists
          bmo2 help                     this help text
          bmo2 <list>                   create/show a list
          bmo2 delete <list>            deletes a list

          bmo2 <list> <name> <value>    create a new list item
          bmo2 <name>                   copy item's value to clipboard
          bmo2 <list> <name>            copy item's value to clipboard
          bmo2 echo <name>              echo the item's value without copying
          bmo2 echo <list> <name>       echo the item's value without copying
          bmo2 copy <name>              copy the item's value without echo
          bmo2 copy <list> <name>       copy the item's value without echo
          bmo2 delete <list> <name>     deletes an item

          all other documentation is located at:
          https://github.com/bmo2/bmo
        }.gsub(/^ {8}/, '')
        output text
      end

    end
  end
end
