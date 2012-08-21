# Copyright (C) Thomas Chace 2011 <ithomashc@gmail.com>
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

require(File.join(File.expand_path(File.dirname(__FILE__)), "packagedata.rb"))
require(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))
require('fileutils')
require('yaml')

class Install
    def initialize()
        FileUtils.rm_r("/tmp/post") if File.exists?("/tmp/post")
        FileUtils.mkdir("/tmp/post")
        FileUtils.cd("/tmp/post")
        @packageDataBase = PackageDataBase.new()
    end

    def installPackage(filename)
        extract(filename)
        FileUtils.rm(filename)
        newFiles = Dir["**/*"].reject {|file| File.directory?(file) }
        newDirectories = Dir["**/*"].reject {|file| File.file?(file) }
        @packageDataBase.installPackage(".packageData", ".remove", newFiles)
        for directory in newDirectories
            FileUtils.mkdir_p("#{@packageDataBase.getRoot()}/#{directory}")
        end
        for file in newFiles
            FileUtils.install(file, "#{@packageDataBase.getRoot()}/#{file}")
            if file.include?("/bin/")
                system("chmod +x #{@packageDataBase.getRoot()}/#{file}")
            end
        end
        installScript = File.read(".install")
        eval(installScript)
    end
end
