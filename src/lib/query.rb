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

require("rubygems")
require("fileutils")

load(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))

module Query
    class << self
        def getCurrentChannel()
            return Tools.openYAML("etc/post/channel")
        end
        def getUrl(package)
            channel = getCurrentChannel()
            url = "#{channel['url']}/#{getFileName(package)}"
            return url
        end
        def getFiles(package)
            files = open(Tools.getRoot() + "var/lib/post/installed/#{package}/files", 'r')
            return files.readlines()
        end
        def getFileName(package)
            return "#{package}-#{getLatestVersion(package)}-#{getPackageArch(package)}.pst"
        end
        def getFileList(package)
            File.read(Tools.getRoot() + "var/lib/post/installed/" + package + "/files")
        end
        def getRemoveScript(package)
            File.read(Tools.getRoot() + "var/lib/post/installed/" + package + "/remove.rb")
        end
        def getInstallScript(package)
            File.read(Tools.getRoot() + "var/lib/post/installed/" + package + "/install.rb")
        end
        def addInstalledPackage(packageData, installFile, removeFile, installedFiles)
            data = Tools.openYAML(packageData)
            Tools.mkdir("var/lib/post/installed/" + data['name'])
            Tools.installFile(packageData, "var/lib/post/installed/" + data['name'] + "/packageData")
            Tools.installFile(installFile, "var/lib/post/installed/" + data['name'] + "/install.rb")
            Tools.installFile(removeFile, "var/lib/post/installed/" + data['name'] + "/remove.rb")
            File.open(Tools.getRoot() + "var/lib/post/installed/" + data['name'] + "/files", 'w') do
                |file|
                file.puts(installedFiles)
            end
        end
        def removeInstalledPackage(package)
            FileUtils.rm_r(Tools.getRoot() +"var/lib/post/installed/" + package)
        end
        def getAvailable(package)
            if File.exists?(Tools.getRoot() + "var/lib/post/available/" + package)
                return true
            end
        end
        def getInstalled(package)
            if File.exists?(Tools.getRoot() + "var/lib/post/installed/" + package + "/packageData")
                return true
            end
        end
        def getPackageArch(package)
            if (getAvailable(package))
                data = Tools.openYAML("var/lib/post/available/" + package)
                return data['architecture']
            end
        end
        def getLatestVersion(package)
            if (getAvailable(package))
                data = Tools.openYAML("var/lib/post/available/" + package)
                return data['version']
            else
                return "0"
            end
        end
        def getInstalledVersion(package)
            if (getInstalled(package))
                data = Tools.openYAML("var/lib/post/installed/" + package + "/packageData")
                return data['version']
            else
                return "0"
            end
        end
        def getDependencies(package)
            if (getAvailable(package))
                data = Tools.openYAML("var/lib/post/available/" + package)
                if (data['dependencies'] != nil)
                    return data['dependencies']
                else
                    return []
                end
            else
                return []
            end
        end
    end
end

