# Copyright (C) Thomas Chace 2011-2012 <tchacex@gmail.com>
# This file is part of Post.
# Post is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Post is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with Post.  If not, see <http://www.gnu.org/licenses/>.

require(File.join(File.dirname(__FILE__), "packagedata.rb"))
require('fileutils')

class Erase
    include FileUtils
    def initialize(queue)
        @queue = queue
        @database = PackageDataBase.new()
    end

    def get_queue()
        @queue
    end

    def build_queue(package)
        @queue.set(package) if @database.installed?(package)
    end

    def remove_package(package)
        remove_script = @database.get_remove_script(package)

        package_files = @database.get_files(package)
        @database.remove_package(package)

        package_files.each() do |file|
            root = @database.get_root()
            file = "#{root}/#{file.strip()}"
            if (FileTest.exists?("#{file}"))
                rm(file)
            end
        end
        eval(remove_script)
    end
end
