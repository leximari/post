# Copyright (C) Thomas Chace 2011-2012 <ithomashc@gmail.com>
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

require(File.join(File.expand_path(File.dirname(__FILE__)), "packagedata.rb"))

class Erase
    def initialize(queue)
        @queue = queue
        @packageDataBase = PackageDataBase.new()
    end

    def getQueue()
        return @queue
    end

    def buildQueue(package)
        @queue.set(package) if @packageDataBase.isInstalled?(package)
    end

    def removePackage(package)
        doErase = Thread.new {
			removeScript = @packageDataBase.getRemoveScript(package)
			$SAFE = 4
			eval(removeScript)
		}

        packageFiles = @packageDataBase.getFiles(package)
        @packageDataBase.removePackage(package)

        packageFiles.each() do |file|
            FileUtils.rm("#{@packageDataBase.getRoot()}/#{file.delete("\n")}")
        end
        doErase.join()
    end
end
