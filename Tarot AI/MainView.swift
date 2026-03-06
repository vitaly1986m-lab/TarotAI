import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var floating = false
    @State private var showCamera = false
    @State private var showSourcePicker = false
    @State private var showCameraCapture = false
    @State private var capturedImage: UIImage?
    @State private var showDetail = false
    @State private var showSettings = false

    // Вопрос пользователя
    @State private var showQuestionField = false
    @State private var tarotQuestion: String = ""
    @FocusState private var questionFocused: Bool
    @State private var questionSubmitted = false
    @State private var showEditHint = false
    @State private var hintPulse = false
    @State private var currentCardIndex: Int = 0
    @State private var cardDescription: String = "Описание карты 1"
    @State private var chatImage: UIImage? = nil
    @State private var cardTapped = false
    @State private var hintFloat = false


    

    @State private var tarotCards: [TarotCard] = [TarotCard(name: "The Fool", description: "The Fool represents new beginnings, having faith in the future, being inexperienced, not knowing what to expect, having beginner's luck, improvisation and believing in the universe.", imageName: "the_fool"),TarotCard(name: "The Magician", description: "When the Magician appears in a spread, it points to the talents, capabilities and resources at the querent's disposal to succeed. The message is to tap into one's full potential rather than holding back, especially when there is a need to transform something.", imageName: "the_magician"),TarotCard(name: "The High Priestess", description: "High Priestess is a card of mystery, stillness and passivity. This card suggests that it is time to retreat and reflect upon the situation and trust your inner instincts to guide you through it. Things around you are not what they appear to be right now.", imageName: "the_high_priestess")]


    struct TarotCard: Identifiable {
        let id = UUID()
        let name: String
        let description: String
        let imageName: String // имя картинки в ассетах

    }


    
    func selectCard(index: Int) {
        guard index < tarotCards.count else { return }
        currentCardIndex = index
        cardDescription = tarotCards[index].description
        chatImage = generateChatImage(text: cardDescription)
    }


    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.08, green: 0.02, blue: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .onTapGesture {
                    questionFocused = false

                    let trimmed = tarotQuestion.trimmingCharacters(in: .whitespacesAndNewlines)

                    withAnimation {
                        if trimmed.isEmpty {
                            showQuestionField = false
                            questionSubmitted = false
                        } else {
                            showQuestionField = false
                            questionSubmitted = true
                        }
                    }

                    // скрываем клавиатуру гарантированно
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }

                VStack {
                    // Верх: заголовок и mockups
                    Spacer().frame(height: 40) // 🔹 пространство сверху перед заголовком

                    header
                    Spacer()

                    mockups
                    Spacer()

                    // Нижняя часть: поле вопроса + кнопки
                    VStack(spacing: 12) {
                        // Показываем вопрос сверху над кнопкой загрузки
                        if !tarotQuestion.isEmpty {
                            VStack(spacing: 8) {
                                Text("Ваш вопрос:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(tarotQuestion)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal)
                        }

                        // Поле ввода
                        if showQuestionField {
                            TextField("Введите ваш вопрос…", text: $tarotQuestion)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(14)
                                .focused($questionFocused)
                                .padding(.horizontal)
                                
                                
                                .onSubmit {
                                    let trimmed = tarotQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }

                                    withAnimation {
                                        showQuestionField = false
                                        questionFocused = false
                                        questionSubmitted = true
                                        showEditHint = true
                                    }

                                    // Автоматическое исчезновение через 2 секунды
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showEditHint = false
                                        }
                                    }
                                }


                                
                    
                        }
                        
                     
                        if showEditHint {
                            Text("✏️ Можно дополнить вопрос")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .opacity(hintPulse ? 1 : 0.6) // мерцание
                                .scaleEffect(hintPulse ? 1.02 : 1) // лёгкое «дыхание»
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                        hintPulse.toggle()
                                    }
                                }
                        }

                        

                        // Кнопка "Спросить у Таро"
                        Button {
                            //guard !questionSubmitted else { return }

                            withAnimation {
                                showQuestionField = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                questionFocused = true
                            }
                        } label: {
                            Text("Спросить у Таро")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    questionSubmitted
                                    ? Color.gray.opacity(0.4)
                                    : Color.white
                                )
                                .foregroundColor(.black)
                                .cornerRadius(22)
                        }
                        .padding(.horizontal)


                        // Кнопка "Загрузить скриншот"
                        Button {
                            showSourcePicker = true
                        } label: {
                            Text("Загрузить скриншот")
                                .font(.headline)
                                .foregroundColor(
                                    questionSubmitted ? .white : .black.opacity(0.5)
                                )
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    questionSubmitted
                                    ? Color.purple.opacity(0.9)
                                    : Color.gray.opacity(0.25)
                                )
                                .cornerRadius(22)
                        }
                        .disabled(!questionSubmitted)
                        .padding(.horizontal)

                    }
                    .padding(.bottom, 20)
                }

            }
            
            .onAppear {
                    // Показываем описание первой карты сразу при запуске экрана
                    selectCard(index: 0)

                    // Запускаем слушатель Firestore
                    ReadingHistoryManager.shared.startListening()

                    // Сохраняем плавающую анимацию
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        floating.toggle()
                    }
                }
            .confirmationDialog("Выберите источник", isPresented: $showSourcePicker, titleVisibility: .visible) {
                Button("Камера") {
                    showCameraCapture = true
                }
                Button("Фото из галереи") {
                    showCamera = true
                }
                Button("Отмена", role: .cancel) {}
            }
            .sheet(isPresented: $showCamera) {
                ImagePickerFiles(image: $capturedImage)
                    .onDisappear {
                        if capturedImage != nil {
                            showDetail = true
                        }
                    }
            }
            .sheet(isPresented: $showCameraCapture) {
                CameraPicker(image: $capturedImage)
                    .onDisappear {
                        if capturedImage != nil {
                            showDetail = true
                        }
                    }
            }
            
            
            .navigationDestination(isPresented: $showDetail) {
                if let image = capturedImage {
                    TarotDetailView(image: image, question: tarotQuestion)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                floating.toggle()
            }
        }
        
    }

    func generateChatImage(text: String) -> UIImage {
        let controller = UIHostingController(rootView:
            ZStack {
                Color.black // фон чата
                Text(text)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(width: 200, height: 200)
            .cornerRadius(12)
        )
        
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }

}

