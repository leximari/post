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

require("yaml")
require("net/http")
require("uri")

require(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

module Tools
    class << self
        def getUrl(package)
            channel = getCurrentChannel()
            url = "#{channel['url']}/#{getFileName(package)}"
            return url
        end
        def getCurrentChannel()
            return openYAML("etc/post/channel")
        end
        def getFileName(package)
            return "#{package}-#{Query.getLatestVersion(package)}-#{Query.getPackageArch(package)}.pst"
        end
        def getRoot()
            return "/"
        end
        def extract(filename)
            system("tar xf #{filename}")
        end
        def openYAML(filename)
            file = open(getRoot() + filename, 'r')
            return YAML::load(file)
        end
        def mkdir(directory)
            FileUtils.mkdir_p("#{Tools.getRoot()}/#{directory}")
        end
        def installFile(file, destination)
            FileUtils.install(file, "#{Tools.getRoot}/#{destination}")
            if file.include?("/bin/")
                system("chmod +x #{Tools.getRoot()}/#{destination}")
            end
        end
        def removeFile(file)
            FileUtils.rm_r(getRoot() + file)
        end
        def copyFile(file, destination)
            FileUtils.cp_r(file, "/#{destination}")
        end
        def log(string, doPrint = true)
            logFile = File.open("/var/log/post.log", 'a+')
            logFile.write("#{Time.now} #{string}")
            logFile.close()
            if (doPrint)
                puts("#{string}")
            end
        end
        def getFile(url, file, progress = true)
            thread = Thread.new do
                thread = Thread.current()
                url = URI.parse(url)
                savedFile = File.open("#{file}", 'w')

                Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
                    length = response['Content-Length'].to_i()
                    response.read_body do |fragment|
                        savedFile << fragment
                        thread[:done] = (thread[:done] || 0) + fragment.length()
                        thread[:progress] = thread[:done].quo(length) * 100
                    end
                end
                savedFile.close()
            end
            if (progress)
                until thread.join(1)
                    print("\r\e Fetching:    #{url} [%.2f%%]\r\e " % thread[:progress])
                end
                Tools.log("Fetching:    #{url} [100.00%]")
            end
            thread.join()
        end
    end
end
