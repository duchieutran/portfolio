# Portfolio Builder Platform Plan

## 1. Vision

Xây dựng nền tảng portfolio bằng Flutter (Web + Mobile).

### Mục tiêu MVP

-   Trang chủ là portfolio của admin.
-   Đăng ký/Đăng nhập.
-   Mỗi user có URL `/username`.
-   Dashboard chỉnh sửa portfolio.
-   Publish portfolio.

## 2. Đối tượng

-   Khách xem portfolio.
-   Người tạo portfolio.
-   Quản trị viên.

## 3. Công nghệ

-   Flutter Web + Mobile
-   BLoC
-   Clean Architecture
-   GoRouter
-   Dio
-   Firebase Auth
-   Cloud Firestore
-   Firebase Storage
-   GetIt
-   Freezed

## 4. Module

### Public

-   Landing
-   About
-   Projects
-   Contact
-   Login/Register

### User

-   Dashboard
-   Profile
-   Projects
-   Skills
-   Experience
-   Theme
-   Publish

### Admin

-   User management
-   Reports
-   Analytics

## 5. Database (Firestore)

users - uid - username - displayName - avatar - bio - createdAt

portfolio - uid - title - about - skills\[\] - projects\[\] -
experiences\[\] - socials{} - theme

## 6. Routing

-   /
-   /login
-   /register
-   /dashboard
-   /settings
-   /:username

## 7. Flutter Structure

    lib/
      core/
      shared/
      features/
        auth/
        landing/
        dashboard/
        portfolio/
        profile/

## 8. Milestones

### Phase 1

-   Project setup
-   Architecture
-   Routing
-   Theme

### Phase 2

-   Authentication

### Phase 3

-   Portfolio CRUD

### Phase 4

-   Dynamic Route

### Phase 5

-   Responsive UI

### Phase 6

-   Publish

### Phase 7

-   Mobile

### Phase 8

-   SEO
-   Performance
-   Testing

## 9. Future

-   Custom domain
-   Subdomain
-   Multiple templates
-   Blog
-   AI portfolio generator
-   Analytics
