//
//  ContentView.swift
//  WordScramble
//
//  Created by Denis Evdokimov on 5/28/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List{
                Section("Score: \(score)") {
                   EmptyView()
                }
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords,id: \ .self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit() {
                addNewWord()
            }
            .onAppear() {
                startGame()
            }
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            .toolbar(content: {
                Button("New game") {
                    startGame()
                }
            })
        }
        

    }
    private func addNewWord() {
        let answr = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard  answr.count > 0 else { return }
        
        guard isOriginal( answr) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answr) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answr) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answr, at: 0)
        }
        
        newWord = ""
        score += answr.count
    }
    
    
    private func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    private func isOriginal(_ word: String) -> Bool {
        !usedWords.contains(word)
    }
    
   private func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    private func isReal(word: String) -> Bool {
        if word.count < 4 || word == rootWord { return false }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
