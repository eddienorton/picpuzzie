//
//  ContentView.swift
//  Picpuzzie
//
//  Created by Edward Brayman on 1/18/26.
//

import SwiftUI

enum PuzzleType: Equatable {
    case classicSliding
    case stripSliding
    case circleRotation
    case rotationPuzzle
    case flip
    case snake
    case swap
    case pizza
}

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var imageId = UUID() // Used to force GameView refresh

    // Display levels (1-8 shown to user)
    @State private var classicSlidingLevel: Int = 1 // Display level 1 = 3x3 grid
    @State private var stripSlidingLevel: Int = 1 // Display level 1 = 3 strips
    @State private var circleRotationLevel: Int = 1 // Display level 1 = 3 rings
    @State private var rotationPuzzleLevel: Int = 1 // Display level 1 = 3x3 grid
    @State private var flipLevel: Int = 1 // Display level 1 = 3x3 grid
    @State private var snakeLevel: Int = 1 // Display level 1 = 3x3 grid
    @State private var swapLevel: Int = 1 // Display level 1 = 3x3 grid
    @State private var pizzaLevel: Int = 1 // Display level 1 = 4 slices

    // Track max unlocked levels for each puzzle (display levels 1-8)
    @State private var classicSlidingMaxLevel: Int = 1
    @State private var stripSlidingMaxLevel: Int = 1
    @State private var circleRotationMaxLevel: Int = 1
    @State private var rotationPuzzleMaxLevel: Int = 1
    @State private var flipMaxLevel: Int = 1
    @State private var snakeMaxLevel: Int = 1
    @State private var swapMaxLevel: Int = 1
    @State private var pizzaMaxLevel: Int = 1

    @State private var currentPuzzleType: PuzzleType = .circleRotation // Start with circle rotation
    @State private var showPuzzleMenu = false
    @State private var showCubesPromo = false
    @State private var shareScreenshot: UIImage?  // For victory card generation
    
    // Time tracking
    @State private var puzzleStartTime: Date?
    @State private var lastPuzzleType: PuzzleType?

    var body: some View {
        ZStack {
            // Background color
            Color.black
                .ignoresSafeArea()

            if let image = selectedImage {
                switch currentPuzzleType {
                case .classicSliding:
                    GameView(
                        sourceImage: image,
                        startingLevel: classicSlidingLevel + 2, // Display level 1 = 3x3 grid
                        currentLevel: classicSlidingLevel,
                        maxUnlockedLevel: classicSlidingMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advanceClassicSlidingLevel,
                        onLevelSelected: selectClassicSlidingLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .classicSliding) }
                    )
                    .id(imageId)
                case .stripSliding:
                    StripSlideGameView(
                        sourceImage: image,
                        startingLevel: stripSlidingLevel + 2, // Display level 1 = 3 strips
                        currentLevel: stripSlidingLevel,
                        maxUnlockedLevel: stripSlidingMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advanceStripSlidingLevel,
                        onLevelSelected: selectStripSlidingLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .stripSliding) }
                    )
                    .id(imageId)
                case .circleRotation:
                    CircleRotationGameView(
                        sourceImage: image,
                        startingLevel: circleRotationLevel + 2, // Display level 1 = 3 rings
                        currentLevel: circleRotationLevel,
                        maxUnlockedLevel: circleRotationMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advanceCircleLevel,
                        onLevelSelected: selectCircleLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .circleRotation) }
                    )
                    .id(imageId)
                case .rotationPuzzle:
                    RotationPuzzleGameView(
                        sourceImage: image,
                        startingLevel: rotationPuzzleLevel + 2, // Display level 1 = 3x3 grid
                        currentLevel: rotationPuzzleLevel,
                        maxUnlockedLevel: rotationPuzzleMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advanceRotationPuzzleLevel,
                        onLevelSelected: selectRotationPuzzleLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .rotationPuzzle) }
                    )
                    .id(imageId)
                case .flip:
                    FlipGameView(
                        sourceImage: image,
                        startingLevel: flipLevel + 2, // Display level 1 = 3x3 grid
                        currentLevel: flipLevel,
                        maxUnlockedLevel: flipMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advanceFlipLevel,
                        onLevelSelected: selectFlipLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .flip) }
                    )
                    .id(imageId)
                case .snake:
                    SnakeGameView(
                        sourceImage: image,
                        startingLevel: snakeLevel + 2, // Display level 1 = 3x3 grid
                        currentLevel: snakeLevel,
                        maxUnlockedLevel: snakeMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advanceSnakeLevel,
                        onLevelSelected: selectSnakeLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .snake) }
                    )
                    .id(imageId)
                case .swap:
                    SwapPuzzleGameView(
                        sourceImage: image,
                        startingLevel: swapLevel + 2, // Display level 1 = 3x3 grid
                        currentLevel: swapLevel,
                        maxUnlockedLevel: swapMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advanceSwapLevel,
                        onLevelSelected: selectSwapLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .swap) }
                    )
                    .id(imageId)
                case .pizza:
                    PizzaGameView(
                        sourceImage: image,
                        startingLevel: pizzaLevel, // Display level 1 = 4 slices
                        currentLevel: pizzaLevel,
                        maxUnlockedLevel: pizzaMaxLevel,
                        onNewPhoto: loadRandomPhoto,
                        onPhotoSelected: setSelectedPhoto,
                        onNextLevel: advancePizzaLevel,
                        onLevelSelected: selectPizzaLevel,
                        onNextPuzzle: nextPuzzle,
                        onShare: { shareVictory(for: .pizza) }
                    )
                    .id(imageId)
                }
            } else {
                ProgressView()
                    .scaleEffect(2)
                    .onAppear {
                        loadRandomPhoto()
                    }
            }
            
            // Cube button (Picpuzzie Cubes promo) - top left
            VStack {
                HStack {
                    Button {
                        showCubesPromo.toggle()
                    } label: {
                        Circle()
                            .fill(Color(red: 0.8, green: 0.8, blue: 0.8)) // #cccccc
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .overlay(
                                Image(systemName: "cube.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.black)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    }
                    .padding(.leading, 15)
                    .padding(.top, 22)
                    Spacer()
                }
                Spacer()
            }
            .zIndex(200)
            
            // Menu button - hamburger icon in top right
            VStack {
                HStack {
                    Spacer()
                    Button {
                        // Save time BEFORE opening menu so InfoView gets current data
                        saveTimeForCurrentPuzzle()
                        // Don't restart timer here - menu time shouldn't count
                        showPuzzleMenu.toggle()
                    } label: {
                        Circle()
                            .fill(Color(red: 0.8, green: 0.8, blue: 0.8)) // #cccccc
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .overlay(
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 22)
                }
                Spacer()
            }
            .zIndex(200)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPuzzleMenu, onDismiss: {
            // Restart timer when menu closes
            startTimeTracking()
        }) {
            InfoView(
                puzzleStats: generatePuzzleStats(),
                currentPuzzle: currentPuzzleType,
                onPuzzleSelected: { newPuzzle in
                    currentPuzzleType = newPuzzle
                    loadRandomPhoto()
                },
                onResetAll: resetAllProgress,
                getUpdatedStats: generatePuzzleStats
            )
        }
        .sheet(isPresented: $showCubesPromo) {
            CubesPromoView()
        }
        .onAppear {
            loadPersistedState()
            startTimeTracking()
        }
        .onChange(of: currentPuzzleType) { oldValue, newValue in
            saveTimeForPuzzle(oldValue)
            startTimeTracking()
            saveCurrentState()
        }
        .onChange(of: selectedImage) { _, _ in
            saveCurrentState()
        }
        .onDisappear {
            saveTimeForCurrentPuzzle()
        }
    }

    // MARK: - Persistence

    private func loadPersistedState() {
        // Load puzzle type
        if let typeString = PersistenceManager.shared.loadCurrentPuzzleType(),
           let puzzleType = puzzleTypeFromString(typeString) {
            currentPuzzleType = puzzleType
        }

        // Load image
        if let image = PersistenceManager.shared.loadCurrentImage() {
            selectedImage = image
        } else {
            loadRandomPhoto()
        }

        // Load display levels (default to 1, which maps to grid size 3)
        // Note: Old data may have saved actual grid levels (3+), so we reset to 1 if data seems invalid
        // Max level is now 6 for all puzzles
        let loadedClassic = PersistenceManager.shared.loadLevel(forPuzzle: "classicSliding") ?? 1
        classicSlidingLevel = min((loadedClassic > 6) ? 1 : loadedClassic, 6)
        classicSlidingMaxLevel = classicSlidingLevel

        let loadedStrip = PersistenceManager.shared.loadLevel(forPuzzle: "stripSliding") ?? 1
        stripSlidingLevel = min((loadedStrip > 6) ? 1 : loadedStrip, 6)
        stripSlidingMaxLevel = stripSlidingLevel

        let loadedCircle = PersistenceManager.shared.loadLevel(forPuzzle: "circleRotation") ?? 1
        circleRotationLevel = min((loadedCircle > 6) ? 1 : loadedCircle, 6)
        circleRotationMaxLevel = circleRotationLevel

        let loadedRotation = PersistenceManager.shared.loadLevel(forPuzzle: "rotationPuzzle") ?? 1
        rotationPuzzleLevel = min((loadedRotation > 6) ? 1 : loadedRotation, 6)
        rotationPuzzleMaxLevel = rotationPuzzleLevel

        let loadedFlip = PersistenceManager.shared.loadLevel(forPuzzle: "flip") ?? 1
        flipLevel = min((loadedFlip > 6) ? 1 : loadedFlip, 6)
        flipMaxLevel = flipLevel

        let loadedSnake = PersistenceManager.shared.loadLevel(forPuzzle: "snake") ?? 1
        snakeLevel = min((loadedSnake > 6) ? 1 : loadedSnake, 6)
        snakeMaxLevel = snakeLevel

        let loadedSwap = PersistenceManager.shared.loadLevel(forPuzzle: "swap") ?? 1
        swapLevel = min((loadedSwap > 6) ? 1 : loadedSwap, 6)
        swapMaxLevel = swapLevel
        
        let loadedPizza = PersistenceManager.shared.loadLevel(forPuzzle: "pizza") ?? 1
        pizzaLevel = min((loadedPizza > 6) ? 1 : loadedPizza, 6)
        pizzaMaxLevel = pizzaLevel
    }

    private func saveCurrentState() {
        // Save puzzle type
        PersistenceManager.shared.saveCurrentPuzzleType(stringFromPuzzleType(currentPuzzleType))

        // Save image
        if let image = selectedImage {
            _ = PersistenceManager.shared.saveCurrentImage(image)
        }

        // Save levels
        PersistenceManager.shared.saveLevel(classicSlidingLevel, forPuzzle: "classicSliding")
        PersistenceManager.shared.saveLevel(stripSlidingLevel, forPuzzle: "stripSliding")
        PersistenceManager.shared.saveLevel(circleRotationLevel, forPuzzle: "circleRotation")
        PersistenceManager.shared.saveLevel(rotationPuzzleLevel, forPuzzle: "rotationPuzzle")
        PersistenceManager.shared.saveLevel(flipLevel, forPuzzle: "flip")
        PersistenceManager.shared.saveLevel(snakeLevel, forPuzzle: "snake")
        PersistenceManager.shared.saveLevel(swapLevel, forPuzzle: "swap")
        PersistenceManager.shared.saveLevel(pizzaLevel, forPuzzle: "pizza")
    }

    private func puzzleTypeFromString(_ string: String) -> PuzzleType? {
        switch string {
        case "classicSliding": return .classicSliding
        case "stripSliding": return .stripSliding
        case "circleRotation": return .circleRotation
        case "rotationPuzzle": return .rotationPuzzle
        case "flip": return .flip
        case "snake": return .snake
        case "swap": return .swap
        case "pizza": return .pizza
        default: return nil
        }
    }

    private func stringFromPuzzleType(_ puzzleType: PuzzleType) -> String {
        switch puzzleType {
        case .classicSliding: return "classicSliding"
        case .stripSliding: return "stripSliding"
        case .circleRotation: return "circleRotation"
        case .rotationPuzzle: return "rotationPuzzle"
        case .flip: return "flip"
        case .snake: return "snake"
        case .swap: return "swap"
        case .pizza: return "pizza"
        }
    }

    private func loadRandomPhoto() {
        PhotoLibraryService.requestPermission { granted in
            if granted {
                PhotoLibraryService.fetchRandomPhoto { image in
                    if let image = image {
                        selectedImage = image
                        imageId = UUID() // Generate new ID to force refresh
                    }
                }
            }
        }
    }
    
    private func setSelectedPhoto(_ image: UIImage) {
        selectedImage = image
        imageId = UUID() // Generate new ID to force refresh
        saveCurrentState()
    }
    
    private func nextPuzzle() {
        // Cycle through puzzles in order
        switch currentPuzzleType {
        case .classicSliding:
            currentPuzzleType = .stripSliding
        case .stripSliding:
            currentPuzzleType = .circleRotation
        case .circleRotation:
            currentPuzzleType = .rotationPuzzle
        case .rotationPuzzle:
            currentPuzzleType = .flip
        case .flip:
            currentPuzzleType = .snake
        case .snake:
            currentPuzzleType = .swap
        case .swap:
            currentPuzzleType = .pizza
        case .pizza:
            currentPuzzleType = .classicSliding // Wrap around
        }
        // onChange handler will trigger and load new photo
    }

    private func advanceClassicSlidingLevel() {
        if classicSlidingLevel < 6 {
            classicSlidingLevel += 1
            if classicSlidingLevel > classicSlidingMaxLevel {
                classicSlidingMaxLevel = classicSlidingLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }

    private func selectClassicSlidingLevel(_ level: Int) {
        classicSlidingLevel = level
        saveCurrentState()
        imageId = UUID() // Force refresh
    }

    private func advanceStripSlidingLevel() {
        if stripSlidingLevel < 6 {
            stripSlidingLevel += 1
            if stripSlidingLevel > stripSlidingMaxLevel {
                stripSlidingMaxLevel = stripSlidingLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }

    private func selectStripSlidingLevel(_ level: Int) {
        stripSlidingLevel = level
        saveCurrentState()
        imageId = UUID()
    }

    private func advanceCircleLevel() {
        if circleRotationLevel < 6 {
            circleRotationLevel += 1
            if circleRotationLevel > circleRotationMaxLevel {
                circleRotationMaxLevel = circleRotationLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }

    private func selectCircleLevel(_ level: Int) {
        circleRotationLevel = level
        saveCurrentState()
        imageId = UUID() // Force refresh
    }

    private func advanceRotationPuzzleLevel() {
        if rotationPuzzleLevel < 6 {
            rotationPuzzleLevel += 1
            if rotationPuzzleLevel > rotationPuzzleMaxLevel {
                rotationPuzzleMaxLevel = rotationPuzzleLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }

    private func selectRotationPuzzleLevel(_ level: Int) {
        rotationPuzzleLevel = level
        saveCurrentState()
        imageId = UUID()
    }

    private func advanceFlipLevel() {
        if flipLevel < 6 {
            flipLevel += 1
            if flipLevel > flipMaxLevel {
                flipMaxLevel = flipLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }

    private func selectFlipLevel(_ level: Int) {
        flipLevel = level
        saveCurrentState()
        imageId = UUID()
    }

    private func advanceSnakeLevel() {
        if snakeLevel < 6 {
            snakeLevel += 1
            if snakeLevel > snakeMaxLevel {
                snakeMaxLevel = snakeLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }

    private func selectSnakeLevel(_ level: Int) {
        snakeLevel = level
        saveCurrentState()
        imageId = UUID()
    }

    private func advanceSwapLevel() {
        if swapLevel < 6 {
            swapLevel += 1
            if swapLevel > swapMaxLevel {
                swapMaxLevel = swapLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }

    private func selectSwapLevel(_ level: Int) {
        swapLevel = level
        saveCurrentState()
        imageId = UUID()
    }
    
    private func advancePizzaLevel() {
        if pizzaLevel < 6 {
            pizzaLevel += 1
            if pizzaLevel > pizzaMaxLevel {
                pizzaMaxLevel = pizzaLevel
            }
        }
        saveCurrentState()
        loadRandomPhoto()
    }
    
    private func selectPizzaLevel(_ level: Int) {
        pizzaLevel = level
        saveCurrentState()
        imageId = UUID()
    }
    
    // MARK: - Time Tracking
    
    private func startTimeTracking() {
        puzzleStartTime = Date()
        lastPuzzleType = currentPuzzleType
    }
    
    private func saveTimeForCurrentPuzzle() {
        saveTimeForPuzzle(currentPuzzleType)
    }
    
    private func saveTimeForPuzzle(_ puzzleType: PuzzleType) {
        guard let startTime = puzzleStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let puzzleKey = stringFromPuzzleType(puzzleType)
        
        PersistenceManager.shared.addTime(elapsed, forPuzzle: puzzleKey)
        puzzleStartTime = nil
    }
    
    private func generatePuzzleStats() -> [PuzzleStats] {
        return [
            PuzzleStats(
                puzzleType: .classicSliding,
                name: "Classic Sliding",
                emoji: "🔲",
                currentLevel: classicSlidingLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "classicSliding")
            ),
            PuzzleStats(
                puzzleType: .stripSliding,
                name: "Strip Sliding",
                emoji: "📊",
                currentLevel: stripSlidingLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "stripSliding")
            ),
            PuzzleStats(
                puzzleType: .circleRotation,
                name: "Circle Rotation",
                emoji: "🎯",
                currentLevel: circleRotationLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "circleRotation")
            ),
            PuzzleStats(
                puzzleType: .rotationPuzzle,
                name: "Rotation Puzzle",
                emoji: "🔄",
                currentLevel: rotationPuzzleLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "rotationPuzzle")
            ),
            PuzzleStats(
                puzzleType: .flip,
                name: "Flip",
                emoji: "🃏",
                currentLevel: flipLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "flip")
            ),
            PuzzleStats(
                puzzleType: .snake,
                name: "Snake",
                emoji: "🐍",
                currentLevel: snakeLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "snake")
            ),
            PuzzleStats(
                puzzleType: .swap,
                name: "Swap",
                emoji: "🔀",
                currentLevel: swapLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "swap")
            ),
            PuzzleStats(
                puzzleType: .pizza,
                name: "Pizza",
                emoji: "🍕",
                currentLevel: pizzaLevel,
                timeSpent: PersistenceManager.shared.loadTime(forPuzzle: "pizza")
            )
        ]
    }
    
    private func resetAllProgress() {
        // Reset all levels to 1
        classicSlidingLevel = 1
        classicSlidingMaxLevel = 1
        stripSlidingLevel = 1
        stripSlidingMaxLevel = 1
        circleRotationLevel = 1
        circleRotationMaxLevel = 1
        rotationPuzzleLevel = 1
        rotationPuzzleMaxLevel = 1
        flipLevel = 1
        flipMaxLevel = 1
        snakeLevel = 1
        snakeMaxLevel = 1
        swapLevel = 1
        swapMaxLevel = 1
        pizzaLevel = 1
        pizzaMaxLevel = 1
        
        // Save reset levels
        PersistenceManager.shared.saveLevel(1, forPuzzle: "classicSliding")
        PersistenceManager.shared.saveLevel(1, forPuzzle: "stripSliding")
        PersistenceManager.shared.saveLevel(1, forPuzzle: "circleRotation")
        PersistenceManager.shared.saveLevel(1, forPuzzle: "rotationPuzzle")
        PersistenceManager.shared.saveLevel(1, forPuzzle: "flip")
        PersistenceManager.shared.saveLevel(1, forPuzzle: "snake")
        PersistenceManager.shared.saveLevel(1, forPuzzle: "swap")
        PersistenceManager.shared.saveLevel(1, forPuzzle: "pizza")
        
        // Reset all times to 0
        PersistenceManager.shared.saveTime(0, forPuzzle: "classicSliding")
        PersistenceManager.shared.saveTime(0, forPuzzle: "stripSliding")
        PersistenceManager.shared.saveTime(0, forPuzzle: "circleRotation")
        PersistenceManager.shared.saveTime(0, forPuzzle: "rotationPuzzle")
        PersistenceManager.shared.saveTime(0, forPuzzle: "flip")
        PersistenceManager.shared.saveTime(0, forPuzzle: "snake")
        PersistenceManager.shared.saveTime(0, forPuzzle: "swap")
        PersistenceManager.shared.saveTime(0, forPuzzle: "pizza")
        
        // Reset timer
        startTimeTracking()
        
        // Load new photo to refresh
        loadRandomPhoto()
    }
    
    // MARK: - Share Victory Functions
    
    func getPuzzleTypeName(_ type: PuzzleType) -> String {
        switch type {
        case .classicSliding: return "CLASSIC SLIDING"
        case .stripSliding: return "STRIP SLIDING"
        case .circleRotation: return "CIRCLE ROTATION"
        case .rotationPuzzle: return "ROTATION PUZZLE"
        case .flip: return "FLIP"
        case .snake: return "SNAKE"
        case .swap: return "SWAP"
        case .pizza: return "PIZZA"
        }
    }
    
    func shareVictory(for puzzleType: PuzzleType) {
        generateVictoryCard(for: puzzleType)
        if let image = shareScreenshot {
            presentShareSheet(with: image)
        }
    }
    
    func presentShareSheet(with image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller")
            return
        }
        
        // Find the topmost presented controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],  // Image only - URL is in the image
            applicationActivities: nil
        )
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(x: topController.view.bounds.midX,
                                       y: topController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        topController.present(activityVC, animated: true)
    }
    
    func generateVictoryCard(for puzzleType: PuzzleType) {
        // 1. Capture the full window screenshot
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else {
            print("❌ No window found")
            return
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let fullScreenshot = renderer.image { context in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        
        // 2. Crop the screenshot to remove black status bar area at top
        let cropAmount: CGFloat = 60  // Remove ~60 points from top
        let cropRect = CGRect(
            x: 0,
            y: cropAmount * fullScreenshot.scale,
            width: fullScreenshot.size.width * fullScreenshot.scale,
            height: (fullScreenshot.size.height * fullScreenshot.scale) - (cropAmount * fullScreenshot.scale)
        )
        
        guard let croppedCGImage = fullScreenshot.cgImage?.cropping(to: cropRect) else {
            print("❌ Failed to crop screenshot")
            return
        }
        let puzzleScreenshot = UIImage(cgImage: croppedCGImage, scale: fullScreenshot.scale, orientation: fullScreenshot.imageOrientation)
        
        // 3. Create composite victory card (portrait, minimal decoration, maximum puzzle!)
        let cardSize = CGSize(width: 1080, height: 1440)
        let cardRenderer = UIGraphicsImageRenderer(size: cardSize)
        
        let cardImage = cardRenderer.image { context in
            let ctx = context.cgContext
            
            // Background gradient (dark blue to black)
            let colors = [
                UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor,
                UIColor.black.cgColor
            ]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray,
                                     locations: [0.0, 1.0])!
            ctx.drawLinearGradient(gradient,
                                  start: CGPoint(x: cardSize.width/2, y: 0),
                                  end: CGPoint(x: cardSize.width/2, y: cardSize.height),
                                  options: [])
            
            // Border
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(8)
            ctx.stroke(CGRect(x: 20, y: 20, width: cardSize.width - 40, height: cardSize.height - 40))
            
            // Title text: "I BEAT ALL 6 LEVELS!"
            let titleText = "I BEAT ALL 6 LEVELS!"
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 64),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0),
                .strokeWidth: -4.0
            ]
            let titleSize = titleText.size(withAttributes: titleAttrs)
            titleText.draw(at: CGPoint(x: (cardSize.width - titleSize.width) / 2, y: 40),
                          withAttributes: titleAttrs)
            
            // Draw puzzle screenshot with MAXIMUM SIZE - minimal spacing!
            let topOfPuzzle: CGFloat = 40 + titleSize.height + 20  // Title + small gap
            let bottomSpace: CGFloat = 100  // Space for URL at bottom
            let availableHeight = cardSize.height - topOfPuzzle - bottomSpace
            
            let screenshotSize = puzzleScreenshot.size
            let aspectRatio = screenshotSize.width / screenshotSize.height
            
            // Use all available height
            let puzzleHeight = availableHeight
            let puzzleWidth = puzzleHeight * aspectRatio
            
            let puzzleRect = CGRect(
                x: (cardSize.width - puzzleWidth) / 2,
                y: topOfPuzzle,
                width: puzzleWidth,
                height: puzzleHeight
            )
            puzzleScreenshot.draw(in: puzzleRect)
            
            // Bottom text: website
            let bottomText = "yonyc.app/puzzie-family.html"
            let bottomAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let bottomSize = bottomText.size(withAttributes: bottomAttrs)
            bottomText.draw(at: CGPoint(x: (cardSize.width - bottomSize.width) / 2,
                                       y: cardSize.height - 80),
                           withAttributes: bottomAttrs)
        }
        
        // 4. Convert to JPEG with compression
        if let jpegData = cardImage.jpegData(compressionQuality: 0.85),
           let compressedImage = UIImage(data: jpegData) {
            shareScreenshot = compressedImage
            print("🎨 Victory card generated for \(getPuzzleTypeName(puzzleType))")
            print("🎨 Card size: \(cardImage.size)")
            print("🎨 JPEG size: \(jpegData.count / 1024)KB")
        } else {
            shareScreenshot = cardImage
            print("🎨 Victory card generated (uncompressed)")
        }
    }
}

#Preview {
    ContentView()
}
