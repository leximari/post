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
require("xmlsimple")
require("net/http")

load(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

def refresh()
    if File.exists?("/tmp/post")
        FileUtils.rm_r("/tmp/post")
    end
    FileUtils.mkdir("/tmp/post")
    FileUtils.cd("/tmp/post")
    if File.exists?(Tools.getRoot() + "var/lib/post/available")
        FileUtils.rm_r(Tools.getRoot() + "var/lib/post/available")
    end
    FileUtils.mkdir_p(Tools.getRoot() + "var/lib/post/")
    channel = Query.getCurrentChannel()
    Tools.getFile(channel['url'] + "/info.tar", "info.tar")
    Tools.extract("info.tar")
    FileUtils.cp_r("info", Tools.getRoot() + "var/lib/post/available")
end
