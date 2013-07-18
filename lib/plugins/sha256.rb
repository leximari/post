# Copyright (C) Thomas Chace 2011-2013 <tchacex@gmail.com>
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

require('net/http')
require('fileutils')
require('digest')

class MismatchedHash < Exception
end

class IncompleteError < Exception
end

class Sha256Check < Plugin
    include FileUtils
    def initialize(root = '/', database)
        @root = root
        @database = database
    end
    
    def get_file(url, file)
        url = URI.parse(url)
        file_name = File.basename(file)
        saved_file = File.open(file, 'w')

        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
            response.read_body do |fragment|
                saved_file << fragment
            end
        end
        saved_file.close()
    end
    
    def verify_package(package)
        cd("/tmp/post/#{package}")
        sync_data = @database.get_sync_data(package)
        repo_url = @database.get_url(@database.get_repo(package))

        filename = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        url = ("#{repo_url}/#{filename}")
        begin
            if url.include?('file://')
                url.sub!("file://", '')
                cp(url + ".sha256", "/tmp/post/#{package}/#{filename}.sha256")
            else
                get_file(url + ".sha256", "/tmp/post/#{package}/#{filename}.sha256")
            end
        rescue
            raise IncompleteError, "Error:      '#{url + ".sha256"}' does not exist."
        end
        `ls`
        file_hash = Digest::SHA256.hexdigest(open(filename, "r").read())
        real_hash = File.open("#{filename}.sha256").read().strip()
        unless (file_hash == real_hash)
            raise MismatchedHash, "Error:       #{filename} is corrupt."
        end
        rm("#{filename}.sha256")
    end
end