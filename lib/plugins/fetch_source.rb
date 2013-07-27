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
require('yaml')
require('rbconfig')

def extract_xz(filename)
    system("mv #{filename} #{filename}.xz")
    system("unxz #{filename}.xz")
    system("tar xf #{filename}")
end

class IncompleteError < Exception
end

class FetchSource < Plugin
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

    def fetch_build(package)
        mkdir_p("/tmp/post/#{package}")
        cd("/tmp/post/#{package}")

        sync_data = @database.get_sync_data(package)
        repo_url = @database.get_url(@database.get_repo(package))

        file = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pstbuild"
        url = ("#{repo_url}/pstbuilds/#{file}")
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

        extract_xz(file)
            
    end
end


class BuildPackage < Plugin


    def get_source(package)
        cd("/tmp/post/#{package}")
        file = open("packageData", 'r')
        spec = YAML::load(file)
        mkdir_p("#{spec['name']}-build/data")
        
        cp("packageData", "#{spec['name']}-build/data/.packageData")
        cp("install", "#{spec['name']}-build/data/.install")
        cp("remove", "#{spec['name']}-build/data/.remove")
        cd("/tmp/post/#{package}/#{spec['name']}-build")
        for source in spec['source']
            if source.include?("http://") or source.include?("ftp://")
                action = system("wget -c #{source}")
                if action == false
                    puts("Could not download #{source}.")
                end
            elsif source.include?("git://")
                action = system("git clone #{source}")
                if action == false
                    puts("Could not download #{source}.")
                end
            end
        end
    end
    
    def cleanup(package, package_filename)
        wd = "/tmp/post/#{package}"
        rm_r("#{wd}/#{package}-build")
        rm("#{wd}/packageData")
        rm("#{wd}/install")
        rm("#{wd}/remove")
        rm("#{wd}/build")
        rm("#{wd}/#{package_filename}build")
    end

    def build_package(package)
        cd("/tmp/post/#{package}")
        wd = pwd()
        file = open("packageData", 'r')
        spec = YAML::load(file)

        build = File.read("#{wd}/build")
        
        cd("#{wd}/#{package}-build")
        build_thread = Thread.new { eval(build) }
        build_thread.join
        packageFiles = Dir["**/*"].reject {|file| File.directory?(file) }
        for file in packageFiles
            if file.include?("/bin/") or file.include?("/lib/")
                system("strip #{file}")
            end
        end
        cd("#{wd}/#{package}-build/data")
        package_name = "#{spec['name']}-#{spec['version']}-#{RbConfig::CONFIG["build_cpu"]}.pst"
        system("tar cf #{package_name} * .packageData .install .remove")
        system("xz #{package_name}")
        cp(package_name + ".xz", "#{wd}/#{package_name}")
        rm("#{package_name}.xz")
        cleanup(package, package_name)
    end
end