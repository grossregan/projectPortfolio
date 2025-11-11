# Software Engineering Final Project

A mobile application prototype for a job finder targeting Software Engineering and Data Science roles.

## Application Overview

This project is a React Native mobile application, built using Expo, designed to streamline the job search process for tech professionals. It aggregates job listings and provides a suite of tools to help users find, compare, and manage opportunities.

### Key Features

* **Dual-Tab Homescreen:** An intuitive layout sorting positions by type (e.g., Software Engineering vs. Data Science) for focused browsing.
* **Custom Search:** Efficiently filter and find specific positions based on user-defined criteria.
* **Favorites System:** Allows users to save jobs of interest for later review.
* **Side-by-Side Comparison:** A unique feature enabling users to compare two job listings directly by pressing and holding the respective job cards.
* **Interview Resources:** A curated list of resources within the application to help users prepare for interviews.

---

## Getting Started

Follow these instructions to get a local copy of the project up and running on your development machine.

### Prerequisites

* **Node.js** (LTS version recommended)
* **npm** or **yarn** package manager
* **Git** for cloning the repository
* **Expo Go App** (for running on a physical device)
    * [Apple App Store](https://apps.apple.com/us/app/expo-go/id982107779)
    * [Google Play Store](https://play.google.com/store/apps/details?id=host.exp.exponent)
* (Optional) **iOS Simulator** (requires Xcode for macOS)
* (Optional) **Android Emulator** (requires Android Studio)

### Installation & Launch

1.  **Clone the Repository:**
    Open your terminal and clone the project repository.
    ```bash
    git clone https://github.com/grossregan/projectPortfolio/tree/150f8e372189284f271bd90cec922b2198848692/openPositionFInder
    ```

2.  **Navigate to Project Directory:**
    ```bash
    cd ../openPositionFInder
    ```

3.  **Install Dependencies:**
    Using npm:
    ```bash
    npm install
    ```
    Or using yarn:
    ```bash
    yarn install
    ```

4.  **Start the Development Server:**
    This command starts the Metro bundler and provides options to run the app.
    ```bash
    npx expo start
    ```

5.  **Run the Application:**
    After starting the server, you will see a QR code in your terminal and a browser window (Expo Dev Tools) will open.

    * **To run on a physical device (Recommended):**
        1.  Install the **Expo Go** app on your iOS or Android phone.
        2.  Scan the QR code from your terminal or the Expo Dev Tools webpage using your phone's camera or the Expo Go app.

    * **To run on a simulator:**
        1.  In the terminal where the server is running, press `i` to launch the iOS Simulator (macOS only).
        2.  In the terminal, press `a` to launch the Android Emulator (requires Android Studio to be set up).

---

## My Contribution

This was a collaborative team project. In the interest of giving credit where credit is due, my specific contributions included:

* **Homescreen:** Developed the dual-tab UI/UX and logic for sorting and displaying job listings.
* **Favorites Page:** Implemented the screen to display all user-favorited jobs, including the logic for saving and removing items.
* **Interview Resource Page:** Built the static resource page providing helpful links and materials for interview preparation.
* **API Integration:** Handled the respective API integrations for the homescreen (fetching jobs), favorites (persisting data), and resource pages.

The remaining features, such as the custom search and job comparison logic, were built by other team members.
<img width="254" height="512" alt="Screenshot_1746562194" src="https://github.com/user-attachments/assets/5c7c818f-ef2a-4a91-a5c7-a967dd538a6d" />
<img width="254" height="512" alt="Screenshot_1746562198" src="https://github.com/user-attachments/assets/4a96f0b9-e4c0-4ea9-bc9b-b89b0da956a5" />
<img width="254" height="512" alt="Screenshot_1746562229" src="https://github.com/user-attachments/assets/4fe1f8a2-985d-47a8-9306-0bc0ee0de633" />
<img width="254" height="512" alt="Screenshot_1746562213" src="https://github.com/user-attachments/assets/78653727-c3be-404c-a25e-362bf5964470" />
<img width="254" height="512" alt="Screenshot_1746562202" src="https://github.com/user-attachments/assets/c3049082-8065-4a9e-bb39-36f6922f937b" />

