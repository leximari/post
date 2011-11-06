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

class Erase
    def initialize()
        unless(@queue)
            @queue = []
        end
    end
    def buildQueue(package)
        if Query.getInstalled(package)
            @queue.push(package)
        else
            Tools.log("Error:       '#{package}' not installed.")
        end
    end
    def removePackages()
        for package in @queue
            removePackage(package)
            Tools.log("Removing:   '#{package}'.")
        end
    end
    def removePackage(package)
        for file in Query.getFiles(package)
            Tools.removeFile(file.delete("\n"))
        end
        removeScript = Query.getRemoveScript(package)
        eval(removeScript)
        Query.removeInstalledPackage(package)
    end
end
