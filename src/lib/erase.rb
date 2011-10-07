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
require("net/http")

load(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

class Erase
    def initialize()
        unless(@queue)
            @queue = []
        end
    end
    def getQueue()
        @queue
    end
    def buildQueue(package)
        if Query.getInstalled(package)
            @queue.push(package)
        else
            Tools.printString("Status:     '#{package}' not installed.", type = "final")
        end
    end
    def removePackages()
        for package in @queue
            removePackage(package)
        end
    end
    def removePackage(package)
        Tools.printString("Status:     Removing '#{package}'.")
        for file in Query.getFiles(package)
            Tools.removeFile(file.delete("\n"))
        end
        removeScript = Query.getRemoveScript(package)
        eval(removeScript)
        Query.removeInstalledPackage(package)
        Tools.printString("Status:     '#{package}' removed.", type = "final")
    end
end
