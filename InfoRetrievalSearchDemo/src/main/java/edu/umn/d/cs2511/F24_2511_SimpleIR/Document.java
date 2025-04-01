package edu.umn.d.cs2511.F24_2511_SimpleIR;

import java.util.ArrayList;

// A Document is represented by the documentFileName it was read from and an ArrayList of the word indices
//   assigned to those words
// So if a document contained the words "The giant yellow flower was taller than the red flower"
//   and the system assigned the indices of the words as follows:
//   the - 1
//   giant - 137
//   yellow - 150
//   flower - 201
//   was - 41
//   taller - 85
//   than - 29
//   red - 145
// Then the wordIndices array for this file would contain:
//   1, 137, 150, 201, 41, 85, 29, 1, 145, 201
// NOTE: I made these indices up, the system simply assigns the next index # to a word whenever a new word is found
public class Document {
    private ArrayList<Integer> wordIndices;
    private String documentFileName;

    private Document() {}
    public Document(ArrayList<Integer> wIs, String df) {
        documentFileName = df;
        wordIndices = wIs;
    }
    public ArrayList<Integer> getWordIndices() {
        return wordIndices;
    }

    public String getDocumentFileName() {
        return documentFileName;
    }
}
