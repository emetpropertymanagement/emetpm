# Product Requirements Document (PRD)

## Project: EMET APP

### Overview
EMET APP is a Flutter-based application designed to streamline and digitize payment receipts and record management for users. The app integrates with Firebase for authentication (including Google Sign-In), data storage, and cloud features. It supports both mobile and web platforms.

### Key Features
- **User Authentication**: 
  - Google Sign-In for secure and easy login.
  - Firebase Authentication for user management.
- **Receipt Generation**:
  - Users can generate digital receipts for payments.
  - Each receipt includes transaction details (payer, amount, date, etc.).
  - Receipts are visually designed to use a background image (`assets/receipt.png`) for a professional and branded look, matching the current design style.
- **Cloud Database Integration**:
  - All data is stored and managed using Firebase Cloud Firestore. No local database is used.
- **File Uploads**:
  - Users can upload files (e.g., payment proofs) to Firebase Storage.
- **PDF Export & Sharing**:
  - Receipts can be exported as PDFs and shared via supported platforms.
- **Asset Management**:
  - All images and design assets (e.g., `bigezo.png`, `icon.png`) are managed in the `assets/` directory.

### Receipt Design Details
- The receipt uses a custom background image (`assets/receipt.png`) as the design template.
- All receipt data (text, numbers, etc.) is overlaid on this background, ensuring a consistent and visually appealing output.
- The layout, fonts, and positioning of elements should closely match the current design as implemented in the app.
- The receipt supports both on-screen display and PDF export, maintaining the same design fidelity.

### Technical Stack
- **Flutter** (Dart 3.x)
- **Firebase** (Auth, Firestore, Storage)
- **Google Sign-In**
- **PDF Generation** (syncfusion_flutter_pdf)
- **Asset Management** (Flutter asset system)

### Non-Functional Requirements
- Responsive UI for both mobile and web.
- Secure authentication and data handling.
- Fast and reliable PDF generation.
- Consistent receipt design across all platforms.

### Acceptance Criteria
- Users can log in with Google and generate receipts.
- Receipts use the `receipt.png` background and match the current design.
- Receipts can be exported/shared as PDFs.
- All assets load correctly and display as intended.
- All data is stored and managed in Firebase Cloud Firestore only (no local database).

---

*This PRD is based on the current app structure and design, with special attention to the receipt's visual fidelity using the `receipt.png` background image as seen in the existing implementation.*
