//
//  ContentView.swift
//  Rock_Paper_Scissors
//
//  Created by Miguel Guzman on 11/10/24.
//

import SwiftUI

struct ContentView: View {
    @State var playerScore = 0
    @State var cpuScore = 0
    
    @State var winner : String = ""
    @State var cpuImage : String = ""
    @State var playerImage : String = ""
    
    @State private var playerSelection: String? = nil // Track player's choice: "rock", "paper", or "scissors"
    
    var body: some View {
        Spacer()
        Spacer()
        VStack { // Contains all elements on screen
            Spacer()
            VStack { // Title
                Text("Rock, Paper, Scissors!")
                    .font(.system(size: 35, weight: .bold))
                    .fontWeight(.semibold)
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                
                Spacer()
                Spacer()
                // Winner display text (at center)
                Text(winner)
                    .font(.system(size: 20, weight: .regular))
                    .italic()
                
                Spacer()
                Spacer()
                HStack { // Contains the images, players, and scores
                    Spacer()
                    VStack { // CPU status
                        Image(cpuImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 135, height: 135)
                        Text("Opponent")
                            .font(.system(size: 25, weight: .regular))
                            .padding()
                        Text(String(cpuScore))
                            .font(.system(size: 25, weight: .regular))
                    }
                    
                    Spacer()
                    VStack { // Player status
                        Image(playerImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 135, height: 135)
                        Text("Player")
                            .font(.system(size: 25, weight: .semibold))
                            .padding()
                        Text(String(playerScore))
                            .font(.system(size: 25, weight: .regular))
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                Spacer()
                
                VStack { // Contains everything for the Choose and Confirm options!
                    HStack { // Modifications for "Choose"
                        Spacer()
                        Text("Choose")
                            .font(.system(size: 30, weight: .bold))
                            .padding(.leading)
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    HStack { // Contains Rock, Paper, and Scissors buttons
                        // Rock Button
                        Button(action: {
                            playerSelection = "rock"
                        }) {
                            Image(playerSelection == "rock" ? "rock_selected" : "rock")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        }
                        // Paper Button
                        Button(action: {
                            playerSelection = "paper"
                            
                        }) {
                            Image(playerSelection == "paper" ? "paper_selected" : "paper")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        }
                        // Scissors Button
                        Button(action: {
                            playerSelection = "scissors"
                            
                        }) {
                            Image(playerSelection == "scissors" ? "scissors_selected" : "scissors")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        }
                    }
                    
                    // CONFIRM Button
                    Button(action: {
                        // Perform an action after pressing "Confirm"
                        playSimulator()
                    }) {
                        ZStack {
                            Rectangle()
                                .fill(Color("button")) // uses assets
                                .frame(width: 220, height: 50)
                                .border(Color.black, width: 2)
                                .shadow(radius: 6)
                                .cornerRadius(15)
                            Text("Confirm")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(Color.white) // uses assets
                        }
                    }
                    .disabled(playerSelection == nil)
                }
                Spacer()
                
                
            }
            Spacer()
        }
    }
    
    func playSimulator() {
        // The player chooses via UI
        let playerChoice = playerSelection
        
        // Choose a random number from 1-3: (1) Rock, (2) Paper, (3) Scissors
        let random = Int.random(in: 1...3)
        var cpuSelection : String = ""
        
        // update image icons for Player
        if playerChoice == "rock" {
            playerImage = "rock"
        }
        else if playerChoice == "paper" {
            playerImage = "paper"
        }
        else {
            playerImage = "scissors"
        }
        
        // Choose appropriate image and choice for CPU, based on "random"
        if random == 1 {
            cpuImage = "rock"
            cpuSelection = "rock"
        }
        else if random == 2 {
            cpuImage = "paper"
            cpuSelection = "paper"
        }
        else if random == 3 {
            cpuImage = "scissors"
            cpuSelection = "scissors"
        }
        
        // Determine the winner
        if cpuSelection == playerSelection  {
            winner = "Tie!"
        }
        else if cpuSelection == "rock" && playerChoice == "paper" || cpuSelection == "paper" && playerChoice == "scissors" || playerChoice == "rock" && cpuSelection == "scissors" {
            winner = "Player Wins"
        }
        else if cpuSelection == "rock" && playerChoice == "scissors" || cpuSelection == "paper" && playerChoice == "rock" || cpuSelection == "scissors" && playerChoice == "paper" {
            winner = "Opponent Wins"
        }
        // Give a point to winner and take a point away from loser, as long as each player has points ≥ 0
        if winner == "Player Wins" {
            playerScore += 1
            if cpuScore > 0 {
                cpuScore -= 1
            }
        }
        else if winner == "Opponent Wins"{
            cpuScore += 1
            if playerScore > 0 {
                playerScore -= 1
            }
        }
    }
    
}

#Preview {
    ContentView()
}
