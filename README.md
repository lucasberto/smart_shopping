# Smart Shopping

## Overview

Smart Shopping is a dynamic, real-time collaborative shopping list application that I built from scratch as part of my Flutter learning journey. This project showcases my ability to create a full-featured application with complex functionalities like real-time updates and user collaboration. What started as a learning challenge evolved into a practical tool that transforms the way users manage shopping lists by enabling seamless collaboration with friends and family.

## Key Features

- Create unlimited shopping lists
- Real-time collaboration
- Instant list sharing capabilities
- Live updates across all connected users
- Google Sign-In integration
- Intuitive item management (add/remove)
- Multi-purpose functionality (works great for task lists too!)

## Technical Stack

- Flutter for cross-platform development
- Firebase Suite:
  - Authentication for secure user management
  - Firestore for real-time data synchronization
  - Storage for data persistence
  - Analytics for usage insights

## Getting Started

1. Clone the repository
2. Set up Firebase in your project
3. Add your `google-services.json` to `android/app/`
4. Run the app

> **Important**: The `google-services.json` file is required but not included in this repository for security reasons. You'll need to generate your own through the Firebase Console.

## Localization

The app currently supports:

- English (en)
- Brazilian Portuguese (pt-BR)

Since the app uses l10n, adding new languages is straightforward. The localization files can be found in the `lib/l10n` directory.
