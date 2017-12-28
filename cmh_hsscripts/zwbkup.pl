#!/usr/bin/perl
# Homeseer Z-Wave backup utility
# d. g. otto 2017/01/25

# usage: zwbkup.pl [ -l username/password ] [ hs3_host [ formid ... ] ]

use strict;
use warnings;
use English;
use Getopt::Std;
use POSIX qw(strftime);

use LWP::UserAgent;
use HTML::TokeParser;
use HTML::Entities;

# username & password for basic authorization
# can be hardcoded here or supplied on cmdline via -l user/pass
my $user = 'username';
my $pass = 'password';

# the default filename starts with an identifier of the interface type
# correct as necessary
my %IFMdlPfx = (
    0  => "None",        # None, 
    1  => "ZNet",        # HomeSeer Z-NET Ethernet
    4  => "HUSBZ1",      # HomeSeer SmartStick +
    6  => "UZB",         # Z-Wave.me UZB
    2  => "AeonZS",      # Aeon Labs Aeotec Z-Stick
    5  => "HSZT",        # HomeSeer Z-Troller
    8  => "ZC",          # ACT HomePro ZC Series
    11 => "ZThink",      # ControlThink ThinkStick
    14 => "AspireUSB",   # Cooper Aspire USB
    17 => "AspireRFUSB", # Cooper Aspire RF-USB
    19 => "HSSL",        # HomeSeer SmartStick Legacy
    20 => "CA8700",      # Intermatic CA8700
    23 => "HA22",        # Intermatic HA22
    25 => "UZB",         # Sigma Designs UZB
    29 => "WDUSB",       # Wayne-Dalton WDUSB-10
    32 => "ZSer",        # Generic Serial Controller
    35 => "ZNet",        # Ethernet Interface
);

# current timestamp portion of backup file name
my $now = strftime("%Y-%m-%d_%H.%M.%S", localtime);

# user agent object
my $ua = LWP::UserAgent->new;

# process option -l username/password
getopts('l:') or exit;
our $opt_l;
($user, $pass) = split('/', $opt_l, 2) if $opt_l;
$pass ||= '';

# cmdline parameter 1: HS3 host
my $host = shift;
$host ||= 'localhost';
my $url = "http://$host/ZWaveControllers";

# cmdline parameter 2+: form id(s) to process
# if none specified, query the form for all available
my @formids = @ARGV;
@formids = get($url) unless @formids;
print "Form ID(s): ", join(",", @formids), "\n";

use constant MAXPASSES => 5;

my ($submitted, %submit);
foreach my $formid (@formids) {
    # the get-post sequence usually must be executed twice (in certain instances more/less) -
    # 1st time selects action "Back Up this interface"
    # 2nd time sets the filename and submits the START button to perform the backup
    $submitted = 0;
    for (my $pass = 1; $pass <= MAXPASSES; $pass++) {
        print "==== Form ID $formid pass $pass ====\n";
        get($url, $formid);
        if ($submitted) {
            print "==== Form ID $formid done ====\n";
            last;
        }
        sleep 5;
    }
}

print 'Form ID count = ', scalar(@formids), '; Submit count = ', scalar(keys %submit), "\n";
exit (scalar(@formids) != scalar(keys %submit));

