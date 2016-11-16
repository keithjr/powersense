#!/usr/bin/perl

# Keith Morse
# 11/12/2016

# Daemon to run rtl-amr (via rtl_tcp) and process the resulting data
# for visualization.


use strict;
use warnings;


#Forcibly detach rltsdr driver from device to prevent this error:

#Kernel driver is active, or device is claimed by second instance of librtlsdr.
#In the first case, please either detach or blacklist the kernel module
#(dvb_usb_rtl28xxu), or enable automatic detaching at compile time.

# TODO somehow put this in a conf file
# sudo modprobe -r dvb_usb_rtl28xxu

# Fork rtl_tcp process, send output to a log file
#  rtl_tcp

# Execute rtl-amr process
#/home/keithjr/gocode/bin/rtlamr -filterid=41280253

# Processing the results
my $log = shift;
open LOG,$log or die "Could not open ${log}:$!\n";
my @samples;
my %sample;
my $timestamp;
my $prev_timestamp;
my $consumption;
while (<LOG>) {
  #TODO loosen the regexp 
  if (/\{Time:(\S+T\d+:\d+):\d+\.\d+ SCM:{ID:41280253 Type: 5 Tamper:{Phy:00 Enc:02} Consumption: (\d+)/) {
    $timestamp = $1;
    $consumption = $2;
    #sample tag is timesample truncated down to the minute
#    $samples{$timestamp} = $consumption;
#    print "$samples{$timestamp}\n";
#    $sample{timestamp} = $timestamp;
#    $sample{consumption} = $consumption;
    if ((!defined $prev_timestamp) || ($prev_timestamp ne $timestamp)) {
      push @samples, { 
        timestamp => $timestamp,
        consumption => $consumption
      };
    }
    $prev_timestamp = $timestamp;
        
  }
}

foreach my $entry (@samples) {
  print "$entry->{timestamp}  - $entry->{consumption}\n";
}

# First sample sets initial time
# Take one packet from the data stream every sample period
# Drop intermediary packets
# Calculate the delta from the previous sample (unless this is the first)
