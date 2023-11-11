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
    
    var reliability: Double? {
        guard
            let lastChat = chatHistories.last,
            case .ai(let message) = lastChat else { return nil}
        return message.reliability
    }
    var reliabilityText: String {
        guard let reliability else { return "Not very reliable" }
        switch reliability {
        case let reliability where reliability >= 0.7:
            return "Reliable"
        case let reliability where reliability >= 0.4:
            return "Pretty reliable"
        default:
            return "Not very reliable"
        }
    }
   
    @State var isSplash: Bool = true
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @FocusState var isEditing: Bool
    @State var inputText: String = "Hi, I was wondering what some of the new innovations in the stainless"
    @State var chatHistories: [Message] = []
    @State private var animateBigCircle = false
    @State private var animateSmallCircle = false
    @State private var animateText = false
    @Namespace private var switchAnimation

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
            if !isSplash && isEditing {
                textInputView
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
                    .matchedGeometryEffect(id: "circleImage", in: switchAnimation)
                if animateText {
                    VStack {
                        Text("Hi, how can I help you?")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .transition(.scale)
                        Spacer().frame(height: 16)
                        Text("Go ahead, I’m listening")
                            .font(.system(size: 16))
                            .foregroundColor(placeholderGray)
                            .transition(.scale)
                    }
                    .opacity(isSplash ? 1.0 : 0.0)
                }
            }
            Spacer()
            if isRecording {
                ScrollView {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 36)
                .frame(maxHeight: 100)
            } else {
                textInputView
            }
            Spacer().frame(height: 48)
        }
        .onAppear {
            withAnimation() {
                animateText = true
            }
        }
    }
    
    var chatHeader: some View {
        ZStack {
            LinearGradient(colors: [backgroundColor, backgroundColor, backgroundColor, gradientColor], startPoint: .top, endPoint: .bottom)
            HStack {
                circleImage
                    .frame(height: 128)
                    .matchedGeometryEffect(id: "circleImage", in: switchAnimation)
                    .animation(.easeOut(duration: 2), value: reliability)
                Spacer()
            }
        }
        .frame(height: 180)
    }

    var circleImage: some View {
        guard let reliability else {
            return Image("main_circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }

        switch reliability {
        case let reliability where reliability >= 0.7:
            return Image("main_circle_green")
                .resizable()
                .aspectRatio(contentMode: .fit)
        case let reliability where reliability >= 0.4:
            return Image("main_circle_yellow")
                .resizable()
                .aspectRatio(contentMode: .fit)
        default:
            return Image("main_circle_red")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
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
                case .error(let message):
                    errorChat(message: message)
                }
            }
            .animation(.easeIn, value: chatHistories)
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
        }
        .padding(.horizontal, 24)
        .transition(.move(edge: .bottom))
    }
    
    func aiChat(message: AIMessage) -> some View {
        HStack {
            VStack {
                HStack(spacing: 8) {
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
                    Text(reliabilityText)
                        .font(.system(size: 12))
                        .foregroundColor(secondalyGray)
                    Spacer()
                }
                HStack {
                    Text(message.answer)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Spacer()
                }
                HStack(spacing: 4) {
                    Text("Source:")
                        .font(.system(size: 12))
                        .foregroundColor(secondalyGray)
                    Text(message.doi)
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
            Spacer()
        }
        .padding(.horizontal, 24)
        .transition(.move(edge: .bottom))
    }
    
    func errorChat(message: String) -> some View {
        HStack {
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(RoundedCorners(color: themeGray, tl: 16, tr: 0, bl: 16, br: 16))
            Spacer()
        }
        .padding(.horizontal, 24)
        .transition(.move(edge: .bottom))
    }

    var textInputView: some View {
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
                    if !inputText.isEmpty {
                        requestAISuggest()
                    }
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
                if !isRecording {
                    speechRecognizer.transcribe()
                } else {
                    speechRecognizer.stopTranscribing()
                    inputText = speechRecognizer.transcript
                }
                isRecording.toggle()
            }) {
                if isRecording {
                    ZStack {
                        Circle() // Big circle
                            .stroke()
                            .frame(width: 140, height: 140)
                            .foregroundColor(.white)
                            .scaleEffect(animateBigCircle ? 1 : 0.3)
                            .opacity(animateBigCircle ? 0: 1)
                            .animation (Animation.easeInOut (duration:2)
                                .repeatForever(autoreverses: false))
                            .onAppear() { self.animateBigCircle.toggle() }
                        Circle () //Gray
                            .foregroundColor(themeBlue.opacity(0.5))
                            .frame(width: 88, height: 88)
                            .scaleEffect(animateSmallCircle ? 0.9 : 1.2)
                            .animation(Animation.easeInOut (duration: 0.4)
                                .repeatForever(autoreverses: false))
                            .onAppear() { self.animateSmallCircle.toggle() }
                        Image("button_stop")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 88, height: 88)
                    }
                } else {
                    Image("button_speech")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 88, height: 88)
                }
            }
            .frame(width: 88, height: 88)
            Spacer()
            Button {
                isEditing = false
                if !inputText.isEmpty {
                    requestAISuggest()
                }
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

extension ContentView {
    func requestAISuggest() {
        withAnimation {
            chatHistories.append(.me(message: inputText))
            isSplash = false
        }

        Task {
            do {
                guard let url = URL(string: "https://east-meets-north.citroner.blog/query?question=\(inputText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
                let urlRequest = URLRequest(url: url)
                let (data, _) = try await URLSession.shared.data(for: urlRequest)
                let aiMessage = try JSONDecoder().decode(AIMessage.self, from: data)
                chatHistories.append(.ai(message: aiMessage))
                inputText = ""
            } catch {
                chatHistories.append(.error(message: "Please try it later"))
            }
        }
    }
}

enum Message: Identifiable, Equatable {
    case me(message: String)
    case ai(message: AIMessage)
    case error(message: String)

    var id: String {
        switch self {
        case .me(let message):
            return message
        case .ai(let message):
            return message.answer
        case .error(let message):
            return message
        }
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

struct AIMessage: Decodable {
    let question: String
    let answer: String
    let source: String
    let reliability: Double
    let doi: String
    let author: String
    let organization: String
    let publication_date: String
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
