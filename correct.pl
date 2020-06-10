#!/usr/bin/perl

use strict;
use warnings;
use FreezeThaw qw/thaw/;
use Data::Dumper;
use File::Slurp;
use JSON;

my $graph = shift @ARGV;

if(-e $graph) {
	my $graph_string = read_file($graph);
	my %graph_data = thaw $graph_string;
	
	my $json = '';
	while (<>) {
		$json .= $_;
	}
	
	$json =~ s#~.*##g;
	print "\n\n\n$json\n\n\n";
	my %json_data = %{decode_json $json};

	my @detected_words = ();
	if (exists $json_data{words}) {
		@detected_words = map { $_->{word} } @{$json_data{words}};
	} elsif (exists $json_data{transcripts}) {
		@detected_words = map { $_->{word} } @{$json_data{transcripts}[0]->{words}};
	} else {
		die "UNKNOWN STRUCTURE";
	}
	warn "ORIGINAL:\t".join(' ', @detected_words)."\n";

	my @alternatives = ();

	if(exists($json_data{transcripts})) {
		my @transcripts = map { $_->{words} } @{$json_data{transcripts}};
		push @alternatives, { 'words' => @transcripts };
	} else {
		@alternatives = @{$json_data{alternatives}};
	}
	#die Dumper @alternatives;

	my %alternatives_probabilities = ();

	foreach my $this_alternative (@alternatives) {
		my @these_words = map { $_->{word} } @{$this_alternative->{words}};
		my $this_probability = 1;

		foreach my $word_index (0 .. ($#these_words - 2)) {
			my $first_word = $these_words[$word_index];
			my $second_word = $these_words[$word_index + 1];
			my $third_word = $these_words[$word_index + 2];

			if(
				exists($graph_data{3}{$first_word}) && 
				exists($graph_data{3}{$first_word}{$second_word}) && 
				exists($graph_data{3}{$first_word}{$second_word}{$third_word})
			) {
				$this_probability += 3 * ($graph_data{2}{$first_word}{$second_word});
			} elsif(exists($graph_data{2}{$first_word}) && exists($graph_data{2}{$first_word}{$second_word})) {
				$this_probability += 2 * ($graph_data{2}{$first_word}{$second_word});
			} else {
				$this_probability -= 1;
			}

		}
		push @{$alternatives_probabilities{$this_probability}}, \@these_words;
	}
	#die Dumper \%alternatives_probabilities;

	my @keys = sort { $b <=> $a } keys %alternatives_probabilities;

	#die Dumper \%alternatives_probabilities;

	if(@keys) {
		if(@{$alternatives_probabilities{$keys[0]}} > 1) {
			print "ORIGINAL:\t".join(' ', @detected_words)."\n";
		} else {
			print "ALTERED:\t".join(' ', @{$alternatives_probabilities{$keys[0]}->[0]})."\n";
		}
	}

} else {
	die "$graph does not exist";
}
