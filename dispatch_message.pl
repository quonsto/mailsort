#!/usr/bin/env -S perl -w

use strict;
use File::Basename;
use File::Path qw/make_path/;
use List::Util qw/reduce/;

sub uniq;
sub extract_folder;
sub choose_best_message_file;
sub choose_best_folder;
sub move_file( $ $ );
sub delete_file( $ );

my @files = map { chomp; $_ } readline;
my @folders = uniq map { extract_folder } @files;

my $best_file = select_best_message_file( @files);
my $best_folder = select_best_folder( @folders);

@files = grep { $_ ne $best_file } @files;

move_file( $best_file, "../result/$best_folder");
delete_file( $_) foreach @files;

sub move_file( $ $ )
{
  my ( $from, $to ) = @_;
  my $fname = basename( $from);
  print sprintf "%s => %s\n", $from, $to;
  make_path $to;
  rename $from, "$to/$fname" or die "rename $from to $to/$fname: $!";
}

sub delete_file( $ )
{
  my ( $file ) = @_;
  print sprintf "%s => X\n", $file;
  unlink $file or die "unlink: $file: $!";
}

sub select_best_message_file
{
  my @files = @_;
  return reduce { choose_best_message_file $a, $b } @files;
}

sub choose_best_message_file( $ $ )
{
  my $notthesame = system "compare_messages.sh", @_;
  die "diff failed: $!" if $notthesame == -1;
  die "files @{[join ' and ', @_]} differ" if $notthesame;
  my $chosen = eval {
    my $chosen = stdout_of( "choose_best_message.sh", $_[0], $_[1]);
    die "Empty output from choose_best_message.sh '$_[0]' '$_[1]'" unless $chosen;
    $chosen;
  };
  if ( defined $chosen )
  {
    chomp $chosen;
    return $chosen;
  };
  die "failed to choose best message: $@";
}

use IPC::Open3;
use Symbol 'gensym';
use IO::Select;

sub stdout_of 
{
  my @program_and_args = @_;
  my ( $stdin, $stdout, $stderr ) = ( undef, undef, gensym() );
  my $pid = open3( $stdin, $stdout, $stderr, @program_and_args);
  my $select = IO::Select->new();
  $select->add( $stdout, $stderr);
  my ( $out, $err ) = map "", 0..1;
  while ( my @ready = $select->can_read )
  {
    foreach my $fh ( @ready )
    {
      my $line;
      my $len = sysread $fh, $line, 4096;
      if ( not defined $len ) 
      {
        die "Error from child: $!\n";
      } 
      elsif ( $len == 0 )
      {
        # Finished reading from this FH because we read
        # 0 bytes.  Remove this handle from $sel.  
        # we will exit the loop once we remove all file
        # handles ($outfh and $errfh).
        $select->remove( $fh);
        next;
      } 
      else 
      { 
        # we read data alright
        if ( $fh == $stdout ) 
        {
          $out .= $line;
        } 
        elsif ( $fh == $stderr ) 
        {
          $err .= $line;
        } 
        else 
        {
          die "Shouldn't be here\n";
        }
      }
    }
  }
  waitpid $pid, 0;
  my $exit_status = $? >> 8;
  die( $err or "child failed") if $exit_status;
  return $out;
}

sub extract_folder
{
  my $filename = $_;
  my @parts = split /\//, $filename;
  pop @parts; # file name
  pop @parts if grep { $parts[$#parts] eq $_ } qw/cur new/;
  shift @parts if $parts[0] eq '.';
  shift @parts;
  return join "/", @parts;
}

sub select_best_folder
{
  my @folders = @_;
  return reduce { choose_best_folder( $a, $b) } @folders;
}

use vars qw/@CHOOSERS/; BEGIN {
@CHOOSERS = (
  sub { $_ ne "Удаленные" },
  sub { $_ ne "Deleted Items" },
  sub { $_ ne "Входящие" },
  sub { $_ ne "Inbox" },
  sub { $_ !~ /IPM_SUBTREE/ }
);
}

use vars qw/%FOLDERS_PREFERENCE/; BEGIN {

%FOLDERS_PREFERENCE = (
  "Personal/People/Машка" => 499,
  "Personal/People/Masha" => 500,
  "Personal/People" => 501,
  "Personal Stuff/CityCat" => 599,
  "Personal/Information/Sciences/Computer Sciences" => 600,
  "Personal/Fun" => 750,
  "Inbox/! Inbox до разделения папок" => 999,
  "Inbox/Spam/Old" => 1000,
  "Inbox/Spam reports" => 1000,
  "Входящие/Spam reports" => 1001,
  "Входящие/Spam/Old" => 1001,
  "Deleted Items до разделения папок" => 1500,
  "Deleted Items/! Deleted Items до разделения папок" => 2000,
);

}

use vars qw/%IS_BETTER_THAN/; BEGIN {

%IS_BETTER_THAN = (
  "Professional/Work/Archive/Telecom-Centre/Maintenance/САСП/Распоряжения и заявки" => {
    "Переписка с клиентами" => 1
  }
);

}

sub choose_best_folder
{
  my @folders = @_;
#  print sprintf "%s\n", join ', ', map "'$_'", @folders;
  foreach my $chooser ( @CHOOSERS ) {
    my @filtered = grep &$chooser, @folders;
    return $filtered[0] if @filtered == 1;
#    @folders = @filtered unless @filtered == 0;
  }
  my @not_all_folders_preferenced = grep { not exists $FOLDERS_PREFERENCE{$_} } @folders;
  if ( not @not_all_folders_preferenced )
  {
    my @sorted_by_preference = sort { $FOLDERS_PREFERENCE{$a} <=> $FOLDERS_PREFERENCE{$b} } @folders;
    return $sorted_by_preference[0];
  }
  my ( $folder1, $folder2 ) = @folders;
  if ( exists $IS_BETTER_THAN{$folder1}{$folder2} )
  { return $folder1 }
  if ( exists $IS_BETTER_THAN{$folder2}{$folder1} )
  { return $folder2 }
  die "Cannot make preference between folders '$folder1' and '$folder2'";
}

sub uniq
{
  my %seen;
  return grep { my $seen = $seen{$_}; $seen{$_} = 1; not $seen } @_;
}
