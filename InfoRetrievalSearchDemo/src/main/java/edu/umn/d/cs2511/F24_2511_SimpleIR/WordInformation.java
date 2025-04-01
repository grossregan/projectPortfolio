package edu.umn.d.cs2511.F24_2511_SimpleIR;

// A WordInformation object contains the information about an individual word
// numberOfWords is a static (global) variable for the entire class that is used
//   to assign word indices
// wordIndex is the specific number given to THIS word
// wordString is the word (e.g., "the", "happy", or "catepillar")
// numOccurrences is the count of how many times the word occurs across all of the documents (you
//   will likely not use that value)
public class WordInformation {
    private static int numberOfWords = 0;
    private int wordIndex;
    private String wordString;
    private int numOccurrences;
    private WordInformation() {}
    public WordInformation(String w) {
        wordString = w;
        wordIndex = numberOfWords++;
        numOccurrences = 0;
    }
    public int getWordIndex() {
        return wordIndex;
    }
    public void incrementOccurrences() { numOccurrences++; }
    public int getNumOccurrences() { return numOccurrences; }
    public String getWordString() { return wordString; }
}
