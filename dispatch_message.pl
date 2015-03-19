#!/usr/bin/env -S perl -w

use strict;
use List::Util qw/reduce/;

sub uniq;
sub extract_folder;
sub choose_best_message_file;
sub choose_best_folder;

my @files = map { chomp; $_ } readline;
my @folders = uniq map { extract_folder } @files;

my $best_file = select_best_message_file( @files);
my $best_folder = select_best_folder( @folders);

@files = grep { $_ ne $best_file } @files;

print sprintf "%s => %s\n", $best_file, "../result/$best_folder";
print sprintf "%s => X\n", $_ foreach @files;

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
  return $_[0];
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

my @CHOOSERS = (
  sub { $_ ne "Удалённые" },
  sub { $_ ne "Deleted Items" },
  sub { $_ ne "Входящие" },
  sub { $_ ne "Inbox" }
);

use vars qw/%FOLDERS_PREFERENCE/; BEGIN {

%FOLDERS_PREFERENCE = (
  "Deleted Items до разделения папок" => 1000,
  "Deleted Items/! Deleted Items до разделения папок" => 2000,
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
  if ( @not_all_folders_preferenced )
  {
    die "Cannot make preference between folders '$folders[0]' and '$folders[1]' @not_all_folders_preferenced";
  }
  my @sorted_by_preference = sort { $FOLDERS_PREFERENCE{$a} <=> $FOLDERS_PREFERENCE{$b} } @folders;
  return $sorted_by_preference[0];
}

sub uniq
{
  my %seen;
  return grep { my $seen = $seen{$_}; $seen{$_} = 1; not $seen } @_;
}
