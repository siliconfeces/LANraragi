use strict;
use warnings;
use utf8;

use Cwd qw( getcwd );

use Test::More;

my $cwd     = getcwd();
require "$cwd/tests/mocks.pl";

use_ok('LANraragi::Plugin::Metadata::Prettifier');

note("test lowercasing tags");
{
    local *LANraragi::Plugin::Metadata::Prettifier::get_plugin_logger         = sub { return get_logger_mock(); };

    my %dummyhash = ( title => "Title", existing_tags => 'TheTag');

    my %ko_tags = LANraragi::Plugin::Metadata::Prettifier::get_tags( "", \%dummyhash, 0, 0, 1 );
    is( $ko_tags{title}, "Title",  "Title should not be touched" );
    is( $ko_tags{tags},  "thetag", "Tags should be lowercased" );
}

note("test cleaning up title");
{
    local *LANraragi::Plugin::Metadata::Prettifier::get_plugin_logger         = sub { return get_logger_mock(); };

    my %dummyhash = ( title => "(Release) [Artist] TITLE (Series) [Language]", existing_tags => 'TheTag');

    my %ko_tags = LANraragi::Plugin::Metadata::Prettifier::get_tags( "", \%dummyhash, 1, 0, 0 );
    is( $ko_tags{title}, "TITLE",  "Title should be extracted" );
    is( $ko_tags{tags},  "TheTag", "Tags should not be touched" );
}

note("test title case");
{
    local *LANraragi::Plugin::Metadata::Prettifier::get_plugin_logger         = sub { return get_logger_mock(); };

    my %dummyhash = ( title => "the black cat of ill omen", existing_tags => 'TheTag');

    my %ko_tags = LANraragi::Plugin::Metadata::Prettifier::get_tags( "", \%dummyhash, 0, 1, 0 );
    is( $ko_tags{title}, "The Black Cat of Ill Omen",  "The title didn't get title cased" );
    is( $ko_tags{tags},  "TheTag", "Tags should not be touched" );
}

done_testing();
