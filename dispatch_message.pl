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
sub not_a_misrosoft( $ );
sub choose_by_complex( $ $ );

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
  my @filenames = @_;
  my @wo_microsoft = grep { not_a_microsoft( $_) } @filenames;
  return $wo_microsoft[0] if @wo_microsoft == 1;
  my @compare_arguments = @filenames;
  push @compare_arguments, 'spam_mode' unless grep { $_ !~ /Спам/ } grep { $_ !~ /Spam/ } @filenames;
  push @compare_arguments, 'spam_mode' unless grep { $_ !~ /Удаленные/ } grep { $_ !~ /Deleted Items/ } @filenames;
  my $notthesame = system "compare_messages.sh", @compare_arguments;
  die "diff failed: $!" if $notthesame == -1;
  die join( join( "\nand\n", @filenames), "files\n", "\ndiffer") if $notthesame;
  my $chosen = eval {
    my $chosen = stdout_of( "choose_best_message.sh", $filenames[0], $filenames[1]);
    die "Empty output from choose_best_message.sh '$filenames[0]' '$filenames[1]'" unless $chosen;
    $chosen;
  };
  if ( defined $chosen )
  {
    chomp $chosen;
    return $chosen;
  };
  die "failed to choose best message: $@";
}

sub not_a_microsoft( $ )
{
  my ( $filename ) = @_;
  open( my $fh, '<', $filename) or die "open: '$filename': $!";
  while (my $line = <$fh>)
  {
    return 0 if $line =~ m'^Content-Type: application/ms-tnef;';
  }
  return 1;
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
  sub { $_ !~ /IPM_SUBTREE/ },
  sub { $_ !~ "^Удаленные/" },
  sub { $_ ne "Удаленные" },
  sub { $_ ne "Deleted Items" },
  sub { $_ ne "Отправленные" },
  sub { $_ !~ /^Sent Items\/?/ },
  sub { $_ ne "Входящие" },
  sub { $_ ne "Inbox" },
);
}

use vars qw/%FOLDERS_PREFERENCE/; BEGIN {

%FOLDERS_PREFERENCE = (
  "Personal/People/Машка" => 500,
  "Personal/People/Masha" => 500,
  "Personal/People/Саныч" => 500,
  "Personal/People/Sanych" => 500,
  "Personal/People/Serg Trushnikov" => 500,
  "Personal/People/Shurka" => 500,
  'Personal/People/Alex@Mati' => 500,
  'Personal/People/Utkis' => 500,
  'Personal/People/Polina' => 500,
  'Personal/People/Ira Moiseenko' => 500,
  "Personal/People" => 500,
  "Personal/Personal/Accounts" => 500,
  "Personal Stuff/CityCat" => 500,
  "Personal/Information/Sciences/Computer Sciences" => 500,
  "Personal/Information/Laws/Army" => 500,
  "Personal/Information/Wealth/Estate" => 500,
  "Personal/Это интересно/Политика" => 500,
  "Inbox/Ипотека" => 500,
  "Входящие/Отпуск" => 500,
  "Personal/Information/Useful Links" => 500,
  "Personal/Equipment/Cellurar" => 500,
  "Personal/Hobby/Money/Forex" => 600,
  "Personal/Fun" => 500,
  "Personal/Investigate" => 500,
  "Personal/History" => 500,
  "Personal/People/History" => 500,
  "Personal/Hobby/Racing" => 500,
  "Personal/Hobby/F1" => 500,
  "Personal/Hobby/Tourism" => 500,
  "Personal/Affairs/Загран" => 500,
  "Personal/Personal/Mobile" => 500,
  "Professional/Work/Satellite/PD/Clients/ITAR" => 500,
  "Professional/Work/Information" => 500,
  "Professional/Information/Network Tech" => 500,
  "Professional/Archive/PostgreStuff" => 500,
  "Professional/Hobby/Development" => 500,
  "Professional/Work/Archive/Telecom-Centre/History" => 500,
  "Professional/Work/Archive/Telecom-Centre/Maintenance/Common" => 500,
  "Professional/Work/Archive/Telecom-Centre/Maintenance/Network in common" => 500,
  "Professional/Work/WMS/PacketDelivery/External" => 500,
  "Professional/Work/Satellite/PD/Clients" => 500,
  "Входящие/Billing" => 500,
  "Queue/2 Tasks" => 500,
  "Queue" => 500,
  "Inbox/In-Out-Boxes" => 750,
  "Either Inbox or Deleted" => 750,
  "Inbox/Unimportant" => 750,
  "Входящие/Unimportant" => 750,
  "Inbox/! Inbox до разделения папок" => 750,
  "Входящие/Sort Old" => 750,
  "Входящие/Sort" => 750,
  "temp" => 750,
  "Queue/9 Hold before deletion" => 750,
  "Queue/9 Hold before deletion/Horoscopes" => 750,
  "Входящие/Spam/ManuallyIdentified" => 1000,
  "Входящие/Spam/AutoIdentified" => 1000,
  "Inbox/Spam/ManuallyIdentidied" => 1000,
  "Inbox/Spam/AutoIdentified" => 1000,
  "Inbox/Spam/Old" => 1000,
  "Inbox/Spam reports" => 1000,
  "Inbox/SpamInvest" => 1000,
  "Входящие/Антиспам" => 1000,
  "Входящие/Spam reports" => 1000,
  "Входящие/Spam/Old" => 1000,
  "Deleted Items до разделения папок" => 1500,
  "Deleted Items/! Deleted Items до разделения папок" => 2000,
);

}

