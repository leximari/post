# Copyright (C) Thomas Chace 2011-2012 <ithomashc@gmail.com>
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

require(File.join(File.expand_path(File.dirname(__FILE__)), "packagedata.rb"))

class DuplicateEntry < Exception
end

class ConflictingEntry < Exception
end

class PackageList
    include Enumerable

    def initialize
        @size = 0
        @packageDataBase = PackageDataBase.new()
    end

    def push(package)
        if (@packageDataBase.upgradeAvailable?(package))
            for dependency in @packageDataBase.getSyncData(package)['dependencies']
                push(dependency)
            end
            set(package)
        end
    end

    def [](n)
        instance_variable_get("@a#{n}")
    end

    def length
        @size
    end

    def each
        0.upto(@size - 1) { |n| yield self[n] }
    end
    
    def empty?()
        if (@size > 0)
            return false
        else
            return true
        end
    end
    
    def include?(package)
        for value in self
            
            if (value == package)
                return true
            end
            
        end
        return false
    end
    
    def set(variable)
        unless (include?(variable))
            conflict?(variable)
            instance_variable_set("@a#{@size}".to_sym, variable)
            @size += 1
        end
    end
    
    def conflict?(variable)
        for conflict in @packageDataBase.getSyncData(variable)['conflicts']
            if include?(conflict)
                raise ConflictingEntry, "Error:      '#{conflict}' conflicts with '#{variable}'"
            end
        end
    end
    
end


