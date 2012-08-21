load('src/lib/post.rb')

time = Time.new
month = time.month
if (time.month < 10)
    month = "0#{month}"
end
date = "#{time.year}-#{month}-#{time.day}"

Gem::Specification.new do |s|
    s.name        = 'post'
    s.executables << 'post'
    s.version     = '1.5.0'
    s.date        = date
    s.summary     = "Package manager in pure ruby."
    s.description = "Small, Fast package manager in pure Ruby."
    s.authors     = ["Thomas Chace"]
    s.email       = 'tchacex@gmail.com'
    s.files       = ["lib/post.rb", "lib/fetch.rb", "lib/libppm/erase.rb",
            "lib/libppm/install.rb", "lib/libppm/packagelist.rb", "lib/libppm/packagedata.rb",
            "lib/libppm/tools.rb"]
    s.homepage    =
        'http://github.com/thomashc/Post'
end
