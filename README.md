# Live Clothing Auction App (Flutter)

A **Flutter app for selling clothes via live auctions**, built with **Clean Architecture principles** and **real-time Firebase interactions**. This project demonstrates scalable state management, robust architecture, and interactive auction features.

---

## Features Implemented

### Architecture & Refactor
- **Clean separation of layers**:
  - **Domain:** Entities, Use Cases, Repository interfaces  
  - **Data:** Repository implementations, DTOs  
  - **Presentation:** BLoCs, UI widgets, listeners
- BLoCs now interact with **Use Cases**, not directly with repositories, streamlined and testable.

### Auction & Product State Handling
- **ProductBloc:** Manages live product offers, bids, and Firebase listeners.  
- **StreamBloc:** Handles creation, fetching, and removal of live auction streams.
- Use Cases wrap all repository calls (e.g., `AddStreamUseCase`, `GetStreamByIdUseCase`).

### DTOs & Entities
- DTOs are converted to **entities** using `.toEntity()`.
- DTOs **do not extend domain entities**, maintaining separation between layers.

### Firebase Listeners
- Managed in BLoCs and tied to UI lifecycle.
- Update state on child `added/changed/removed` events.
- Listeners start/stop automatically based on Bloc lifecycle.

### Code & Design Improvements
- Business logic to be moved out of BLoCs into Use Cases.
- Project follows **Clean Architecture**:
  **Bloc → Use Case → Repository → Firebase/Data Source**
- **SRP and other SOLID princibles applied**:
  - BLoCs → UI-driven state + listeners  
  - Use Cases → domain/business logic  
  - Repositories → data access only


---

## How It Works (Live Auction Flow)

1. **Auction Stream Creation**
   - Owners create a stream and add products with starting price and details.
2. **Live Bidding**
   - Viewers join the stream and place bids.
   - ProductBloc listens to Firebase for bid updates and refreshes UI in real time.
3. **Bid Updates**
   - Each new bid updates the current bidder and product offer.
   - Owner and viewers see live price changes instantly.
4. **Product Offer Handling**
   - ProductBloc manages all product offers per stream.
   - Offers and bids are converted from DTOs to domain entities.
5. **Stream Closing**
   - Owner ends the auction stream.
   - Final bid and winner information are stored.

---

## Refactoring Plan / Next Steps

### Use Cases
- Wrap all domain operations (streams, bids, product offers).
- Remain **domain-focused**, no UI logic.
- Call only repository methods.

### BLoC Cleanup
- Keep Firebase listeners and state orchestration in BLoC.
- Move any remaining business logic into Use Cases.

### Future Features
- Advanced auction logic (e.g., auto-bids, countdown timers).
- Additional product types or auction categories.
- Make auction winners able to see products won
- Make sellers able to see what products to send to whom
- Payment integration
- Unit and integration tests.
- Error handling and retry strategies in Use Cases.

---

## Summary Takeaways

| Layer | Responsibility |
|-------|----------------|
| **BLoCs** | UI state + Firebase listeners |
| **Use Cases** | Business/domain operations |
| **Repositories** | Data access only |
| **Entities** | Pure domain objects |
| **DTOs** | Data transport objects only |

This ensures a **scalable and maintainable live auction app** without mixing layers or responsibilities.

---

## Tech Stack
- **Flutter** (Dart)  
- **Firebase** (Realtime Database / Firestore)  
- **BLoC** for state management  
- Clean Architecture, SOLID principles

---

## Project Structure
```
├── domain/
│ ├── entities/
│ ├── use_cases/
│ └── repositories/
├── data/
│ ├── models/ (DTOs)
│ └── repositories/ (implementations)
├── presentation/
│ ├── blocs/
│ ├── pages/
│ └── widgets/
```


---

## Key Learnings
- Proper separation of layers prevents **logic leaks**.  
- DTOs decouple Data layer from Domain layer.  
- Firebase listeners safely live in BLoCs when tied to lifecycle.  
- Clean Architecture enables **scalable, testable Flutter apps**.
