load('src/lib/post.rb')

time = Time.new
month = time.month
day = time.day
if (time.month < 10)
    month = "0#{month}"
end

if (day < 10)
    day = "0#{day}"
end

date = "#{time.year}-#{month}-#{day}"

Gem::Specification.new do |s|
    s.name        = 'post'
    s.license     = 'GPL'
    s.executables << 'post'
    s.executables << 'postdb'
    s.version     = '2.4.5'
    s.date        = date
    s.summary     = "Package manager in pure ruby."
    s.description = "Small, fast package manager in pure Ruby."
    s.authors     = ["Thomas Chace"]
    s.email       = 'tchacex@gmail.com'
    s.files       = ["lib/post.rb", "lib/plugins", "lib/plugins/fetch.rb",
            "lib/plugins/install.rb", "lib/plugins/sha256.rb", "lib/plugins/remove.rb",
            "lib/packagelist.rb", "lib/packagedata.rb", "lib/plugin.rb"]
    s.homepage    =
        'http://github.com/thomashc/Post'
end
