package LANraragi::Plugin::Metadata::Prettifier;

use strict;
use warnings;

use LANraragi::Utils::Logging qw(get_plugin_logger);
use LANraragi::Utils::String qw(trim);

sub plugin_info {

    return (
        name        => "Prettifier",
        type        => "metadata",
        namespace   => "prettifier",
        author      => "siliconfeces",
        version     => "0.1",
        description => "Makes existing metadata prettier.",
        parameters => [
            { type => "bool", desc => "Cleanup title by removing language, artist, etc" },
            { type => "bool", desc => "Title-case the title" },
            { type => "bool", desc => "Make all tags lowercase" },
        ],
    );
}

sub get_tags {

    shift;
    my $lrr_info = shift;    # Global info hash
    my ( $cleanup_title, $title_case, $lowercase_tags ) = @_;

    my $logger = get_plugin_logger();

    my $title = $lrr_info->{archive_title};
    my $tags  = $lrr_info->{existing_tags};
    if ($cleanup_title) {
        $title =~ &get_regex;
        if ( defined $5 ) { $title = trim($5); }
    }
    if ($title_case) {
        $title = tc($title);
    }
    if ($lowercase_tags) {
        $tags = lc($tags);
    }

    $logger->info("Sending the following tags to LRR: $tags");
    $logger->info("Sending the following title to LRR: $title");
    return ( tags => $tags, title => $title );
}

# Stolen from LANraragi::Plugin::Metadata::RegexParse
my $regex = qr/(\(([^([]+)\))?\s*(\[([^]]+)\])?\s*([^([]+)\s*(\(([^([)]+)\))?\s*(\[([^]]+)\])?/;
sub get_regex { return $regex }

# Stolen from docstore.mik.ua/orelly/perl4/cook/ch01_15.htm
sub tc {
    our %nocap;
    for (qw(a an the and but or as at but by for from in into of off on onto per to with)) {
        $nocap{$_}++;
    }

    local $_ = shift;
    # put into lowercase if on stop list, else titlecase
    s/(\pL[\pL']*)/$nocap{$1} ? lc($1) : ucfirst(lc($1))/ge;
    s/^(\pL[\pL']*) /\u\L$1/x;
    # last word guaranteed to cap
    s/ (\pL[\pL']*)$/\u\L$1/x; # first word guaranteed to cap
    # treat parenthesized portion as a complete title
    s/\( (\pL[\pL']*) /(\u\L$1/x; s/(\pL[\pL']*) \) /\u\L$1)/x;
    # capitalize first word following colon or semi-colon
    s/ ( [:;] \s+ ) (\pL[\pL']* ) /$1\u\L$2/x; return $_;
}

1;