use vars qw/%IS_BETTER_THAN/; BEGIN {

%IS_BETTER_THAN = (
  "Professional/Work/Archive/Telecom-Centre/Maintenance/САСП/Распоряжения и заявки" => {
    "Переписка с клиентами" => 1,
    "Распоряжения" => 1,
    "Распоряжения/Unchecked" => 1,
    "Professional/Work/Archive/Telecom-Centre/Распоряжения" => 1,
  },
  "Professional/Work/Archive/Telecom-Centre/Maintenance/САСП" => {
    "Распоряжения" => 1,
  },
  "Professional/Work/Archive/Telecom-Centre/Significant &- Important" => {
    "Significant &- Important" => 1
  },
  "Inbox/! Inbox до разделения папок" => {
    "Inbox/In-Out-Boxes" => 1,
    "Входящие/Sort Old" => 1
  },
  "Personal/People/Baranovsky" => {
    "Personal Stuff/Baranovsky" => 1
  },
  "Personal/People/Андрей" => {
    "Personal Stuff" => 1,
  },
  "Personal/People" => {
    "Personal/Personal" => 1,
    "Personal Stuff" => 1,
  },
  "Professional/Work/Archive/Telecom-Centre/Development/KIS" => {
    "Projects/KIS" => 1
  },
  "Входящие/SPF/WillPass" => {
    "Inbox/Спам!" => 1
  },
  "Входящие/Sort Old" => {
    "Отправленные" => 1
  },
  "Queue/1 In work/Tasks/3 Important/Security Updates" => {
    "Queue/1 In work/Tasks/2 Urgent" => 1
  },
  "Queue/1 In work/Tasks/2 Urgent" => {
    "Queue/2 Tasks" => 1
  },
  "Deleted Items/! Deleted Items до разделения папок" => {
    "Удаленные" => 1
  },
  "Personal/People/Машка" => {
    "Personal/History" => 1
  },
  "Deleted Items до разделения папок" => {
    "Входящие/Sort Old" => 1
  },
  "Professional/Information/Useful links" => {
    "Personal Stuff" => 1
  },
  "Входящие/Спам? (Помечено SPF)" => {
    "Inbox/Спам! (Помечено SPF-ом)" => 1
  },
  "Professional/Work/WMS" => {
    "Входящие/Billing" => 1
  },
  "Personal/People/Julia Itkis" => {
    "Personal/People/Utkis" => 1
  },
  "Personal/People/Sanych" => {
    "Personal/People/Саныч" => 1
  },
  "Personal/People/Саныч" => {
    "Personal/Archive" => 1
  },
  "Personal/Personal/Accounts" => {
    "Inbox/Spam/Old" => 1,
    "Входящие/Personal" => 1,
  },
  "Входящие/Отпуск" => {
    "Deleted Items/! Deleted Items до разделения папок" => 1
  },
  "Входящие/Отпуск - старое" => {
    "Входящие/Отпуск" => 1
  },
  "Входящие/Отпуск - старое/4Home" => {
    "Входящие/Отпуск/4Home" => 1
  },
  "Personal/Hobby/Racing" => {
    "Personal/Hobby/F1" => 1
  },
  "Personal/Study/Aspirant" => {
    "Personal Stuff" => 1
  },
  "Inbox/Спам! (Помечено SPF-ом)/Не пометилось" => {
    "Входящие/SPF/Unfiltered-3" => 1,
    "Входящие/SPF/Unfiltered-2" => 1,
  },
  "Professional/Information/Network Tech/IP Technologies" => {
    "Personal Stuff/CityCat" => 1,
    "Personal Stuff/InformatioPersonal Stuff/Information" => 1,
  },
  "Inbox/SpamInvest" => {
    "Входящие/SpamFight" => 1,
  },
  "Inbox/PD" => {
    "Входящие/PacketDelivery" => 1,
  },
  "Personal/People/Иришка" => {
    "Personal/People/Ira Moiseenko" => 1,
    "Personal/ЖЖ" => 1,
  },
  "Queue/9 Hold before deletion" => {
    "Deleted Items/! Deleted Items до разделения папок" => 1,
  },
  "Входящие/Цифры" => {
    "Professional/Work/Организационные вопросы" => 1,
  },
  "Personal/Information/Useful Links" => {
    "Personal Stuff" => 1,
  },
  "Professional/People" => {
    "Professional/Work/People" => 1,
  },
  "Professional/Information/Admin/AdminNT" => {
    "Personal Stuff/CityCat" => 1,
  },
  "Personal/Information/Useful Links" => {
    "Personal Stuff/Information" => 1,
    "Personal Stuff" => 1,
  },
  "Professional/Information/Development" => {
    "Personal Stuff/CityCat" => 1,
  },
  "Projects/Netflow 2" => {
    "My Projects/Netflow 2" => 1,
  },
  "Professional/Work/Archive/Telecom-Centre/Development/Netflow 2" => {
    "My Projects/Netflow 2" => 1,
  },
  "Queue/9 Hold before deletion/Horoscopes" => {
    "Personal Stuff/CityCat" => 1,
  },
  "Personal/Information/Technology/Internet" => {
    "Personal Stuff/CityCat" => 1,
  },
  "Personal/People/Мама" => {
    "Мама" => 1,
  },
  "Inbox/Important" => {
    "Входящие/Sort Old" => 1,
  },
  "Professional/Information/Admin/AdminUnix" => {
    "Personal Stuff" => 1,
    "Personal Stuff/Information" => 1,
  },
  "Входящие/SPF/WillReject/Not Spam" => {
    "Inbox/Не спам" => 1,
  },
  'Old Info/F~$&-ing hackers and providers' => {
    'F~$&-ing hackers and providers' => 1,
  },
  'Professional/Work/Archive/Telecom-Centre/Development/BIZRTK1' => {
    'Projects/BIZRTK' => 1,
  },
  'Professional/Information/Development/PostgreSQL' => {
    'Professional/Work/Archive/Telecom-Centre/History' => 1,
  },
  'Personal/Information/Sciences' => {
    'Personal Stuff' => 1,
  },
  'Personal/Hobby/Martial' => {
    'Personal/Hobby/Sport' => 1,
  },
  'Professional/Work/Archive/Telecom-Centre/Maintenance/Our Clients/RIA Novosti' => {
    'Our Clients/RIA Novosti' => 1,
  },
  'Входящие/Почтовые проблемы' => {
    'Inbox/Почта' => 1,
  },
  'Входящие/Жалобы от Naumen Service Desk' => {
    'Inbox/Naumen' => 1,
  },
  'Inbox/Питер' => {
    'Входящие/Personal' => 1,
  },
  'Personal/Information/Это интересно' => {
    'Personal Stuff/CityCat' => 1,
  },
  'Professional/Information/Security' => {
    'Personal Stuff/CityCat' => 1,
    'Personal Stuff/Information' => 1,
  },
  'Входящие/L8r' => {
    'Inbox/! Inbox до разделения папок' => 1,
  },
  'Personal/Information/Entertainment/Music' => {
    'Personal Stuff' => 1,
    'Personal Stuff/CityCat' => 1,
    'Personal Stuff/Information' => 1,
  },
);

}

