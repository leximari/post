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

load(File.join(File.expand_path(File.dirname(__FILE__)), "libppm", "install.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "libppm", "query.rb"))

require('net/http')

class Fetch
    def initialize()
        @installObject = Install.new()
        @queue = []
        @packageQuery = Query.new()
    end

    def getQueue()
        @queue
    end

    def setQueue(newQueue)
        @queue = newQueue
    end
    def getFile(url, file)
        url = URI.parse(url)
        savedFile = File.open("#{file}", 'w')

        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
            length = response['Content-Length'].to_i()
            savedFileLength = 0.0
            response.read_body do |fragment|
                savedFile << fragment
                savedFileLength += fragment.length()
                progressData = (savedFileLength / length) * 100
                print("\r\e Fetching:    #{url} [#{progressData.round()}%]\r\e ")
            end
        end
        puts("\r\e Fetching:    #{url} [100%]")
        savedFile.close()
    end

    def buildQueue(package)
        if (@packageQuery.upgradeAvailable?(package))
            for dependency in @packageQuery.getSyncPackageData(package)['dependencies'].to_a()
                buildQueue(dependency)
            end
            unless @queue.include?(package)
                @queue.push(package)
            end
        end
    end

    def fetchPackage(package, progress = true)
        FileUtils.mkdir("/tmp/post/#{package}")
        url = @packageQuery.getUrl(package)
        filename = @packageQuery.getFileName(package)
        getFile(url, "/tmp/post/#{package}/#{filename}")
    end

    def installQueue()
        for package in @queue
            FileUtils.cd("/tmp/post/#{package}")
            filename = @packageQuery.getFileName(package)
            puts("Installing:  #{package}")
            @installObject.installPackage(filename)
        end
    end
end
