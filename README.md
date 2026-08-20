# hotel_management_app

A new Flutter project.
# World Heart Hotel & Resort — Enterprise Management System

A cross-platform hotel operations terminal engineered with **Flutter** and **Riverpod**. The platform streamlines front-desk workflows, eliminates double-booking through algorithmic date-overlap exclusion, automates room turnover states, and provides an integrated, context-aware AI operations assistant equipped with client-side prompt injection defenses (OWASP LLM Top 10 compliance).

### Key Architectural Highlights
* **Reactive State Architecture:** Centralized domain controllers powered by Riverpod `StateNotifier` and `StateProvider` for room inventories, booking states, and guest profiles.
* **50-Unit Live Inventory:** Full categorized directory (Presidential Suites, Executive Penthouses, Lake View Grand Suites, Poolside Villas, and Corporate Halls) with USD pricing.
* **Overlap Exclusion Search:** Non-blocking reservation engine that filters conflicting check-in/check-out date ranges to prevent double-booking.
* **Automated Stay Lifecycle:** Transactional state transitions (`Booked` → `Checked In` → `Checked Out` → `Cleaning/Turnover` → `Available`).
* **Hardened AI Operations Assistant:** In-app assistant for instant room allocation, real-time rate queries, and guest lookups, protected with client-side jailbreak and extraction filters.
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
