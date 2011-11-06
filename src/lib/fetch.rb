# Copyright (C) Thomas Chace 2011 <ithomashc@gmail.com>
#
# This file is part of Post.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above
#   copyright notice, this list of conditions and the following disclaimer
#   in the documentation and/or other materials provided with the
#   distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

load(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

class Fetch
    def initialize()
        if File.exists?("/tmp/post")
            FileUtils.rm_r("/tmp/post")
        end
        FileUtils.mkdir("/tmp/post")
        FileUtils.cd("/tmp/post")
        unless(@queue)
            @queue = []
        end
    end
    def getQueue()
        @queue
    end
    def checkConflicts(package)
        packageConflict = false
        for conflictingPackage in Query.getConflicts(package)
            if @queue.include?(conflictingPackage)
                Tools.log("Error:      '#{conflictingPackage} conflicts with '#{package}'", "final")
                packageConflict = true
            end
        end
        return packageConflict
    end
    def buildQueue(package)
        if (Query.upgradeAvailable(package))
            for dependency in Query.getDependencies(package)
                buildQueue(dependency)
            end
            unless @queue.include?(package)
                @queue.push(package)
            end
        end
    end
    def fetchQueue()
        for package in @queue
            FileUtils.mkdir("/tmp/post/#{package}")
            url = Tools.getUrl(package)
            filename = Tools.getFileName(package)
            Tools.getFile(url, "/tmp/post/#{package}/#{filename}")
        end
    end
    def installQueue()
        for package in @queue
            FileUtils.cd("/tmp/post/#{package}")
            filename = Tools.getFileName(package)
            Tools.log("Installing:  '#{filename}'.")
            installPackage(filename)
        end
    end
    def installPackage(filename)
        Tools.extract(filename)
        Tools.removeFile("#{Dir.pwd()}/#{filename}")
        installedFiles = Dir["**/*"].reject {|file| File.directory?(file) }
        installedDirectories = Dir["**/*"].reject {|file| File.file?(file) }
        Query.addInstalledPackage("#{Dir.pwd()}/.packageData", "#{Dir.pwd()}/.install",
                                  "#{Dir.pwd()}/.remove", installedFiles)
        for directory in installedDirectories
           Tools.mkdir(directory)
        end
        for file in installedFiles
            Tools.installFile(file, file)
            if file.include?("/bin/")
                system("chmod +x #{Tools.getRoot()}/#{file}")
            end
        end
        installScript = File.read(".install")
        eval(installScript)
    end
end
