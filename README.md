# Rick and Morty App

An iOS application built with SwiftUI that displays characters from the Rick and Morty API, featuring search, filtering, and infinite scroll pagination.

## 🚀 How to Run

1. **Prerequisites:**
   - Xcode 15.0 or later
   - iOS 17.0+ deployment target
   - Swift 6.0

2. **Setup:**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd RickyMortyApp
   
   # Open the project
   open RickyMortyApp.xcodeproj
   ```

3. **Run:**
   - Select a simulator or connected device
   - Press `Cmd + R` or click the Run button
   - The app will automatically fetch and display characters on launch

4. **Dependencies:**
   - The project uses **Factory** for dependency injection (managed via Swift Package Manager)
   - Dependencies are automatically resolved when opening the project

## 🏗️ Architecture

### Clean Architecture with MVVM Pattern

The project follows **Clean Architecture** principles with a **MVVM (Model-View-ViewModel)** pattern, organized into distinct layers:

```
┌─────────────────────────────────────┐
│         Feature Layer               │  ← Views & ViewModels
├─────────────────────────────────────┤
│         Domain Layer                │  ← Use Cases (Business Logic)
├─────────────────────────────────────┤
│         Data Layer                  │  ← Repositories
├─────────────────────────────────────┤
│         Network Layer               │  ← Data Sources & Services
└─────────────────────────────────────┘
```

**Reasoning:**
- **Separation of Concerns**: Each layer has a single responsibility, making the codebase maintainable and testable
- **Dependency Inversion**: High-level modules (Domain) don't depend on low-level modules (Network/Data)
- **Testability**: Each layer can be tested independently with mocked dependencies
- **Scalability**: Easy to add new features or modify existing ones without affecting other layers
- **Reusability**: Use cases and repositories can be reused across different features

**Layer Responsibilities:**
- **Feature**: SwiftUI views and ViewModels that handle UI state and user interactions
- **Domain**: Business logic through Use Cases (protocols and implementations)
- **Data**: Repository implementations that coordinate data sources
- **Network**: Remote data sources and network services for API communication

## 💉 Dependency Injection

The project uses **Factory** (a lightweight DI framework) for dependency injection, configured through container extensions.

### How It Works

1. **Container Extensions**: Dependencies are registered in separate container extension files:
   - `NetworkContainer.swift` - Network layer dependencies
   - `Container+Extensions.swift` - Domain layer (Use Cases)
   - `RepoContainer+Extensions.swift` - Data layer (Repositories)

2. **Injection Methods**:
   - **Property Injection**: Using `@Injected` property wrapper
     ```swift
     @Injected(\.getCharacterUseCase) var getCharacterUseCase: GetCharacterUseCase
     ```
   - **Constructor Injection**: For testability (ViewModels accept dependencies in initializers)
     ```swift
     init(useCase: GetCharactersUseCase) {
         self.getCharactersUseCase = useCase
     }
     ```

3. **Benefits**:
   - **Testability**: Easy to inject mock dependencies in tests
   - **Flexibility**: Can swap implementations without changing dependent code
   - **Loose Coupling**: Components don't create their own dependencies
   - **Centralized Configuration**: All dependencies registered in one place

### Example Flow

```
ViewModel → UseCase (via @Injected) → Repository (via @Injected) → DataSource (via @Injected) → NetworkService
```

## 🧪 Testing

### What Was Tested

1. **HomeViewModel Tests** (`HomeViewModelTests.swift`):
   - **State Transitions**: idle → loading → success/error
   - **Search Functionality**: 
     - Valid text triggers search with debounce
     - Empty text doesn't trigger search
     - Debounce cancels previous searches
     - Same value doesn't re-trigger search
   - **Filter Functionality**: 
     - Status filtering (Alive, Dead, Unknown, All)
     - Filter removal when selecting "All"
   - **Combined Search & Filter**: Both work together correctly
   - **Pagination Reset**: Search/filter changes reset to page 1

2. **NetworkService Tests** (`NetworkServiceTests.swift`):
   - **Successful Decoding**: CharactersResponse with multiple characters
   - **Snake Case Conversion**: Automatic conversion from snake_case to camelCase
   - **Empty Responses**: Handling empty results arrays
   - **HTTP Status Codes**: Successful responses (200, 201, 204)

### Why These Tests

- **ViewModel Tests**: Ensure business logic, state management, and user interaction flows work correctly. Critical for maintaining app stability as features grow.
- **Network Tests**: Validate data parsing and API communication. Prevents runtime crashes from malformed responses.
- **Test Framework**: Uses Swift Testing (modern Swift 6 testing framework) with tags for organized test suites.

### Test Coverage Areas

- ✅ State management and transitions
- ✅ Search debouncing and validation
- ✅ Filter application and reset
- ✅ Pagination logic
- ✅ Error handling
- ✅ Network response decoding

## 📊 Observability

### Current Implementation

- **@Observable Macro**: ViewModels use Swift 6's `@Observable` macro for reactive state management
- **Error States**: Comprehensive error handling with user-friendly messages
- **Loading States**: Clear loading indicators during data fetching
- **Empty States**: Dedicated UI for "not found" scenarios

### Security Considerations

- **No Sensitive Data**: The app only consumes public API data (no authentication required)
- **HTTPS Only**: All network requests use HTTPS endpoints
- **Input Validation**: Search text is trimmed and validated before API calls
- **Error Handling**: Network errors are caught and displayed without exposing internal details
- **No Local Storage**: No sensitive data is persisted locally

### Future Observability Enhancements

- Add logging framework for debugging and analytics
- Implement crash reporting (e.g., Crashlytics)
- Add analytics tracking for user interactions
- Network request/response logging in debug builds

## 🔮 Future Improvements

### High Priority

1. **Caching Layer**:
   - Implement local caching (Core Data or SwiftData) for offline support
   - Cache character images to reduce network usage
   - Cache search results for better UX

2. **Enhanced Error Handling**:
   - Retry mechanisms with exponential backoff
   - Network reachability detection
   - More granular error messages

3. **UI/UX Enhancements**:
   - Pull-to-refresh functionality
   - Skeleton loading states
   - Image caching and placeholder handling
   - Animations and transitions

4. **Testing Expansion**:
   - Integration tests for complete user flows
   - UI tests for critical paths
   - Repository and DataSource unit tests
   - Performance tests for large datasets

### Medium Priority

5. **Architecture Refinements**:
   - Coordinator pattern for navigation
   - Combine framework for reactive data flows
   - Result builders for complex UI composition

6. **Features**:
   - Character favorites/bookmarks
   - Share functionality
   - Deep linking support
   - Dark/Light mode toggle (currently dark only)

7. **Code Quality**:
   - SwiftLint integration
   - Code documentation with DocC
   - Performance profiling and optimization

### Low Priority

8. **Additional Features**:
   - Character detail enhancements (episode list, location details)
   - Related characters suggestions
   - Search history
   - Advanced filters (species, gender, etc.)

## ⏱️ Development Time Analysis

This project took more than 2-3 hours due to several factors:

### Architecture Setup (1-2 hours)
- Designing and implementing Clean Architecture layers
- Setting up dependency injection with Factory
- Creating protocol-based abstractions for testability
- Organizing code structure by features and layers

### Feature Implementation (2-3 hours)
- **Search with Debounce**: Implementing proper debouncing logic with task cancellation to prevent unnecessary API calls
- **Filter System**: Status filtering with proper state management and API parameter handling
- **Infinite Scroll**: Pagination logic with proper state tracking (currentPage, hasNextPage)
- **Error Handling**: Comprehensive error handling for different network scenarios (404, no connection, timeout, etc.)
- **UI States**: Loading, error, empty, and success states with proper transitions

### Testing (2-3 hours)
- Writing comprehensive unit tests for ViewModel (15+ test cases)
- Creating mock implementations for UseCases
- Testing network layer with mocked URLSession
- Ensuring test coverage for edge cases (debounce cancellation, pagination reset, etc.)

### Polish & Edge Cases (1-2 hours)
- Handling "not found" scenarios with dedicated UI
- Proper task cancellation to prevent memory leaks
- Input validation and trimming
- State synchronization between search, filter, and pagination

**Total Estimated Time: 6-10 hours**

The additional time was invested in creating a **production-ready, maintainable codebase** with proper architecture, comprehensive testing, and attention to edge cases rather than a quick prototype.

## 📝 Notes

- The app uses modern Swift 6 features: `@Observable`, `async/await`, typed throws, and Swift Testing
- All network operations are asynchronous and properly handle concurrency
- The codebase follows iOS best practices and Swift naming conventions
- Error messages are user-friendly and don't expose technical details

## 📄 License

This project is for educational/demonstration purposes.
