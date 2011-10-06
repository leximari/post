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

require("optparse")
load(File.join(File.expand_path(File.dirname(__FILE__)), "fetch.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "erase.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "tools.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))
load(File.join(File.expand_path(File.dirname(__FILE__)), "refresh.rb"))

OPTIONS = {
    :install  => [],
    :remove   => [],
}

install = nil
remove = nil
sync = nil

ARGV.options do |o|
    o.set_summary_indent("    ")
    o.banner =    "Usage: post [OPTIONS] [PACKAGES]"
    o.version =   "Post 1.0 Pre Alpha(201109)"
    o.define_head "Copyright (C) Thomas Chace 2011 <ithomashc@gmail.com>"

    if (Process.uid == 0)
        o.on("-i", "--fetch=", Array,
            "Install or update a package.")  { |v| OPTIONS[:install] = v; install = true}
        o.on("-r", "--erase=", Array,
            "Erase a package.") { |v| OPTIONS[:remove] = v; remove = true}
        o.on("-s", "--refresh", "Refresh the package database") {sync = true}
    end

    o.on("-h", "--help", "Show this help message.") {puts(o)}
    o.on("-v", "--version", "Show version information.") {puts(o.version)}
    o.parse!
end

if (sync)
    refresh()
elsif (install)
    fetch = Fetch.new()
    puts("Preparing:  Building Queue")
    for package in OPTIONS[:install]
        fetch.buildQueue(package)
    end
    unless fetch.getStatus() == nil
        puts(fetch.getStatus())
    else
        fetch.fetchQueue()
        fetch.installQueue()
    end
elsif (remove)
    erase = Erase.new()
    for package in OPTIONS[:remove]
        erase.buildQueue(package)
    end
    erase.removePackages()
end