sub choose_best_folder
{
  my @folders = @_;
#  print sprintf "%s\n", join ', ', map "'$_'", @folders;
  my $generated = generate_folder( $folders[0], $folders[1]);
  return $generated if $generated;
  foreach my $chooser ( @CHOOSERS ) {
    my @filtered = grep &$chooser, @folders;
    return $filtered[0] if @filtered == 1;
#    @folders = @filtered unless @filtered == 0;
  }
  my @not_all_folders_preferenced = grep { not exists $FOLDERS_PREFERENCE{$_} } @folders;
  if ( not @not_all_folders_preferenced )
  {
    my @all_folders_have_different_preference = scalar(@folders) - scalar( uniq( @FOLDERS_PREFERENCE{@folders}));
    if ( @all_folders_have_different_preference )
    {
      my @sorted_by_preference = sort { $FOLDERS_PREFERENCE{$a} <=> $FOLDERS_PREFERENCE{$b} } @folders;
      return $sorted_by_preference[0];
    }
  }
  my ( $folder1, $folder2 ) = @folders;
  if ( exists $IS_BETTER_THAN{$folder1}{$folder2} )
  { return $folder1 }
  if ( exists $IS_BETTER_THAN{$folder2}{$folder1} )
  { return $folder2 }
  my $chosen_by_complex = choose_by_complex( $folder1, $folder2);
  return $chosen_by_complex if $chosen_by_complex;
  my $chosen_by_substring = choose_by_substringing( $folder1, $folder2);
  return $chosen_by_substring if $chosen_by_substring;
  die "Cannot make preference between folders '$folder1' and '$folder2'";
}

