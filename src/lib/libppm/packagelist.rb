require(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))

class DuplicateEntry < Exception
end

class ConflictingEntry < Exception
end
 

class PackageList
    include Enumerable

    def initialize
        @size = 0
        @packageQuery = Query.new()
    end

    def push(package)
        if (@packageQuery.upgradeAvailable?(package))
            for dependency in @packageQuery.getSyncData(package)['dependencies']
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
        for conflict in @packageQuery.getSyncData(variable)['conflicts']
            if include?(conflict)
                raise ConflictingEntry, "Error:      '#{conflict}' conflicts with '#{variable}'"
            end
        end
        
    end
    
end


