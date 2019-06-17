# WordPredictionR

## Executive Summary
This application is designed to demonstrate basic natural language processing for the purpose of next word prediction, implemented online through R and Shiny as a web app.


## Introduction
The corpus for this project was created from text data scraped from Twitter, Blogs and News websites available at the following link. https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip

Only the english texts were used for this project. It was found that the data import functioned more reliably when a connection was opened before reading each file in by line. The size of the files created approximately matches the declared file size in Windows Explorer which indicates successful import of these large files.

Libraries used for this project are data.table, quanteda, stringr, tm and shiny.

## Data Import and Cleaning
Due to the large file size, a 50% subset was created for training. Computational difficulty and the size of output DFMs and ngrams increases rapidly with input size and the amount of terms involved. 
During tokenisation, all punctuation, symbols, URL's, twitter handles, numbers and hyphens were removed and all text was converted to lower case. It was decided not to stem the words,as this would require stemming input text to the prediction algorithm too to prevent loss of valid matches.

Working on a standard desktop PC, it was found that with regular saving of outputs and memory clearing, there was no need to use virtual memory or further partition computations in order to compute DFMs and create three word ngrams using 50% of the corpus data. To make use of more training data, the corpus may be further subsetted and the resulting ngams added after aggregation. Combinations that appeared fewer than 5 times in the corpus were removed to trim the DFMs down to usable data only


Condensed tables were created as search-able dictionaries ranked by occurrence to be uploaded and for the prediction application to search, rather than performing the tokenisation and following computations online. This results in a faster prediction application and less server bandwidth.

## Prediction Algorithm 
The prediction algorithm takes two inputs, a string to match and a number of predictions to return.
The string is split, numbers removed and converted to lower case. The longest table used in prediction is based on a trigram model and so the last two words of the string are saved and the rest is ignored.

The prediction algorithm searches through the table of two word combinations where the first word is the same as the last word of the input string, and searches through the three word combinations where the first and second word match the second last and last words of the input string. The top 50 occuring unigram words from the corpus are used as a pre-generated list to ensure there are always results.

To return a list of predictions, a weighed sum of the unigram, bigram and trigram results is taken. Unlike a pure back off method, the weightings can be modified to change the importance of pure nuber of results versus context in which the result was found. An example set of weightings was used based on top and average counts for each table, though these numbers could be trained for using the rest of the corpus.

The top n number of predictions are returned based on the slider input


## Acknowledgments
Thanks to Jeff Leek, Roger Peng and Brian Caffo from Johns Hopkins
Thanks to Coursera.org and SwiftKey for facilitation of this capstone project
