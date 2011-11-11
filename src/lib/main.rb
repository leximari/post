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

directory = File.expand_path(File.dirname(__FILE__))

libraries = [
    File.join(directory, "fetch.rb"),
    File.join(directory, "libppm", "erase.rb"),
    File.join(directory, "libppm", "query.rb"),
]

for library in libraries
    load(library)
end

QUERY = Query.new()
QUERY.updateDatabase()

def installPackages(argumentPackages)
    fetch = Fetch.new()
    for package in argumentPackages
        fetch.buildQueue(package)
    end
    packageQueue = fetch.getQueue()

    unless (packageQueue.empty?)
        puts "Queue:       #{packageQueue.join(" ")}"
        print "Confirm:     [y/n] "
        confirmTransaction = gets().capitalize()
        if confirmTransaction.include?("Y")
            for package in packageQueue
                fetch.fetchPackage(package)
            end
            fetch.installQueue()
        end
    end
end

def removePackages(argumentPackages)
    erase = Erase.new()
    for package in argumentPackages
        erase.buildQueue(package)
    end
    for package in erase.getQueue()
        puts("Removing:    #{package}")
        erase.removePackage(package)
    end
end

def upgradePackages()
    packages = QUERY.getInstalledPackages()
    OPTIONS[:install] = packages
    installPackages()
end

ARGV.options do |o|
    o.set_summary_indent("    ")
    o.banner =    "Usage: post [OPTIONS] [PACKAGES]"
    o.version =   "Post 1.0 Beta 1(0.8)"
    o.define_head "Copyright (C) Thomas Chace 2011 <ithomashc@gmail.com>"

    if (Process.uid == 0)
        o.on("-i", "--fetch=", Array,
            "Install or update a package.")  { |args| installPackages(args) }
        o.on("-r", "--erase=", Array,
             "Erase a package.") { |args| removePackages(args) }
        o.on("-u", "--upgrade",
             "Upgrade all packages to their latest versions") { upgradePackages() }
    end

    o.on("-h", "--help", "Show this help message.") { puts(o) }
    o.on("-v", "--version", "Show version information.") { puts( o.version() ) }
    o.parse!
end