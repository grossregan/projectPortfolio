package edu.umn.d.cs2511.F24_2511_SimpleIR;

import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        // Directory containing the files used in this test
        String dirName = "/Users/regangross/IdeaProjects/F24_2511_SimpleIR-master/src/main/Data/FederalistPapers"; // Replace with your file's name
        // docs represents the set of documents read from the directory above
        DocumentSet docs = new DocumentSet(dirName);

        // Repeatedly read in a set of search terms to use and then call the code to see which documents
        // have the highest TF-IDF values for those terms
        Scanner scanner = new Scanner(new InputStreamReader(System.in));
        ArrayList<Integer> searchWords = null;
        String desiredW = null;
        do {
            System.out.print("Terms you wish to look for: ");
            String line = scanner.nextLine();
            desiredW = line.toLowerCase();
            Scanner lineScanner = new Scanner(line);
            lineScanner.useDelimiter("[ |\t|\n|.|!|,|;|:|(|)]+");
            searchWords = new ArrayList<>();
            while (lineScanner.hasNext()) {
                String word = lineScanner.next().toLowerCase();
                int wordIndex = docs.indexOfWord(word);
                searchWords.add(wordIndex);
            }

            // Calls the code you will need to add
            docs.showKMostRelevantDocuments(searchWords,3);

        } while (!desiredW.equals("quit"));
    }
}