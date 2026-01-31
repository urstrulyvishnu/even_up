# Feature Request: Splitwise Clone (Serverless & Flutter)

## Overview
A minimalistic, Apple-style expense splitting application built with Flutter and a serverless AWS backend.

## Core Features

### 1. User Management
- **Authentication**: Sign up/Log in using email/password (AWS Cognito).
- **Profile**: User avatar, display name, and contact info.
- **Friends**: Add friends by email or phone number.

### 2. Group Management
- **Create Groups**: Name, category (Trip, Home, Couple, Other).
- **Group Members**: Invite friends to join groups.
- **Simplify Debts**: Automated debt simplification within groups.

### 3. Expense Management
- **Add Expense**: Description, amount, date, and payer.
- **Splitting Logic**:
  - Split equally.
  - Split by exact amounts.
  - Split by percentages.
  - Split by shares.
- **Multiple Payers**: Support for expenses paid by more than one person.
- **Notes & Receipts**: Attach receipts and add notes to expenses.

### 4. Balances & Settlements
- **Debt Tracking**: Overview of who owes whom and how much.
- **Settle Up**: Record payments to balance debts.
- **Activity Log**: Chronological list of all expenses and payments.

### 5. UI/UX (Apple Minimalistic Style)
- **Design Principles**:
  - High use of whitespace.
  - System typography (SF Pro).
  - Subtle shadows and glassmorphism.
  - Smooth transitions and haptic feedback.
  - Dark mode support.
- **Views**:
  - Dashboard (Activity feed + Overall balance).
  - Friends list.
  - Groups list.
  - Expense details.

## Technical Architecture (High-Level)
- **Frontend**: Flutter (iOS & Android).
- **Backend**: AWS Serverless.
  - **Auth**: AWS Cognito.
  - **API**: Amazon API Gateway (REST).
  - **Logic**: AWS Lambda (Node.js/Python).
  - **Database**: Amazon DynamoDB (NoSQL).
  - **Storage**: Amazon S3 (for receipts).
  - **Notifications**: AWS SNS/FCM.

## Future Enhancements
- Currency conversion.
- Recurring expenses.
- Charts and spending insights.
- Export to PDF/CSV.
