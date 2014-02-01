# /AUTOAWAY <n> - Mark user away after <n> seconds of inactivity
# /AWAY - play nice with autoaway
# Automatically marks user as away when X server is idle
# (c) 2000 Larry Daffner (vizzie@airmail.net)
#     You may freely use, modify and distribute this script, as long as
#      1) you leave this notice intact
#      2) you don't pretend my code is yours
#      3) you don't pretend your code is mine
#
# share and enjoy!

# This is an adaptation of the auto_away.pl script by Larry Daffner.
# This version automatically sets the user's away status based on
# X server idle time, as reported by the xprintidle command.
#
# To install xprintidle on Debian install the package, xprintidle
#
# /autoaway <n> will mark you as away automatically if you have not used
# the mouse or keyboard in <n> seconds. (<n>=0 disables the feature) It
# will also automatically unmark you away the next time you type
# a command, move the mouse, or press a key.
#
# Note that using the /away command will disable the autoaway mechanism,
# as well as the autoreturn. (when you unmark yourself, the autoaway wil
# restart again)
#
# The script currently checks idle time by polling on a 30 second
# interval.  So there will be a delay after resuming activity before you
# are unmarked as away.  But typing a command in irssi will unmark you
# immediately.

# Thanks to Adam Monsen for multiserver and config file fix
#
# X server idle time adaptation by Jesse Hallett

use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);
$VERSION = "0.3";
%IRSSI = (
    authors => 'Larry "Vizzie" Daffner, Jesse Hallett',
    contact => 'jesse@sitr.us',
    name => 'Away on idle',
    description => 'Automatically goes away after defined inactivity, determined by X server idle time',
    license => 'BSD',
    url => 'http://www.flamingpackets.net/~vizzie/irssi/',
    changed => '2014-01-31',
    changes => 'Uses X server idle time to determine inactivity'
);

my $autoaway_sec;
my $autoaway_to_tag;
my $autoaway_poll_interval = 30;  # 30 seconds
my $away_state;     # false
my $set_manually;   # false
my $changing_state; # false
my $message;

#
# /AUTOAWAY - set the autoaway timeout
#
sub cmd_autoaway {
  my ($data, $server, $channel) = @_;
  my @params = split " ", $data;
  my $timeout = shift @params;

  $message = join " ", @params;
  $message =~ s/^\s+|\s+$//g;  # Trim whitespace

  if (!($timeout =~ /^[0-9]+/)) {
    Irssi::print("autoaway: usage: /autoaway <seconds> [<message>]");
    return 1;
  }

  if (system("which xprintidle >/dev/null")) {
    Irssi::print("Could not locate the executable, xprintidle. Please install this utility.");
    return 1;
  }

  $autoaway_sec = $timeout;

  if ($autoaway_sec) {
    Irssi::print("autoaway timeout set to $autoaway_sec seconds");
  } else {
    Irssi::print("autoway disabled");
  }

  if (defined($autoaway_to_tag)) {
    Irssi::timeout_remove($autoaway_to_tag);
    $autoaway_to_tag = undef;
  }

  if ($autoaway_sec) {
    $autoaway_to_tag =
      Irssi::timeout_add($autoaway_poll_interval*1000, "check_idle_time", undef);
  }
}

#
# away = Set us away or back, within the autoaway system
sub cmd_away {
  my ($data, $server, $channel) = @_;

  $set_manually = 1;

  if ($data) {
    $away_state = 1;
  }
  else {
    $away_state = 0;
  }
}

sub check_idle_time {
  my $idle_time = `xprintidle` / 1000;

  if ($idle_time >= $autoaway_sec) {
    auto_timeout();
  }
  elsif ($idle_time < $autoaway_sec) {
    auto_resume();
  }
}

sub auto_timeout {
  if ($away_state || $changing_state) {
    return 1;
  }

  my $msg = $message || "autoaway after $autoaway_sec seconds";
  if (!defined($msg)) {
    $msg = "autoaway after $autoaway_sec seconds";
  }

  # we're in the process.. don't touch anything.
  $changing_state = 1;
  foreach my $server (Irssi::servers()) {
      $server->command("/AWAY -one $msg");
  }
  $changing_state = 0;

  $away_state = 1;
  $set_manually = 0;
}

sub auto_resume {
  if (!$away_state || $set_manually || $changing_state) {
    return 1;
  }

  $changing_state = 1;
  foreach my $server (Irssi::servers()) {
      $server->command("/AWAY -one");
  }
  $changing_state = 0;

  $away_state = 0;
  $set_manually = 0;
}

Irssi::settings_add_int("misc", "autoaway_timeout", 0);
Irssi::settings_add_str("misc", "autoaway_message", "");

my $autoaway_default = Irssi::settings_get_int("autoaway_timeout");
$message = Irssi::settings_get_str("autoaway_message");
if ($autoaway_default) {
  cmd_autoaway($autoaway_default);
}

Irssi::command_bind('autoaway', 'cmd_autoaway');
Irssi::command_bind('away', 'cmd_away');
Irssi::signal_add('send command', 'auto_resume');
