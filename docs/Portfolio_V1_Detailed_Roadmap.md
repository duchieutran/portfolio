# Portfolio Builder Platform - Development Roadmap (Version 1)

## Vision

Xây dựng một portfolio cá nhân bằng Flutter (Web + Mobile) với kiến trúc
có khả năng mở rộng thành nền tảng Portfolio Builder trong tương lai.

> Nguyên tắc: **Build once, scale later.**

------------------------------------------------------------------------

# Phase 0 - Planning

## Mục tiêu

-   Xác định phạm vi Version 1.
-   Thiết kế kiến trúc để không phải viết lại.

### Deliverables

-   Requirement.md
-   Sitemap
-   UI Flow
-   Component Inventory
-   Data Model

------------------------------------------------------------------------

# Phase 1 - Architecture

## Kiến trúc

Clean Architecture

Feature First

BLoC

GoRouter

Dependency Injection

### Cấu trúc

Page → Template → Section → Component → Widget

------------------------------------------------------------------------

# Phase 2 - Design System

## Theme

-   Color System
-   Typography
-   Spacing
-   Radius
-   Elevation
-   Animation
-   Responsive Breakpoints

------------------------------------------------------------------------

# Phase 3 - Data Layer

## Models

-   Profile
-   Project
-   Experience
-   Skill
-   Contact
-   Social
-   PortfolioConfig

Repository hiện tại đọc từ Local JSON.

------------------------------------------------------------------------

# Phase 4 - Component Library

## Hero Section

-   Avatar
-   Name
-   Title
-   CTA
-   Social Icons

## About Section

## Skills Section

## Experience Section

## Project Section

## Contact Section

## Footer Section

Mỗi Section độc lập, chỉ nhận dữ liệu.

------------------------------------------------------------------------

# Phase 5 - Template Engine

## ModernTemplate

Ghép các Section:

Hero About Skills Experience Projects Contact Footer

Không chứa business logic.

------------------------------------------------------------------------

# Phase 6 - Pages

-   Home
-   Project Detail (optional)
-   404

Routing:

/ #/ (mobile/web) future: /username

------------------------------------------------------------------------

# Phase 7 - State Management

Mỗi feature có:

-   Event
-   State
-   Bloc

Hiện tại dữ liệu local nhưng vẫn đi qua Repository.

UI không truy cập trực tiếp JSON.

------------------------------------------------------------------------

# Phase 8 - Responsive

Desktop

Tablet

Mobile

Kiểm tra mọi Section trên cả 3 kích thước.

------------------------------------------------------------------------

# Phase 9 - Animation

-   Hero entrance
-   Scroll reveal
-   Hover
-   Page transition

------------------------------------------------------------------------

# Phase 10 - SEO (Web)

-   Meta tags
-   Open Graph
-   Sitemap
-   robots.txt
-   Canonical URL

------------------------------------------------------------------------

# Phase 11 - Optimization

-   Image optimization
-   Lazy loading
-   Cache
-   Performance

------------------------------------------------------------------------

# Phase 12 - Release

Deploy Flutter Web.

Build Android.

Build iOS.

------------------------------------------------------------------------

# Future Version 2

Thêm Dashboard.

Repository chuyển Local -\> Firestore.

------------------------------------------------------------------------

# Future Version 3

Authentication

Dynamic Route

/username

------------------------------------------------------------------------

# Future Version 4

Subdomain

username.domain.com

Theme Marketplace

JSON Config

Component Renderer

------------------------------------------------------------------------

# Quy tắc kiến trúc

1.  Widget không đọc dữ liệu.
2.  Component không biết Repository.
3.  Section chỉ render.
4.  Template chỉ ghép Section.
5.  Page chỉ chọn Template.
6.  Repository là nguồn dữ liệu duy nhất.
7.  Có thể thay Local JSON bằng API hoặc Firestore mà không sửa UI.
