# Mental Health Chat Application

This Flutter application provides a chat interface designed to support mental health discussions. The app features a clean and user-friendly interface, allowing users to communicate effectively.

## Project Structure

The project is organized into several directories and files:

- **lib/**: Contains the main application code.
  - **main.dart**: Entry point of the application.
  - **screens/**: Contains the different screens of the app.
    - **chat_screen.dart**: Displays the chat interface.
    - **landing_screen.dart**: Initial screen with welcome messages.
  - **widgets/**: Contains reusable UI components.
    - **chat_bubble.dart**: Represents individual chat messages.
    - **chat_input.dart**: Input field for typing messages.
    - **message_list.dart**: Displays a list of messages.
  - **services/**: Contains service classes for API interactions.
    - **api_service.dart**: Handles API queries and responses.
    - **chat_service.dart**: Manages chat functionalities.
  - **models/**: Contains data models.
    - **message.dart**: Represents a chat message.
    - **chat_response.dart**: Represents API response structure.
  - **theme/**: Contains theme configuration.
    - **app_theme.dart**: Defines color schemes and styles.
  - **utils/**: Contains utility constants.
    - **constants.dart**: Defines static values used throughout the app.

- **assets/**: Contains image assets used in the application.

- **test/**: Contains widget tests to ensure UI functionality.

- **android/**: Android-specific configuration and code.

- **ios/**: iOS-specific configuration and code.

- **web/**: Web-specific configuration and code.

- **pubspec.yaml**: Configuration file for dependencies and assets.

## Setup Instructions

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd mental_health_chat
   ```

2. **Install dependencies**:
   ```
   flutter pub get
   ```

3. **Run the application**:
   ```
   flutter run
   ```

## Usage

- Launch the app to see the landing screen.
- Navigate to the chat screen to start a conversation.
- Use the input field to send messages and view responses.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.