sub substitute( $ $ $ )
{
  my ( $find, $substitute, $string ) = @_;
  $string =~ s/$find/$substitute/g;
  return $string;
}

sub is_a_deleted_items_folder( $ )
{
  return 1 if $_[0] eq 'Удаленные';
  return 1 if $_[0] eq 'Deleted Items';
  return 1 if $_[0] eq 'Deleted Items/! Deleted Items до разделения папок';
  return 0;
}

sub is_an_inbox_folder( $ )
{
  return 1 if $_[0] eq 'Inbox';
  return 1 if $_[0] eq 'Входящие';
  return 1 if $_[0] eq 'Входящие/Sort';
  return 0;
}

sub generate_folder( $ $ )
{
  my ( $folder1, $folder2 ) = @_;
  return "" unless grep { is_a_deleted_items_folder( $_) } @_;
  return "" unless grep { is_an_inbox_folder( $_) } @_;
  return "Either Inbox or Deleted";
}

use vars qw/@ESTIMATING_SUBSTITUTIONS/; BEGIN { @ESTIMATING_SUBSTITUTIONS = (

  [ '^Входящие', 'Inbox' ],
  [ '^Personal Stuff/', 'Personal/People/' ],
  [ '^Personal Stuff/', 'Personal/Information/' ],
  [ '^', 'Professional/Work/Archive/Telecom-Centre/' ],
  [ '^Projects/', 'Professional/Work/Archive/Telecom-Centre/Development/' ],
  [ '^Personal Stuff/', 'Personal/' ],

) }
  

sub choose_by_complex( $ $ )
{
  my ( $folder1, $folder2 ) = @_;
  foreach my $estimating_substitution ( @ESTIMATING_SUBSTITUTIONS ) {
    my ( $substitute, $replacement ) = @$estimating_substitution;
    if ( substitute( $substitute, $replacement, $folder1) eq $folder2 )
    { return $folder2 }
    if ( substitute( $substitute, $replacement, $folder2) eq $folder1 )
    { return $folder1 }
  }
  return 0;
}

sub list_contains_list( \@\@ )
{
  my ( $list1, $list2 ) = @_;
  my %hash1 = map { $_ => 1 } @$list1;
  return 0 if grep { not exists $hash1{$_} } @$list2;
  return 1;
} 

sub choose_by_substringing( $ $ )
{
  my ( $folder1, $folder2 ) = @_;
  if ( substr( $folder1, 0, length( $folder2)) eq $folder2 )
  { return $folder1 }
  if ( substr( $folder2, 0, length( $folder1)) eq $folder1 )
  { return $folder2 }
  my @path_elems_1 = split( '/', $folder1);
  my @path_elems_2 = split( '/', $folder2);
  if ( list_contains_list( @path_elems_1, @path_elems_2) )
  { return $folder1 }
  if ( list_contains_list( @path_elems_2, @path_elems_1) )
  { return $folder2 }
  return "";
}

sub uniq
{
  my %seen;
  return grep { my $seen = $seen{$_}; $seen{$_} = 1; not $seen } @_;
}
