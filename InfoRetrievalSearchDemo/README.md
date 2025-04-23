## Project completed as part of coursework for Software Analysis and Design, 2024- University of Minnesota Duluth

### This project implements a basic Information Retrieval (IR) system in Java. 
It reads a set of text documents, processes the words, and provides functionality 
to score and retrieve the most relevant documents based on term frequency-inverse document frequency (TF-IDF).


### `Document.java`

Represents a single document, storing:
- `documentFileName`: the name of the file it was loaded from.
- `wordIndices`: a list of word indices that represent the document contents after processing.

### `DocumentSet.java`

The core class of the system. It:
- Reads files from a specified directory.
- Processes words in each file and assigns them a unique index.
- Computes **TF-IDF** scores to rank documents.
- Provides a method to retrieve the top K most relevant documents given a set of search words.

Key components:
- `wordMap`: Maps words to unique indices.
- `words`: Maps word indices to `WordInformation` objects.
- `documents`: List of all loaded `Document` objects.
- `showKMostRelevantDocuments(...)`: Calculates and displays the top K relevant documents.

### `WordInformation.java`

Stores metadata for each word, including:
- A unique index (`wordIndex`).
- The word itself (`wordString`).
- Total occurrences of the word across all documents (`numOccurrences`).

## Features

- **Word Indexing**: Assigns a unique ID to each distinct word.
- **TF-IDF Scoring**: Scores documents based on how relevant they are to a search query.
- **Search Interface**: Retrieve the top K relevant documents for a given set of keywords.

## How to Use

1. Using the provided document set, run Main.java
2. Enter a word you would like to search for within the document set. Press enter. The most relevant documents will be read back with the of the term
3. Repeat if desired
4. Or, enter 'quit' to break the loop
