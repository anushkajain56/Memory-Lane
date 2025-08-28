# Memory Lane  
A SwiftUI iOS app that lets you capture memories with photos, notes, and locations, then resurfaces them when you revisit those places.  

**Built solo using SwiftUI.**

---

## 📱 Screens & Demo
<p align="center">
<img src="./images_memory_lane/screenshot_1" alt="Screenshot 1" width="24%">
<img src="./images_memory_lane/screenshot_3" alt="Screenshot 3" width="24%">
<img src="./images_memory_lane/screenshot_4" alt="Screenshot 4" width="24%">
<img src="./images_memory_lane/screenshot_2" alt="Screenshot 2" width="24%">
  
 
</p>


**Quick Walkthrough:**  
1. Open the app and take a photo or add a note.  
2. Save it with your current location.  
3. Browse your collection or view memories on the map.  
4. Get a popup/notification when you return to a saved place.  

---

## ✨ Features 
- Create memories with photos, notes, and GPS data.  
- Browse, search, and filter saved memories by content or location.  
- View memories on a map with interactive annotations.  
- Get notified when revisiting places you’ve been before.  
- Memory stats: total count, most visited locations, accuracy of saved points.  
- Background location support for automatic detection.  

---

## 🛠 Skills
- Designed and built complete iOS app **end-to-end with SwiftUI**.  
- Implemented **location services** with `CoreLocation` for foreground and background updates.  
- Integrated **local notifications** using `UserNotifications` framework.  
- Built **reusable SwiftUI components** (previews, popups, lists, maps).  
- Created **map annotations** with `MapKit` to display memory pins.  
- Persisted data using **UserDefaults with JSON encoding/decoding**.  
- Developed **search, sort, and filter logic** for browsing saved data.  
- Used **computed extensions** for clean formatting of dates, coordinates, and accuracy strings.  
- Managed app state with `@StateObject`, `@ObservedObject`, and `@Binding`.  
- Debugged and tested with **custom print logging** for location and storage status.  

---

## ⚙️ Tech Stack
- **Language:** Swift 5.9  
- **Frameworks:** SwiftUI, CoreLocation, MapKit, UserNotifications, UIKit (for ImagePicker)  
- **IDE:** Xcode 15+  
- **Target:** iOS 17.0+  
- **Swift Packages:** None (all native frameworks)  

---

## 🚀 Setup (Run in 2 Minutes)
1. Clone the repo:  
   ```bash
   git clone https://github.com/anushkajain56/Memory-Lane
   ```
2. Open in Xcode:
	```bash
	open MemoryLane.xcodeproj
	```
3. Run on a simulator or device (location permissions required).
4. Optionally add photos/notes and walk around to trigger location detection.

## 🔮 Future Improvements
- CloudKit or CoreData sync for cross-device persistence.  
- Widgets or Live Activities to surface nearby memories.  
- More advanced clustering/heatmaps for memory locations.  
- Optional FaceID/TouchID privacy lock.  

---

## 🙌 Credits & Inspiration
- Built using using the [**CodeDreams tool**](https://codedreams.app/)
- Apple’s official SwiftUI and CoreLocation documentation.  
- SF Symbols for icons.  

---

## 📄 License & Contact
**License:** MIT  

**Author:** Anushka Jain 
- 📧 ajain887@gatech.edu
- 💼 [LinkedIn](https://linkedin.com/in/anushka-jain56/)  
