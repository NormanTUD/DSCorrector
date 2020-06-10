#!/usr/bin/perl

use strict;
use warnings;
use FreezeThaw qw/freeze/;
use File::Slurp;
use Data::Dumper;
use List::Util 'sum';
use autodie;

my $graph_file = "graph.db";
my $train_dir = "folder";

if(!-e $graph_file) {
	my %graph = ();
	while (my $file = <$train_dir/*.txt>) {
		warn $file;
		my $contents = lc(read_file($file));
		$contents =~ s#[»«—]##g;
		my @sentences = map { $_ =~ s#^\s*##g;  $_ =~ s#\s*$##g; $_ } split /(?:[\.,!:()]|\R)/, $contents;
		
		foreach my $sentence (@sentences) {
			my @words = grep $_, split /[\s\n\r,\.!:;]/, $sentence;

			my $i = 0;
			while ($i < $#words) {
				$graph{2}{$words[$i]}{$words[$i + 1]}++;
				$i++;
			}

			$i = 0;
			while ($i < $#words - 2) {
				$graph{3}{$words[$i]}{$words[$i + 1]}{$words[$i + 2]}++;
				$i++;
			}
		}
	}


	my %probabilities = ();
	foreach my $first_word (sort { $a cmp $b } keys %{$graph{2}}) {
		my $words_after_first_word = $graph{2}{$first_word};
		my $number_of_hashkeys = scalar %{$words_after_first_word};
		my $number_of_all_occurances = sum values %{$words_after_first_word};

		foreach my $second_word  (sort { $a cmp $b } keys %{$words_after_first_word}) {
			my $this_number_occurences = $words_after_first_word->{$second_word};
			my $this_probability = sprintf("%.2f", ($this_number_occurences / $number_of_all_occurances) * 100);

			$probabilities{2}{$first_word}{$second_word} = $this_probability;
		}
	}

	foreach my $first_word (sort { $a cmp $b } keys %{$graph{3}}) {
		my $words_after_first_word = $graph{3}{$first_word};

		foreach my $second_word  (sort { $a cmp $b } keys %{$words_after_first_word}) {
			foreach my $third_word (sort { $a cmp $b } keys %{$words_after_first_word->{$second_word}}) {
				my $number_of_hashkeys = scalar %{$words_after_first_word->{$second_word}};
				my $number_of_all_occurances = sum values %{$words_after_first_word->{$second_word}};
				my $this_number_occurences = $words_after_first_word->{$second_word}->{$third_word};
				my $this_probability = sprintf("%.2f", ($this_number_occurences / $number_of_all_occurances) * 100);
				warn "\$probabilities{3}{$first_word}{$second_word}{$third_word} = $this_probability";
				$probabilities{3}{$first_word}{$second_word}{$third_word} = $this_probability;
			}
		}
	}

	open my $fh, '>>', $graph_file;
	print $fh freeze(%probabilities);
	close $fh;
} else {
	die "Graph already exists";
}
