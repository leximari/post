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

loadLibraries = Thread.new {
    thread = Thread.current()
    for library in libraries
        load(library)
    end
    if (Process.uid == 0)
        thread[':packageQuery'] = packageQuery = Query.new()
        begin
            thread[':packageQuery'].updateDatabase()
        rescue
            puts("Error:       Cannot update database.")
            exit(1)
        end
    end
}

OPTIONS = {
    :install  => [],
    :remove   => [],
}

install = nil
remove = nil
query = nil
queryAvailable = nil

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
        o.on("-q", "--info=", String,
             "Get package information.") { |v| OPTIONS[:query] = v; query = true}
        o.on("-qa", "--infoa=", String,
             "Get available package information.") {queryAvailable = true}
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
elsif (remove)
    erase = Erase.new()
    for package in OPTIONS[:remove]
        erase.buildQueue(package)
    end
    for package in erase.getQueue()
        puts("Removing:    #{package}")
        erase.removePackage(package)
    end
elsif (query)
    packageQuery = loadLibraries[':packageQuery']
    databaseLocation = packageQuery.getDatabaseLocation()
    fileName = File.join(databaseLocation, 'available', OPTIONS[:query])
    file = open(fileName, 'r')
    puts(file.read())
elsif (queryAvailable)
    packageQuery = loadLibraries[':packageQuery']
    puts packageQuery.getAvailablePackages()
end
