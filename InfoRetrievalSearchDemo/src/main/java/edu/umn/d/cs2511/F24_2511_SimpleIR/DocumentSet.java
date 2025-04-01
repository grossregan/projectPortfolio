package edu.umn.d.cs2511.F24_2511_SimpleIR;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

public class DocumentSet {
    // Path to the directory where files were read from
    private String docDirectory;

    // A mapping to let you look up what ID# a word has been given, you say wordMap.get("taxes") and
    // it will return the index that has been assigned to the word taxes
    private HashMap<String, Integer> wordMap; // A mapping for all of the words in all the documents

    // A mapping from the word Index to the WordInformation object associated with the index
    private HashMap<Integer, WordInformation> words;

    // An ArrayList of Document objects, one for each file read
    private ArrayList<Document> documents;

    // Java to get the list of non-directory files in a directory
    private ArrayList<String> getDirectoryFileNames(String dir) throws IOException {
        ArrayList<String> fileSet = new ArrayList<>();
        try (DirectoryStream<Path> stream = Files.newDirectoryStream(Paths.get(dir))) {
            for (Path path : stream) {
                if (!Files.isDirectory(path)) {
                    fileSet.add(path.getFileName()
                            .toString());
                }
            }
        }
        return fileSet;
    }

    // No argument constructor should not be called
    private DocumentSet() {}

    // Check if a word has already been assigned an index, if yes then simply return that index
    // if no, then add it to wordMap, assign it a new index and create a new WordInformation object for it
    private int findInsertWord(String word) {
        int wIndex;
        WordInformation wordInfo;
        if (wordMap.containsKey(word)) {
            wIndex = wordMap.get(word);
            wordInfo = words.get(wIndex);
        }
        else {
            wordInfo = new WordInformation(word);
            wIndex = wordInfo.getWordIndex();
            wordMap.put(word,wIndex);
            words.put(wIndex,wordInfo);
        }
        wordInfo.incrementOccurrences();
        return wIndex;
    }

    // Read all of the words from a document file and return an ArrayList of the indices assigned
    // to the words in the document
    private ArrayList<Integer> readDocumentWords(String docFile) {
        ArrayList<Integer> wordIndices = new ArrayList<>();
        try (Scanner scanner = new Scanner(new File(docFile))) {
            scanner.useDelimiter("[ |\t|\n|.|!|,|;|:|(|)]+");
            while (scanner.hasNext()) {
                String word = scanner.next().toLowerCase();
                int wIndex = findInsertWord(word);
                wordIndices.add(wIndex);
            }
        } catch (FileNotFoundException e) {
            System.err.println("File not found: " + e.getMessage());
        }
        return wordIndices;
    }

    private double calcTF(int index, Document d) {
        List<Integer> wordIndices = d.getWordIndices();
        long termCount = wordIndices.stream().filter(w -> w == index).count();
        return(double) termCount/wordIndices.size();
    }

    private double calcIDF(int index){
        long countContainingWord = documents.stream().filter(doc -> doc.getWordIndices().contains(index)).count();
        if(countContainingWord == 0){
            return 0;
        }
        return Math.log((double)documents.size()/countContainingWord/Math.log(2));
    }

    // Look up a word, if not in the map simply return a -1 to indicate it is not there, otherwise return
    // its index
    public Integer indexOfWord(String w) {
        if (wordMap.containsKey(w)) {
            return wordMap.get(w);
        }
        else {
            return -1;
        }
    }

    // Constructor for the class, takes a directory that should contain files, reads each of those files
    // adding the words from the file to the list of words and then creating a Document object with the
    // ArrayList of all the wordIndices in that file
    public DocumentSet(String dir) {
        wordMap = new HashMap<>();
        words = new HashMap<>();
        documents = new ArrayList<>();
        try {
            ArrayList<String> files = getDirectoryFileNames(dir);
            docDirectory = dir;
            for (String f : files) {
                ArrayList<Integer> docWords = readDocumentWords(Paths.get(dir, f).toString());
                documents.add(new Document(docWords,dir + f));
            }
        }
        catch (IOException e) {
            System.err.println("Error! Path " + dir + " is not valid");
        }
    }

    public void showKMostRelevantDocuments(ArrayList<Integer> searchWords,  int K) {
        // THIS IS WHERE YOUR CODE GOES
        HashMap<Document, Double> docScores = new HashMap<>();
        for (Document d : documents) {
            double score = 0.0;
            for(int index : searchWords) {
                if(index == -1){
                    continue;
                }
                double tf = calcTF(index, d);
                double idf = calcIDF(index);

                score = score + (tf * idf);
            }
            docScores.put(d, score);
        }
        List<Map.Entry<Document, Double>> sortedDocs = new ArrayList<>(docScores.entrySet());
        sortedDocs.sort((d1, d2) -> d2.getValue().compareTo(d1.getValue()));
        if(sortedDocs.isEmpty()){
            System.out.println("No documents found");
            return;
        }

        System.out.println("For each of the documents:");
        for (int i = 0; i < Math.min(K,sortedDocs.size()); i++) {
            Map.Entry<Document, Double> entry = sortedDocs.get(i);
            System.out.println(entry.getValue() + "   " + entry.getKey().getDocumentFileName());
        }
    }
}
