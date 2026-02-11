# Project Name

This is a Flutter project organized into various sections following clean architecture principles. Below is the breakdown of the directory structure and the files within it.

## Directory Structure

lib/
├── core/
│ ├── error/
│ ├── usecases/
│ └── utils/
│ ├── app_colors.dart
│ ├── app_icons.dart
│ ├── custom_bottom_navigation.dart
│ └── CustomStepper.dart
├── features/
│ ├── authentication/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ └── auth_remote_data_source.dart
│ │ ├── models/
│ │ │ └── user_model.dart
│ │ ├── repositories/
│ │ │ └── auth_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── user.dart
│ │ │ └── repositories/
│ │ │ └── auth_repository.dart
│ │ ├── usecases/
│ │ │ ├── login.dart
│ │ │ └── register.dart
│ │ └── presentation/
│ │ ├── blocs/
│ │ │ └── auth_bloc.dart
│ │ ├── screens/
│ │ │ ├── basic_info_screen.dart
│ │ │ ├── business_info_screen.dart
│ │ │ ├── document_upload_screen.dart
│ │ │ └── login_screen.dart
│ │ └── widgets/
│ │ ├── custom_text_field.dart
│ │ └── login_form.dart
│ ├── booking/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ └── document_remote_data_source.dart
│ │ ├── models/
│ │ │ └── document_model.dart
│ │ ├── repositories/
│ │ │ └── document_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── document.dart
│ │ │ └── repositories/
│ │ │ └── document_repository.dart
│ │ └── presentation/
│ │ ├── blocs/
│ │ │ └── document_bloc.dart
│ │ ├── screens/
│ │ │ ├── active_booking_screen.dart
│ │ │ └── booking_screen.dart
│ │ └── widgets/
│ │ └── document_upload_form.dart
│ ├── chat/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ ├── model/
│ │ │ └── repositories/
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ └── repositories/
│ │ └── presentation/
│ │ ├── bloc/
│ │ │ └── inbox_bloc.dart
│ │ ├── screens/
│ │ │ ├── chat_screen.dart
│ │ │ └── inbox_screen.dart
│ │ └── widgets/
│ │ └── chat_card.dart
│ ├── home/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ └── home_remote_data_source.dart
│ │ ├── models/
│ │ │ └── home_model.dart
│ │ ├── repositories/
│ │ │ └── home_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── home.dart
│ │ │ └── repositories/
│ │ │ └── home_repository.dart
│ │ └── presentation/
│ │ ├── blocs/
│ │ │ └── home_bloc.dart
│ │ ├── screens/
│ │ │ ├── home_screen.dart
│ │ │ └── new_leads_screen.dart
│ │ └── widgets/
│ │ └── home_card.dart
│ ├── profile/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ └── profile_remote_data_source.dart
│ │ ├── models/
│ │ │ └── profile_model.dart
│ │ ├── repositories/
│ │ │ └── profile_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── profile.dart
│ │ │ └── repositories/
│ │ │ └── profile_repository.dart
│ │ ├── usecases/
│ │ │ ├── get_profile.dart
│ │ │ └── update_profile.dart
│ │ └── presentation/
│ │ ├── blocs/
│ │ │ └── profile_bloc.dart
│ │ ├── screens/
│ │ │ ├── help_support_screen.dart
│ │ │ ├── manage_notification_screen.dart
│ │ │ └── profile_screen.dart
│ │ └── widgets/
│ │ └── profile_form.dart
│ ├── services/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ └── services_remote_data_source.dart
│ │ ├── models/
│ │ │ └── service_model.dart
│ │ ├── repositories/
│ │ │ └── services_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── service.dart
│ │ │ └── repositories/
│ │ │ └── services_repository.dart
│ │ ├── usecases/
│ │ │ ├── add_service.dart
│ │ │ └── get_services.dart
│ │ └── presentation/
│ │ ├── blocs/
│ │ │ └── services_bloc.dart
│ │ ├── screens/
│ │ │ └── services_screen.dart
│ │ └── widgets/
│ │ └── service_card.dart



## **Directory Overview**:

### **core**
Contains shared utilities, such as:
- **app_colors.dart**: Defines the app's color scheme.
- **app_icons.dart**: Stores the icon assets used throughout the app.
- **custom_bottom_navigation.dart**: Custom bottom navigation bar implementation.
- **CustomStepper.dart**: Custom stepper widget for use in forms or processes.

### **features**
Contains all the features of the app, such as **authentication**, **booking**, **chat**, **profile**, and **services**, organized as:

1. **Authentication**: Handles user authentication processes like login, register, and user data.
2. **Booking**: Manages booking-related information, including active bookings and document uploads.
3. **Chat**: Implements chat features, including inbox and messaging.
4. **Home**: Contains the home screen, dashboard information, and widgets.
5. **Profile**: Manages user profile data, including viewing and updating profile details.
6. **Services**: Handles services-related data, including service management and display.

### **presentation**
Contains UI-related files, like **screens** and **widgets** for each feature. These files interact with the app’s business logic.

### **data**
Contains the **datasources** and **repositories** for fetching and managing data.

### **domain**
Contains business logic, including **entities** and **usecases** that represent app data and operations.

---

This structure follows clean architecture principles and ensures separation of concerns between different layers of the application.

### **Installation**

1. Clone this repository:
   ```bash
   git clone <repository_url>
