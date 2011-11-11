## License

Post is available under the Lesser General Public license.

## What Is Post?

Post is a powerful package manager that focuses on clean design, efficiency, and simplicity.

Post is supported running on the Rubinius(1.1+), but works well on Ruby 1.8+.

## Installing Post

        git clone git://github.com/thomashc/Post.git
        cd Post
        sudo rbx build.rb # For Rubinius
        sudo ruby1.8 build.rb # For Ruby 1.8
        sudo ruby1.9 build.rb # For Ruby 1.9

## Configuring The Test Repository

        sudo cp src/etc/post/channel /etc/post/channel

## Testing The Installation

        sudo post -h
        sudo post -s
        sudo post -i zile

If all of these pass without error, it looks like Post is installed!

If you have any questions, email me at ithomashc at gmail dot com.
