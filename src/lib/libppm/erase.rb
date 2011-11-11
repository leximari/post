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

load(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

class Erase
    def initialize()
        @queue = []
        @packageQuery = Query.new()
    end
    def getQueue()
        @queue
    end

    def buildQueue(package)
        if @packageQuery.isInstalled?(package)
            @queue.push(package)
        end
    end

    def removePackage(package)
        eval(@packageQuery.getRemoveScript(package))

        packageFiles = @packageQuery.getPackageFiles(package)
        @packageQuery.removeInstalledPackage(package)

        for file in packageFiles
            FileUtils.rm("#{@packageQuery.getRoot()}/#{file.delete("\n")}")
        end

    end
end