// MARK: - Components
extension MainView {
    var header: some View {
        HStack {
            Text("Tarot")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Text("ai")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Spacer()
            
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .padding(.horizontal)
    }
    
    var mockups: some View {
        HStack(spacing: 24) {
            // Левая панель — одна карта
            if !tarotCards.isEmpty {
                AnimatedMockup(
                    imageName: tarotCards[currentCardIndex].imageName,
                    text: "Нажми на карту",
                    angle: -14,
                    textPosition: .top,
                    onCardTap: {
                        // переключаем карту по кругу
                        currentCardIndex = (currentCardIndex + 1) % tarotCards.count
                        selectCard(index: currentCardIndex)
                        cardTapped = true
                    }
                )
                .offset(x: 12, y: -20)
            }

            // Правая панель — описание карты с эффектом чата
    
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.2))
                    .rotationEffect(.degrees(-3))
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 2, y: 2)

                VStack(alignment: .leading, spacing: 8) {
                    // Логотип
                    Text("Tarot ai")
                        .font(.caption2)
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .rotationEffect(.degrees(5)) // наклон логотипа

                    Spacer()

                    // Текст описания карты
                    Text(cardDescription)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .rotationEffect(.degrees(3)) // наклон текста

                    Spacer()

                    // Текст подсказки с двумя стрелками сверху текста
                    VStack(spacing: 2) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up")
                            Image(systemName: "arrow.up")
                               
                        }
                        .foregroundColor(.pink)
                        .font(.caption2)
                        
                        Text("Описание карты появится здесь")
                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .rotationEffect(.degrees(6))
                    //.offset(y: hintFloat ? -4 : 4)
                                            .scaleEffect(hintPulse ? 1.05 : 1)
                                            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: hintFloat)
                                            .onAppear {
                                                hintFloat.toggle()
                                            }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .center)
                                            }
                                            .padding(8)
                                        }
                                        .frame(width: 220, height: 250)
                                        .offset(y: floating ? -8 : 8)
                }
                    
                    
                    
                    
              
            }
            
            }

           
// MARK: - Animated Mockup
struct AnimatedMockup: View {
    let imageName: String
    let text: String
    let angle: Double
    let textPosition: TextPosition
    let onCardTap: (() -> Void)?

    enum TextPosition {
        case top, bottom
    }

    @State private var isTapped = false
    @State private var float = false
    @State private var pulse = false
  

    var body: some View {
        VStack(spacing: 10) {

            if textPosition == .top {
                rotatedText
                arrowsDown
                Spacer().frame(height: 12)
            }

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .rotationEffect(.degrees(angle))
                .scaleEffect(isTapped ? 0.95 : 1)
                .offset(y: float ? -8 : 8)
                .shadow(color: .black.opacity(0.6), radius: 20, y: 12)
                .onTapGesture {
                    onCardTap?()

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
                        isTapped.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        isTapped.toggle()
                    }
                }

            if textPosition == .bottom {
                Spacer().frame(height: 12)
                arrowsUp
                rotatedText
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                float.toggle()
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }

    private var rotatedText: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .rotationEffect(.degrees(angle))
            .scaleEffect(pulse ? 1.06 : 1)
    }

    private var arrowsDown: some View {
        HStack(spacing: 40) {
            Image(systemName: "arrow.down")
                //Image(systemName: "arrow.down")
        }
        .foregroundColor(.pink)
        .font(.caption)
    }

    private var arrowsUp: some View {
        Image(systemName: "arrow.up")
            .foregroundColor(.pink)
            .font(.caption)
    }
}

#Preview {
    MainView()
}
