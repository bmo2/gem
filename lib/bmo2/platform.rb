module Bmo2
  class Platform
    class << self
      def cygwin?
        !!(RbConfig::CONFIG['host_os'] =~ /cygwin/)
      end
      def darwin?
        !!(RbConfig::CONFIG['host_os'] =~ /darwin/)
      end

      def windows?
        !!(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/)
      end

      def open_command
        if darwin?
          'open'
        elsif windows?
          'start'
        elsif cygwin?
          'cygstart'
        else
          'xdg-open'
        end
      end

      def open(item)
        unless windows?
          system("#{open_command} '#{item.url.gsub("\'","'\\\\''")}'")
        else
          system("#{open_command} #{item.url.gsub("\'","'\\\\''")}")
        end

        item.value
      end

      def copy_command
        if darwin?
          'pbcopy'
        elsif windows? || cygwin?
          'clip'
        else
          'xclip -selection clipboard'
        end
      end

      def copy(item)
        begin
          IO.popen(copy_command,"w") {|cc|  cc.write(item.value)}
          item.value
        rescue Errno::ENOENT
          puts item.value
          puts "Please install #{copy_command[0..5]} to copy this item to your clipboard"
          exit
        end
      end

      def edit(json_file)
        unless ENV['EDITOR'].nil?
          unless windows?
            system("`echo $EDITOR` #{json_file} &")
          else
            system("start %EDITOR% #{json_file}")
          end
        else
          system("#{open_command} #{json_file}")
        end

        "Make your edits, and do be sure to save."
      end
    end
  end
end
