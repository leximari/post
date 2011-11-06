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

require(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))

module Query
    class << self
        def getFiles(package)
            files = open("#{Tools.getRoot()}/var/lib/post/installed/#{package}/files", 'r')
            return files.readlines()
        end
        def getFileList(package)
            File.read("#{Tools.getRoot()}/var/lib/post/installed/#{package}/files")
        end
        def getRemoveScript(package)
            File.read("#{Tools.getRoot()}/var/lib/post/installed/#{package}/remove")
        end
        def getInstallScript(package)
            File.read("#{Tools.getRoot()}/var/lib/post/installed/#{package}/install")
        end
        def addInstalledPackage(packageData, installFile, removeFile, installedFiles)
            data = Tools.openYAML(packageData)
            Tools.mkdir("var/lib/post/installed/#{data['name']}")
            Tools.installFile(packageData, "var/lib/post/installed/#{data['name']}/packageData")
            Tools.installFile(installFile, "var/lib/post/installed/#{data['name']}/install")
            Tools.installFile(removeFile, "var/lib/post/installed/#{data['name']}/remove")
            files = open("#{Tools.getRoot()}/var/lib/post/installed/#{data['name']}/files", 'w')
            files.puts(installedFiles)
        end
        def removeInstalledPackage(package)
            FileUtils.rm_r("#{Tools.getRoot()}/var/lib/post/installed/#{package}")
        end
        def getInstalled(package)
            if File.exists?("#{Tools.getRoot()}/var/lib/post/installed/#{package}/packageData")
                return true
            end
        end
        def upgradeAvailable(package)
            available = File.exists?("#{Tools.getRoot()}/var/lib/post/available/#{package}")
            if (available) and (getLatestVersion(package) > getInstalledVersion(package))
                return true
            end
        end
        def getPackageArch(package)
            data = Tools.openYAML("var/lib/post/available/#{package}")
            return data['architecture'].to_s()
        end
        def getLatestVersion(package)
            version = "0"
            available = File.exists?("#{Tools.getRoot()}/var/lib/post/available/#{package}")
            if (available)
                data = Tools.openYAML("var/lib/post/available/#{package}")
                version = data['version']
            end
            if version.class == Array
                version = version.sort().last()
            end
            return version.to_s()
        end
        def getInstalledVersion(package)
            version = "0"
            if (getInstalled(package))
                data = Tools.openYAML("var/lib/post/installed/#{package}/packageData")
                version = data['version']
            end
            if version.class() == Array
                version = version.sort().last()
            end
            return version.to_s()
        end
        def getConflicts(package)
            conflicts = Tools.openYAML("var/lib/post/available/#{package}")['conflicts']
            if (conflicts == nil)
                conflicts = []
            end
            return conflicts
        end
        def getDependencies(package)
            dependencies = Tools.openYAML("var/lib/post/available/#{package}")['dependencies']
            if (dependencies == nil)
                dependencies = []
            end
            return dependencies
        end
    end
end

