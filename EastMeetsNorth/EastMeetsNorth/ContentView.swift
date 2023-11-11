//
//  ContentView.swift
//  EastMeetsNorth
//
//  Created by Sae Nuruki on 2023/11/11.
//

import SwiftUI

struct ContentView: View {
    let backgroundColor: Color = .init(red: 25 / 255, green: 27 / 255, blue: 35 / 255)
    let gradientColor: Color = .init(red: 13 / 255, green: 15 / 255, blue: 25 / 255, opacity: 0)
    let themeBlue: Color = .init(red: 1 / 255, green: 150 / 255, blue: 240 / 255)
    let themeGray: Color = .init(red: 46 / 255, green: 48 / 255, blue: 51 / 255)
    let placeholderGray: Color = .init(red: 214 / 255, green: 199 / 255, blue: 199 / 255)
    let secondalyGray: Color = .init(red: 142 / 255, green: 145 / 255, blue: 154 / 255)
   
    @State var isSplash: Bool = true
    @State var isInputAudio: Bool = false
    @FocusState var isEditing: Bool
    @State var inputText: String = "Hi, I was wondering what some of the new innovations in the stainless"
    @State var chatHistories: [Message] = [
        .me(message: "Hi, I was wondering what some of the new innovations in the stainless steel industry are?"),
        .ai(message: AIMessage(
            question: "Hi, I was wondering what some of the new innovations in the stainless steel industry are?",
            answer: "Great question! The latest research says that the topics of X and Y are really hot at the moment. They are looking into new materials using this technology which can help reduce the cost of production by 10%. ",
            source: "title of paper",
            reliability: 0.86,
            url: "https://arxiv.org/pdf/1706.03762.pdf"))
        ]

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            mainContent
            if !isSplash {
                VStack {
                    chatHeader
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
    }
    
    var mainContent: some View {
        VStack {
            ScrollView {
                if isSplash {
                    initBody
                } else {
                    chatBody
                }
            }
            if !isEditing {
                footer
            }
        }
    }

    var initBody: some View {
        VStack {
            Spacer()
            ZStack {
                Image("main_circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 36)
                VStack {
                    Text("Hi, how can I help you?")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Spacer().frame(height: 16)
                    Text("Go ahead, I’m listening")
                        .font(.system(size: 16))
                        .foregroundColor(placeholderGray)
                }
            }
            Spacer()
            HStack(spacing: 4) {
                TextField("", text: $inputText, axis: .vertical)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .focused($isEditing)
                    .onSubmit { isEditing = false }
                    .padding(.horizontal, 36)
                    .frame(maxHeight: 100)
                if isEditing {
                    Button {
                        isEditing = false
                    } label: {
                        Image("button_send")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 57, height: 57)
                    }
                    .frame(width: 57, height: 57)
                    .padding(.trailing, 24)
                }
            }
            Spacer().frame(height: 48)
        }
    }
    
    var chatHeader: some View {
        ZStack {
            LinearGradient(colors: [backgroundColor, gradientColor], startPoint: .top, endPoint: .bottom)
            HStack {
                Image("main_circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 128)
                Spacer()
            }
        }
        .frame(height: 180)
    }
    
    var chatBody: some View {
        VStack(spacing: 40) {
            Spacer().frame(height: 120)
            ForEach(chatHistories, id: \.id) { chat in
                switch chat {
                case .me(let message):
                    meChat(message: message)
                case .ai(let message):
                    aiChat(message: message)
                }
            }
        }
    }
    
    func meChat(message: String) -> some View {
        HStack {
            Spacer()
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(RoundedCorners(color: themeBlue, tl: 16, tr: 0, bl: 16, br: 16))
                .frame(maxWidth: UIScreen.screenWidth * 0.8)
        }
        .padding(.horizontal, 24)
    }
    
    func aiChat(message: AIMessage) -> some View {
        HStack {
            VStack {
                HStack(spacing: 4) {
                    ZStack {
                        CircularProgressView(progress: message.reliability)
                            .frame(width: 42, height: 42)
                        HStack(spacing: 0) {
                            Text("\(Int(message.reliability * 100))")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                            Text("%")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                        }
                    }
                    Text(" Reliable")
                        .font(.system(size: 12))
                        .foregroundColor(secondalyGray)
                    Spacer()
                }
                Text(message.answer)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Text("Source:")
                        .font(.system(size: 12))
                        .foregroundColor(secondalyGray)
                    Text(message.source)
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .fill(secondalyGray)
                        }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(RoundedCorners(color: themeGray, tl: 0, tr: 16, bl: 16, br: 16))
            .frame(maxWidth: UIScreen.screenWidth * 0.8)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    var footer: some View {
        HStack(alignment: .bottom) {
            Button(action: {
                isEditing = true
            }, label: {
                Image("button_keyboard")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 57, height: 57)
            })
            .frame(width: 57, height: 57)
            Spacer()
            Button(action: {
                print("TODO: write later")
            }, label: {
                Image("button_speech")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 88, height: 88)
            })
            .frame(width: 88, height: 88)
            Spacer()
            Button {
                isEditing = false
            } label: {
                Image("button_send")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 57, height: 57)
            }
            .frame(width: 57, height: 57)
        }
        .frame(height: 108)
        .padding(.horizontal, 36)
        .padding(.bottom, 8)
        .ignoresSafeArea(.keyboard)
    }
}

enum Message: Identifiable {
    case me(message: String)
    case ai(message: AIMessage)

    var id: String {
        switch self {
        case .me(let message):
            return message
        case .ai(let message):
            return message.answer
        }
    }
}

struct AIMessage {
    let question: String
    let answer: String
    let source: String
    let reliability: Double
    let url: String
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
