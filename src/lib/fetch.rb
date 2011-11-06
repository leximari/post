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

load(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

class Fetch
    def initialize()
        if File.exists?("/tmp/post")
            FileUtils.rm_r("/tmp/post")
        end
        FileUtils.mkdir("/tmp/post")
        FileUtils.cd("/tmp/post")
        unless(@queue)
            @queue = []
        end
        @download = ""
    end
    def getQueue()
        @queue
    end
    def buildQueue(package)
        if (Query.upgradeAvailable(package))
            for dependency in Query.getDependencies(package)
                buildQueue(dependency)
            end
            unless @queue.include?(package)
                @queue.push(package)
            end
        end
    end
    def fetchPackage(package, progress = true)
        if progress == false
            @download += "Fetching:    #{Tools.getUrl(package)} [100.00%]\n"
        end
        if progress == true
            puts @download
            @download = ""
        end
        FileUtils.mkdir("/tmp/post/#{package}")
        url = Tools.getUrl(package)
        filename = Tools.getFileName(package)
        Tools.getFile(url, "/tmp/post/#{package}/#{filename}", progress)
    end
    def fetchQueue()
        for package in @queue
            fetchPackage(package)
        end
    end
    def installQueue()
        for package in @queue
            FileUtils.cd("/tmp/post/#{package}")
            filename = Tools.getFileName(package)
            Tools.log("Installing:  '#{filename}'.")
            installPackage(filename)
        end
    end
    def installPackage(filename)
        Tools.extract(filename)
        Tools.removeFile("#{Dir.pwd()}/#{filename}")
        installedFiles = Dir["**/*"].reject {|file| File.directory?(file) }
        installedDirectories = Dir["**/*"].reject {|file| File.file?(file) }
        Query.addInstalledPackage("#{Dir.pwd()}/.packageData", "#{Dir.pwd()}/.install",
                                  "#{Dir.pwd()}/.remove", installedFiles)
        for directory in installedDirectories
           Tools.mkdir(directory)
        end
        for file in installedFiles
            Tools.installFile(file, file)
        end
        installScript = File.read(".install")
        eval(installScript)
    end
end
