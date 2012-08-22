# Copyright (C) Thomas Chace 2011-2012 <ithomashc@gmail.com>
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

directory = File.dirname(__FILE__)
path = File.expand_path(directory)

require(File.join(path, "packagedata.rb"))

class MissingFile < Exception
end

class Erase
    def initialize(queue)
        @queue = queue
        @package_data_base = PackageDataBase.new()
    end

    def get_queue()
        return @queue
    end

    def build_queue(package)
        @queue.set(package) if @package_data_base.installed?(package)
    end

    def remove_package(package)
        remove_script = @package_data_base.get_remove_script(package)

        package_files = @package_data_base.get_files(package)
        @package_data_base.remove_package(package)

        package_files.each() do |file|
            if (FileTest.exists?(file))
                FileUtils.rm("#{@package_data_base.get_root()}/#{file.delete("\n")}")
            end
        end
        eval(remove_script)
    end
end
