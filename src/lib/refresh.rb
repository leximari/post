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

require("fileutils")

load(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))

def refresh()
    if File.exists?("/tmp/post")
        Tools.removeFile("/tmp/post")
    end
    Tools.mkdir("/tmp/post")
    FileUtils.cd("/tmp/post")
    if File.exists?("#{Tools.getRoot()}/var/lib/post/available")
        Tools.removeFile("/var/lib/post/available")
    end
    Tools.mkdir("var/lib/post/")
    channel = Tools.getCurrentChannel()
    Tools.getFile("#{channel['url']}/info.tar", "info.tar")
    Tools.extract("info.tar")
    Tools.copyFile("info", "var/lib/post/available")
end