my (%friendly, %homeid);
sub get {
    my ($url, $formid) = @ARG;
    print "GET $url\n";
    my $rsp = $ua->get($url);
    print $rsp->status_line, "\n";
    exit unless $rsp->is_success;
    my $content = $rsp->as_string;
    my $p = HTML::TokeParser->new(\$content);
    my ($form, $select, $optval, $text, @postdata, %p);
    my ($friendly, $homeid, $tcol);
    my @formids;
    while (my $tok = $p->get_token) {
        my @tok = @$tok;
        my $op = shift @tok;
        if ($op eq 'S') {  # tag Start
            my ($tag, $attr, $attrseq, $origtext) = @tok;
            my %attr = %$attr;
            if ($tag eq 'form') {
                # form name
                $form = $attr{name};
            } elsif ($tag eq 'input') {
                if ($attr{type} eq 'text' and $attr{name}) {
                    if ($attr{name} =~ /^Friendly_([0-9A-F]+)/) {
                        # parse the Networks and Options form for 
                        # Network Friendly Name and Home ID
                        $homeid = $1;
                        $friendly = $attr{value};
                        $tcol = 1;  # table column number
                    } elsif ($attr{name} =~ /^NewName_[0-9A-F]+/) {
                        # Interface Name
                        # available for use when building the backup file name
                        $p{IFName} = $attr{value};
                    } elsif ($attr{name} =~ /^File_[0-9A-F]+/) {
                        # set the backup file name as appropriate
                        my $filename = $attr{value};
                        $filename = generate_filename($filename, %p);
                        push(@postdata, $attr{name} => $filename);
                    }
                }
            } elsif ($tag eq 'select') {
                # name of select pulldown form field
                $select = $attr{name};
            } elsif ($tag eq 'option') {
                # an option within a select form field
                $optval = $attr{value};
                if ($attr{selected} and $select =~ /^IFModel_/) {
                    # index of selected Interface Model
                    # available for use when building the backup file name
                    $p{IFModelIndex} = $attr{value} || 0;
                }
            } elsif ($tag eq 'button') {
                # submit button
                if ($attr{name} =~ /^GO_[0-9A-F]+/) {
                    # submit the form
                    push(@postdata, %attr);
                }
            }
        } elsif ($op eq 'E') {  # tag End
            my $tag = shift @tok;
            if ($tag eq 'form') {
                # end of form - post queued changes
                if ($form and $form =~ /^Form_([0-9A-F]+)/ and @postdata) {
                    my $thisid = $1;
                    push(@formids, $thisid);
                    if ($formid and $formid eq $thisid) {
                        post($url, @postdata);
                    }
                }
                undef $form;
                undef @postdata;
                undef %p;
            } elsif ($tag eq 'select') {
                undef $select;
            } elsif ($tag eq 'option') {
                # end of option - text label is available for query
                if ($select =~ /^OpSelect_/ and $text =~ /back\s*up/i) {
                    # set action to 'Back Up this interface'
                    # unless the form has already been submitted
                    (my $button = $select) =~ s/^[^_]+/GO/;
                    $button .= '-' . $optval;
                    push(@postdata, $select => $optval) unless $submit{$button};
                }
                undef $optval;
            } elsif ($tag eq 'td') {
                # table data
                if ($tcol and $tcol++ == 4) {
                    # Interface Name is in 4th column of table displaying
                    # Z-Wave Networks and Options
                    my $ifname = $text;
                    # Network Friendly Name and Home ID
                    # available for use when building the backup file name
                    $friendly{$ifname} = $friendly;
                    $homeid{$ifname} = $homeid;
                    undef $tcol;
                }
            }
        } elsif ($op eq 'T') {  # Text
            ($text) = @tok;
            $text =~ s/[\r\n]//g;
            $text =~ s/^\s+|\s+$//g;
            $text = decode_entities($text);
        }
    }
    sleep 1;
    # this seems to keep it happy...
    post($url, action => 'updatetime');
    sleep 1;
    return @formids;
}

# POST the changes
sub post {
    my ($url, @postdata) = @ARG;
    # don't submit same button more than once
    my %p = @postdata;
    if ($p{name}) {
        return if $submit{$p{name}};
        $submit{$p{name}}++;
        $submitted = 1;
    }

    print "POST $url\n[\n";
    for (my $ii = 0; $ii < @postdata; $ii += 2) {
        print "  $postdata[$ii] => $postdata[$ii+1]\n";
    }
    print "]\n";

    my $rsp = $ua->post($url, \@postdata);
    print $rsp->status_line, "\n";
    exit unless $rsp->is_success;
}

# routine to generate the backup file name
# default behaviour is
# {IFModel}_{FriendlyName}_{HomeID}_{TimeStamp}.ZWave
# customize as desired 
sub generate_filename {
    my ($givenname, %p) = @ARG;

    # interface name
    my $ifname = $p{IFName};

    # Network Friendly Name
    my $friendly = $friendly{$ifname};

    # HomeID
    my $homeid = $homeid{$ifname};

    # map interface model index to abbreviation defined above
    my $idx = $p{IFModelIndex};
    my $mdlpfx = $IFMdlPfx{$idx} || 'ZWave';

    # build the darn thing!
    my $newname = "${mdlpfx}_${friendly}_${homeid}_${now}.ZWave";
    return $newname;
}

# setup to supply credentials if challenged
no warnings 'redefine';
sub LWP::UserAgent::get_basic_credentials {
    my ($self, $realm, $url, $isproxy) = @ARG;
    return ($user, $pass);
}

