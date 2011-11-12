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

require('optparse')

directory = File.expand_path(File.dirname(__FILE__))

require(File.join(directory, 'fetch.rb'))
require(File.join(directory, 'libppm', 'erase.rb'))
require(File.join(directory, 'libppm', 'query.rb'))

QUERY = Query.new()
puts('Loading:     Downloading package information.')
QUERY.updateDatabase()

def installPackages(argumentPackages)
    fetch = Fetch.new()
    for package in argumentPackages
        fetch.buildQueue(package)
    end
    packageQueue = fetch.getQueue()

    conflict = false
    for package in packageQueue
        conflict = true if (fetch.checkConflicts(package))
    end

    unless (packageQueue.empty?)# or (conflict)
        puts "Queue:       #{packageQueue.join(" ")}"
        print 'Confirm:     [y/n] '
        confirmTransaction = gets()
        if confirmTransaction.include?('y')
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
    installPackages(packages)
end

options = ARGV.options()
options.set_summary_indent('    ')
options.banner =    "Usage: post [OPTIONS] [PACKAGES]"
options.version =   "Post 1.0 Release Candidate 2(0.9.8)"
options.define_head "Copyright (C) Thomas Chace 2011 <ithomashc@gmail.com>"

if (Process.uid == 0)
    options.on('-i', '--fetch=', Array,
        'Install or update a package.')  { |args| installPackages(args) }
    options.on('-r', '--erase=', Array,
         'Erase a package.') { |args| removePackages(args) }
    options.on('-u', '--upgrade',
         'Upgrade all packages to their latest versions') { upgradePackages() }
    end

options.on('-h', '--help', 'Show this help message.') { puts(options) }
options.on('-v', '--version', 'Show version information.') { puts( options.version() ) }
options.parse!