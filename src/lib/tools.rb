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

module Tools
    class << self
        def getRoot()
            return "/"
        end
        def extract(filename)
            system("tar xf " + filename)
        end
        def run(command)
            system(command)
        end
        def openXML(filename)
            file = getRoot() + filename
            return XmlSimple.xml_in(file, { 'KeyAttr' => 'name' })
        end
        def mkdir(dir)
            FileUtils.mkdir_p("/" + dir)
        end
        def installFile(file, destination)
            FileUtils.cp(file, "/" + destination)
        end
        def removeFile(file)
            FileUtils.rm("/" + file)
        end
        def getFile(url, file)
            if ENV['http_proxy']
                protocol, userinfo, host, port  = URI::split(ENV['http_proxy'])
                proxy_user, proxy_pass = userinfo.split(/:/) if userinfo
                http = Net::HTTP::Proxy(host, port, proxy_user, proxy_pass)
            else
                http = Net::HTTP
            end

            http.get_response(URI(url)) do |res|
                size, total = 0, res.header['Content-Length'].to_i
                File.open file, "w" do |f|
                    res.read_body do |chunk|
                        f << chunk
                        size += chunk.size
                        print "\rRetrieving: #{url} [%d%%]" % [(size * 100) / total]
                    end
                end
            end
            puts("")
        end
    end
end
