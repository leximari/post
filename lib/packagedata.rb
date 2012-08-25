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

require('yaml')
require('open-uri')
require('fileutils')
require('rbconfig')
require('zlib')

class PackageDataBase
    include FileUtils
    def initialize()
        @root = '/'
        @database_location = "#{@root}/var/lib/post/"
        @install_database = File.join(@database_location, "installed")
        @sync_database = File.join(@database_location, "available")

        unless File.exist?(@database_location)
            mkdir_p(@install_database)
            mkdir_p(@sync_database)
        end

    end

    def get_root()
        @root
    end

    def get_data(package)
        begin
            package_data = File.join(@install_database, package, 'packageData')
            data = normalise(YAML::load_file(package_data))
        rescue
            data = {}
            data['version'] = "0"
        end
        return data
    end

    def normalise(data)
        data['version'] = data['version'].to_s()

        data['conflicts'] = [] if data['conflicts'] == nil
        data['dependencies'] = [] if data['dependencies'] == nil
        data['version'] = "0" if data['version'].empty?
        return data
    end

    def get_sync_data(package)
        package_data = File.join(@sync_database, package)
        data = normalise(YAML::load_file(package_data))
        unless (data['architecture'].include?(RbConfig::CONFIG['host_cpu']))
            data['version'] = "0"
        end
        return data
    end

    def get_files(package)
        file = File.join(@install_database, package, 'files')
        return IO.readlines(file)
    end

    def get_remove_script(package)
        remove_script = File.join(@install_database, package, 'remove')
        File.read(remove_script)
    end

    def install_package(package_data, remove_file, installed_files)
        data = YAML::load_file(package_data)

        dir_name = File.join(@install_database, data['name'])
        file_name = File.join(dir_name, 'files')
        package_data_name = File.join(dir_name, 'packageData')
        remove_file_name = File.join(dir_name, 'remove')

        mkdir_p(dir_name)
        install(package_data, package_data_name)
        install(remove_file, remove_file_name)

        file = open(file_name, 'w')
        file.puts(installed_files)
    end

    def remove_package(package)
        dir_name = File.join(@install_database, package)
        rm_r(dir_name)
    end

    def get_available_packages()
        list = Dir["#{@sync_database}/*"].map() { |package| File.basename(package) }
        list.delete("repo.yaml")
        return list
    end

    def get_repodata
        return YAML::load_file("#{@sync_database}/repo.yaml")
    end

    def get_installed_packages()
        Dir["#{@install_database}/*"].map() { |package| File.basename(package) }
    end

    def installed?(package)
        true if get_installed_packages.include?(package)
    end

    def available?(package)
        true if get_available_packages.include?(package)
    end

    def upgrade?(package)
        true if (available?(package)) and
            (get_sync_data(package)['version'] > get_data(package)['version'])
    end

    def get_channel()
        YAML::load_file("/etc/post/channel")
    end

    def update_database()
        rm_r("/tmp/post") if (File.exists?("/tmp/post"))
        rm_r("/var/lib/post/available") if (File.exists?("/var/lib/post/available"))

        mkdir_p("/tmp/post")
        cd("/tmp/post")

        source_url = get_channel()['url'] + '/info.tar'
        File.open('info.tar', 'w') do |file|
            file.puts(open(source_url).read)
        end
        
        system("tar xf info.tar")
        cp_r('info', '/var/lib/post/available')
        
        source_url = get_channel()['url'] + '/repo.yaml'
        File.open('repo.yaml', 'w') do |file|
            file.puts(open(source_url).read)
        end
        cp_r('repo.yaml', '/var/lib/post/available/repo.yaml')
    end
end

