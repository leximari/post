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

require('yaml')
require('open-uri')
require('fileutils')

class Query
    def initialize()
        setRoot('/')
        setDatabaseLocation("#{getRoot}/var/lib/post/")
        @installDatabase = File.join(@databaseLocation, "installed")
        @syncDatabase = File.join(@databaseLocation, "available")
    end

    def openYAML(fileName)
        return YAML::load_file(fileName)
    end

    def setRoot(newRoot)
        @root = newRoot
    end

    def getRoot()
        return @root
    end

    def setDatabaseLocation(newDatabaseLocation)
        @databaseLocation = newDatabaseLocation
    end

    def getDatabaseLocation()
        return @databaseLocation
    end

    def getInstalledPackageData(package)
        if isInstalled?(package)
            packageData = File.join(@installDatabase, package, 'packageData')
            data = openYAML(packageData)
            return data
        end
    end

    def getSyncPackageData(package)
        if isAvailable?(package)
	        packageData = File.join(@syncDatabase, package)
	        data = openYAML(packageData)
	        return data
	    end
    end

    def getPackageFiles(package)
        file = File.join(@installDatabase, package, 'files')
        fileList = open(file, 'r')
        return fileList.readlines()
    end

    def getRemoveScript(package)
        removeScript = File.join(@installDatabase, package, 'remove')
        File.read(removeScript)
    end

    def addPackage(packageData, removeFile, installedFiles)
        data = openYAML(packageData)

        dirName = File.join(@installDatabase, data['name'])
        fileName = File.join(dirName, 'files')
        packageDataName = File.join(dirName, 'packageData')
        removeFileName = File.join(dirName, 'remove')

        FileUtils.mkdir_p(dirName)
        FileUtils.install(packageData, packageDataName)
        FileUtils.install(removeFile, removeFileName)

        file = open(fileName, 'w')
        file.puts(installedFiles)
    end

    def removeInstalledPackage(package)
        dirName = File.join(@installDatabase, package)
        FileUtils.rm_r(dirName)
    end

    def getAvailablePackages()
        packageList = Dir.entries(@syncDatabase)
        packageList.delete('.')
        packageList.delete('..')
        return packageList
    end

    def isInstalled?(package)
        installFile = File.join(@installDatabase, package)
        if File.exists?(installFile)
            return true
        end
    end

    def isAvailable?(package)
        if getAvailablePackages.include?(package)
            return true
        end
    end
    def upgradeAvailable?(package)
        if (isAvailable?(package)) and (getSyncVersion(package) > getLocalVersion(package))
            return true
        end
    end

    def getSyncVersion(package)
        version = "0"
        if (isAvailable?(package))
            data = getSyncPackageData(package)
            version = data['version']
        end
        if version.class() == Array
            version = version.sort().last()
        end
        return version.to_s()
    end

    def getLocalVersion(package)
        version = "0"
        if (isInstalled?(package))
            version = getInstalledPackageData(package)['version']
        end
        if version.class() == Array
            version = version.sort().last()
        end
        return version.to_s()
    end

    def getUrl(package)
        channel = getCurrentChannel()
        url = "#{channel['url']}/#{getFileName(package)}"
        return url
    end

    def getCurrentChannel()
        return openYAML("/etc/post/channel")
    end

    def getFileName(package)
        latestVersion = getSyncVersion(package)
        packageArch = getSyncPackageData(package)['architecture']
        return "#{package}-#{latestVersion}-#{packageArch}.pst"
    end

    def updateDatabase()
        if File.exists?("/tmp/post")
            FileUtils.rm_r("/tmp/post")
        end
        FileUtils.mkdir_p("/tmp/post")
        FileUtils.cd("/tmp/post")
        if File.exists?("/var/lib/post/available")
            FileUtils.rm_r("/var/lib/post/available")
        end
        url = getCurrentChannel()['url']
        sourceFile = url + '/info.tar'
        destinationFile = open('info.tar', "wb")
        destinationFile.write(open(sourceFile).read())
        destinationFile.close()
        system("tar xf info.tar")
        FileUtils.cp_r("info", "/var/lib/post/available")
    end
end

