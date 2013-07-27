## License

Post is available under the Lesser General Public license.

## What Is Post?

Post is package manager for unix systems that focuses on clean design, efficiency, and simplicity.

Post is is supported by Rubinius(1.1+), but also works well on Ruby 1.9+.

## Installing Post

        git clone git://github.com/thomashc/Post.git
        git checkout 1.0
        cd Post
        gem build post.gemspec
        gem install post-2.5.6.gem

## Configuring The Test Repository

        sudo cp cfg/bellaciao /etc/post/repos.d/bellaciao

## Testing The Installation

        sudo post -h
        sudo post -i zile

If you have questions, email me at <tchacex@gmail.com>.
