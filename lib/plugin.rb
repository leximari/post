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

directory = File.dirname(__FILE__)
path = File.expand_path(directory)
plugin_directory = File.join(path, "plugins")

require('set')
require("fileutils")

class Plugin
	include FileUtils
	def initialize(root = '/', database)
        @root = root
        @database = database
    end

    def cleanup
        rm_r("/tmp/post") if File.exists?("/tmp/post")
        mkdir("/tmp/post")
        cd("/tmp/post")
    end

    def self.plugins
        @plugins ||= []
    end

    def self.inherited(klass)
        @plugins ||= []
        @plugins << klass
    end
end

require(File.join(plugin_directory, "http_fetch_binary.rb"))
require(File.join(plugin_directory, "install_binary.rb"))
require(File.join(plugin_directory, "remove_binary.rb"))
require(File.join(plugin_directory, "verify_sha256.rb"))
require(File.join(plugin_directory, "fetch_source.rb"))