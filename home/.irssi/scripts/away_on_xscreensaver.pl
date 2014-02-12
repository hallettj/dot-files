# /AUTOAWAY <n> - Mark user away after <n> seconds of inactivity
# /AWAY - play nice with autoaway
# Automatically marks user as away when xscreensaver is active
# (c) 2000 Larry Daffner (vizzie@airmail.net)
#     You may freely use, modify and distribute this script, as long as
#      1) you leave this notice intact
#      2) you don't pretend my code is yours
#      3) you don't pretend your code is mine
#
# share and enjoy!

# This is an adaptation of the auto_away.pl script by Larry Daffner.
# This version automatically sets the user's away status based on
# whether the screen is blanked by xscreensaver.
#
# /autoaway <message> will mark you as away automatically when the
# screen blanks.  It will also automatically unmark you away the next
# time you type a command or unlock the screen.  Use /autoaway with no
# arguments to disable.
#
# Note that using the /away command will disable the autoaway mechanism,
# as well as the autoreturn. (when you unmark yourself, the autoaway wil
# restart again)
#
# The script currently checks xscreensaver state by polling on a 10
# second interval.  So there will be a delay after resuming activity
# before you are unmarked as away.  But typing a command in irssi will
# unmark you immediately.

# Thanks to Adam Monsen for multiserver and config file fix
#
# xscreensaver state adaptation by Jesse Hallett

use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);
$VERSION = "0.3";
%IRSSI = (
    authors => 'Larry "Vizzie" Daffner, Jesse Hallett',
    contact => 'jesse@sitr.us',
    name => 'Away on idle',
    description => 'Automatically goes away when xscreensaver blanks the screen',
    license => 'BSD',
    url => 'http://www.flamingpackets.net/~vizzie/irssi/',
    changed => '2014-01-31',
    changes => 'Uses X server idle time to determine inactivity'
);

my $autoaway_to_tag;
my $autoaway_poll_interval = 10;  # 10 seconds
my $away_state;     # false
my $set_manually;   # false
my $changing_state; # false
my $message;

#
# /AUTOAWAY - set the autoaway timeout
#
sub cmd_autoaway {
  my ($msg, $server, $channel) = @_;
  $msg =~ s/^\s+|\s+$//g;  # Trim whitespace

  if (system("which xscreensaver-command >/dev/null")) {
    Irssi::print("Could not locate the xscreensaver-command executable. Please install xscreensaver to use this utility.");
    return 1;
  }

  if (system("xscreensaver-command -time 2>&1 >/dev/null")) {
    Irssi::print("It appears that xscreensaver is not running. This utility will not work without xscreensaver.")
  }

  if ($msg) {
    Irssi::print("autoaway enabled");
    $message = $msg;
  }
  else {
    Irssi::print("autoaway disabled");
  }

  if (defined($autoaway_to_tag)) {
    Irssi::timeout_remove($autoaway_to_tag);
    $autoaway_to_tag = undef;
  }

  if ($msg) {
    $autoaway_to_tag =
      Irssi::timeout_add($autoaway_poll_interval*1000, "check_idle", undef);
  }
}

#
# away = Set us away or back, within the autoaway system
sub cmd_away {
  my ($data, $server, $channel) = @_;

  if ($changing_state) {
    return 1;
  }

  $set_manually = 1;

  if ($data) {
    $away_state = 1;
  }
  else {
    $away_state = 0;
  }
}

sub check_idle {
  my $idle = !system("xscreensaver-command -time 2>/dev/null | grep -Eq ' blanked|locked'");

  if ($idle) {
    auto_timeout();
  }
  else {
    auto_resume();
  }
}

sub auto_timeout {
  if ($away_state || $changing_state) {
    return 1;
  }

  # we're in the process.. don't touch anything.
  $changing_state = 1;
  foreach my $server (Irssi::servers()) {
      $server->command("/AWAY -one $message");
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

Irssi::settings_add_str("misc", "autoaway_message", "");

$message = Irssi::settings_get_str("autoaway_message");
if ($message) {
  cmd_autoaway($message);
}

Irssi::command_bind('autoaway', 'cmd_autoaway');
Irssi::command_bind('away', 'cmd_away');
# Irssi::signal_add('send command', 'auto_resume');
