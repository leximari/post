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

require("optparse")

libraries = [
    File.join(File.expand_path(File.dirname(__FILE__)), "fetch.rb"),
    File.join(File.expand_path(File.dirname(__FILE__)), "erase.rb"),
    File.join(File.expand_path(File.dirname(__FILE__)), "refresh.rb"),
]

loadLibraries = Thread.new {
    for library in libraries
        load(library)
    end
    if (Process.uid == 0)
        refresh()
    end
}

OPTIONS = {
    :install  => [],
    :remove   => [],
}

install = nil
remove = nil

ARGV.options do |o|
    o.set_summary_indent("    ")
    o.banner =    "Usage: post [OPTIONS] [PACKAGES]"
    o.version =   "Post 1.0 Pre Alpha(2011.11)"
    o.define_head "Copyright (C) Thomas Chace 2011 <ithomashc@gmail.com>"

    if (Process.uid == 0)
        o.on("-i", "--fetch=", Array,
            "Install or update a package.")  { |v| OPTIONS[:install] = v; install = true}
        o.on("-r", "--erase=", Array,
            "Erase a package.") { |v| OPTIONS[:remove] = v; remove = true}
    end

    o.on("-h", "--help", "Show this help message.") {puts(o)}
    o.on("-v", "--version", "Show version information.") {puts(o.version())}
    o.parse!
end

loadLibraries.join()

if (install)
    fetch = Fetch.new()
    for package in OPTIONS[:install]
        fetch.buildQueue(package)
    end
    packageQueue = fetch.getQueue()

    unless (packageQueue.empty?)
        download = Thread.new {
            thread = Thread.current()
            thread[:progress] = false
            for package in packageQueue
                fetch.fetchPackage(package, thread[:progress])
            end
        }
        puts "Queue:       #{packageQueue.join(" ")}"
        print "Confirm:     [y/n] "
        if gets().include?("y")
            download[:progress] = true
            download.join()
            fetch.installQueue()
        end
    end
elsif (remove)
    erase = Erase.new()
    for package in OPTIONS[:remove]
        erase.buildQueue(package)
    end
    erase.removePackages()
end
