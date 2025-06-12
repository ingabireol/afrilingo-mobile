# Afrilingo

Afrilingo is a Flutter application designed for language learning and translation. This README provides an overview of the project, detailed functionalities, setup instructions, and usage guidelines.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Authentication](#authentication)
- [Profile Management](#profile-management)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

### Authentication
- **Sign In**: Users can log in using their email and password.
- **Sign Up**: New users can create an account with email and password.
- **Google Authentication**: Users can sign in using their Google account.
- **Role Management**: User roles are assigned during authentication (e.g., "ROLE_USER").

### Profile Management
- **Profile Setup**: Users can set up their profiles, including personal information.
- **Profile Picture Update**: Users can upload and update their profile pictures.
- **Role Display**: Users can view their assigned roles within the application.

### Quiz Functionality
- **Quiz Creation**: Users can create quizzes with multiple-choice questions.
- **Quiz Taking**: Users can take quizzes with a timer and receive immediate feedback.
- **Score Tracking**: Users can view their scores and performance on quizzes.

### Dashboard
- **User Dashboard**: A personalized dashboard displaying user statistics, recent activities, and quick access to features.
- **Lesson Content**: Users can access lesson materials and resources.

### Chatbot Integration
- **Chatbot Interaction**: Users can interact with a chatbot for language practice and assistance.

### Additional Features
- **Lesson Management**: Users can manage and track their lessons.
- **Completion Tracking**: Users can see their progress and completed tasks.

## Installation

To get started with Afrilingo, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/clevy11/afrilingo.git
   cd afrilingo
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up your backend service (if applicable) and configure the necessary environment variables.

4. Run the application:
   ```bash
   flutter run
   ```

## Usage

- **Sign In / Sign Up**: Users can create an account or log in using their credentials.
- **Profile Management**: Users can update their profile information, including profile pictures and roles.
- **Take Quizzes**: Users can participate in quizzes and track their scores.
- **Access Dashboard**: Users can view their personalized dashboard with statistics and quick links.

## Authentication

The application uses a custom authentication service. Ensure that the backend is set up to handle user roles correctly. The frontend sends the role as "USER," while the backend expects "ROLE_USER."

## Profile Management

Users can update their profile pictures. Ensure that the profile picture URL is sent as a raw string to avoid issues.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeature`).
3. Make your changes and commit them (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries or issues, please contact:

- Your Name - caleb levy Buntu [buntulevycaleb@gmail.com]
- Project Link: [https://github.com/clevy11/afrilingo](https://github.com/clevy11/afrilingo)


