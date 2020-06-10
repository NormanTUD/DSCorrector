# DSCorrector

Allows to create a graph of di- and trigrams of utterances from text files. E.g.

This house is yellow.

This creates:

> 2:

> "this" -> "house" = 1

> "house" -> "is" = 1

> "is" -> yellow = 1

> 3:

> "this" -> "house" -> "is" = 1

>"house" -> "is" -> "yellow" = 1

When you add other sentences, the probabilites will change according to how many utterances of this were recorded.

# How to train

Put all of your txt-files into the folder `folder`. Run `perl create_graph.pl`.

# How to use

You need to be able to pass the JSON-output of DeepSpeech into STDOUT and pipe it into the `correct.pl` after creating a graph.

Example:

> cat dat.json | perl correct.pl graph.db

# Caveats

Not every word is checked. This is about to be changed soon hopefully. Right now, only the sentence alternatives as a whole are checked.

The default graph.db consists of `Mars` by Fritz Zorn and the german Bible.
