# Copyright (C) Thomas Chace 2010-2011 <ithomashc@gmail.com>
# Ruby Build System
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

require('fileutils')
include(FileUtils)

prefix = ENV["PREFIX"]
destdir = ENV["DESTDIR"]

puts("Configuring...")

rm("src/bin/post.rb")

File.open("src/bin/post.rb", "w") do |file|
    file.puts("#!#{$ruby}")
    file.puts("load('#{prefix}/lib/post/main.rb')")
end

puts("Installing...")

mkdir_p("#{destdir}/var/cache/post/")
mkdir_p("#{destdir}/var/cache/post/available/")
mkdir_p("#{destdir}/var/cache/post/installed/")
mkdir_p("#{destdir}/#{prefix}/bin/")
mkdir_p("#{destdir}/#{prefix}/lib/post/")
mkdir_p("#{destdir}/etc/post/repos.d/")

system("install -m 755 src/bin/post.rb #{destdir}#{prefix}/bin/post")
system("install -m 644 src/lib/fetch.rb #{destdir}#{prefix}/lib/post/fetch.rb")
system("install -m 644 src/lib/main.rb #{destdir}#{prefix}/lib/post/main.rb")
system("install -m 644 src/lib/query.rb #{destdir}#{prefix}/lib/post/query.rb")
system("install -m 644 src/lib/tools.rb #{destdir}#{prefix}/lib/post/tools.rb")
