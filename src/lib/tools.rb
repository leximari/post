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

require("yaml")
require("net/http")
require("uri")

require(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

module Tools
    class << self
        def getUrl(package)
            channel = getCurrentChannel()
            url = "#{channel['url']}/#{getFileName(package)}"
            return url
        end
        def getCurrentChannel()
            return openYAML("etc/post/channel")
        end
        def getFileName(package)
            return "#{package}-#{Query.getLatestVersion(package)}-#{Query.getPackageArch(package)}.pst"
        end
        def getRoot()
            return "/"
        end
        def extract(filename)
            system("tar xf #{filename}")
        end
        def openYAML(filename)
            file = open(getRoot() + filename, 'r')
            return YAML::load(file)
        end
        def mkdir(directory)
            FileUtils.mkdir_p("/#{directory}")
        end
        def installFile(file, destination)
            FileUtils.install(file, "/#{destination}")
        end
        def removeFile(file)
            FileUtils.rm_r(getRoot() + file)
        end
        def copyFile(file, destination)
            FileUtils.cp_r(file, "/#{destination}")
        end
        def log(string, doPrint = true)
            File.open("#{Tools.getRoot()}/var/log/post.log", 'a+') {|f|
                f.puts("#{Time.now} #{string}")
            }
            if (doPrint)
                puts("#{string}")
            end
        end
        def getFile(url, file)
            thread = Thread.new do
                thread = Thread.current
                url = URI.parse(url)
                body = File.open("#{file}", 'w')

                Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
                    thread[:length] = response['Content-Length'].to_i()
                    response.read_body do |fragment|
                        body << fragment
                        thread[:done] = (thread[:done] || 0) + fragment.length
                        thread[:progress] = thread[:done].quo(thread[:length]) * 100
                    end
                end
                body.close()
            end
            print("\r\e Fetching:    #{url} [%.2f%%]\r\e " % thread[:progress].to_f) until thread.join(1)
            Tools.log("Fetching:    #{url} [100.00%]")
        end
    end
end
