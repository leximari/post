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
require(File.join(File.dirname(__FILE__), "tools.rb"))
require('fileutils')

class Install
    def initialize()
        FileUtils.rm_r("/tmp/post") if File.exists?("/tmp/post")
        FileUtils.mkdir("/tmp/post")
        FileUtils.cd("/tmp/post")
        @database = PackageDataBase.new()
    end

    def install_package(filename)
        extract(filename)
        FileUtils.rm(filename)
        new_files = Dir["**/*"].reject {|file| File.directory?(file) }
        new_directories = Dir["**/*"].reject {|file| File.file?(file) }
        @database.install_package(".packageData", ".remove", new_files)
        for directory in new_directories
            FileUtils.mkdir_p("#{@database.get_root()}/#{directory}")
        end
        for file in new_files
            FileUtils.install(file, "#{@database.get_root()}/#{file}")
            system("chmod +x #{@database.get_root()}/#{file}") if file.include?("/bin/")
        end
        install_script = File.read(".install")
        eval(install_script)
    end
end
