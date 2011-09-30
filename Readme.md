# Installing Post

Post is a powerful package manager that focuses on clean design, efficiency, and simplicity.

Post is supported running on the Rubinius or JRuby virtual machines, but works well on Ruby 1.8 or 1.9.

## Dependencies
* Rubinius 1.1 + or
* Ruby 1.9 + or
* Jruby 1.5 +

## Install Polar

        git clone git://github.com/thomashc/Post.git
        cd Post
        sudo rbx build.rb

## Setup The Test Repository

        cp src/etc/post/channel.xml /etc/post/channel.xml

## Test Installation

        sudo post -h
        sudo post -s
        sudo post -i zile

If all of these pass without error, it looks like Post is installed!