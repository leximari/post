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

class IncompleteError < Exception
end

class CommandLineFetch < Plugin
    def get_file(url, file)
        url = URI.parse(url)
        file_name = File.basename(file)
        saved_file = File.open(file, 'w')

        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
            length = response['Content-Length'].to_i
            saved_file_length = 0.0
            response.read_body do |fragment|
                saved_file << fragment
                saved_file_length += fragment.length
                progress = (saved_file_length / length) * 100
                print("\rFetching:    #{file_name} [#{progress.round}%]")
            end
        end
        saved_file.close()
        print("\r")
        puts("Fetched:     #{file_name} [100%]\n")
    end

    def fetch_package(package)
        mkdir_p("/tmp/post/#{package}")

        sync_data = @database.get_sync_data(package)
        repo_url = @database.get_url(@database.get_repo(package))

        file = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        url = ("#{repo_url}/#{file}")
        begin
            if url.include?('file://')
                url.sub!("file://", '')
                cp(url, "/tmp/post/#{package}/#{file}")
            else
                get_file(url, "/tmp/post/#{package}/#{file}")
            end
        rescue
            raise IncompleteError, "Error:      '#{url}' does not exist."
        end
            
    end
end



