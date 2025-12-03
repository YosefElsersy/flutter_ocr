
```markdown
# Flutter OCR App

A complete Flutter application for extracting, enhancing, translating, and converting text using **Google ML Kit**, **TTS**, **QR Scanning**, and **PDF Exporting**.  
The app provides a smooth end-to-end workflow: capture → process → recognize → translate → read aloud → export.

The project is modular, screen-based, and designed for scalability.

---

## 🚀 Features

### 🔍 OCR & Recognition
- Extract text from images using Google ML Kit  
- Supports multilingual OCR (Arabic, English, Chinese, Japanese, Korean, etc.)  
- Live preview scanning  
- Auto-processing pipeline (crop → enhance → recognize)

### 🖼 Image Enhancement
- Adjust contrast, brightness, sharpen  
- Grayscale filter  
- Enhance images before OCR for better accuracy

### 🌐 Translation
- Translate text between multiple languages  
- Smooth UI for switching source/target languages

### 🔊 Text-to-Speech (TTS)
- Read recognized or translated text aloud  
- Supports multiple voices (depending on platform)

### 🔦 QR Scanner
- Scan QR codes from live camera or static images  
- Detect URLs, text, WiFi, geo-locations, and more  
- Auto-open URLs with validation

### 📄 Export System
- Export recognized text as a clean PDF  
- Export images as PDF  
- Share files or save locally  
- Temporary file management

### 🎨 UI / UX
- Minimal and functional interface  
- Smooth animations (flutter_animate)  
- Full dark mode support  
- Enhanced screen-based workflow

---

## 📦 Technologies Used

- **Flutter / Dart**
- **Google ML Kit (Text Recognition + Barcode Scanning)**
- **ImageEditorPlus**
- **TTS Plugins**
- **Provider (State Management)**
- **url_launcher**
- **camera**
- **flutter_animate**

---

## 📁 Project Structure

```

lib/
├── main.dart
├── screens/
│   ├── home/
│   ├── scanner/
│   ├── qr_scan/
│   ├── recognizer/
│   ├── enhance/
│   ├── tts/
│   └── export/
├── services/
│   ├── ocr_service.dart
│   ├── qr_service.dart
│   ├── translation_service.dart
│   ├── tts_service.dart
│   └── pdf_service.dart
├── providers/
│   ├── theme_provider.dart
│   ├── app_state_provider.dart
│   └── image_provider.dart
└── widgets/
├── buttons/
├── dialogs/
└── custom_components/

````

> *Structure may expand as architecture improves.*

---

## 🔧 Installation & Setup

### 1. Clone the repository
```bash
git clone https://github.com/konynour/flutter_ocr.git
cd flutter_ocr
````

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Android Setup

Edit:
`android/app/build.gradle`

Add ML Kit dependencies:

```gradle
dependencies {
    implementation 'com.google.mlkit:text-recognition-chinese:16.0.0'
    implementation 'com.google.mlkit:text-recognition-devanagari:16.0.0'
    implementation 'com.google.mlkit:text-recognition-japanese:16.0.0'
    implementation 'com.google.mlkit:text-recognition-korean:16.0.0'
}
```

---

## ▶️ Run the App

### Debug:

```bash
flutter run
```

### Release:

```bash
flutter run --release
```

---

## 🛠 Build APK

```bash
flutter build apk --release
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🐞 Known Issues / Bugs (To Be Fixed)

### 🔊 **TTS Screen**

* After translating from English → Arabic,
  pressing **Play** for English *still plays Arabic only*.
* TTS refuses to switch languages after Arabic playback.
  ➡️ *Needs language-state cleanup + TTS engine reset before replay.*

---

### 🧭 **QR Screen**

* `geo:` parameter is **not supported** by the ML Kit barcode library.
* Code is currently commented out.
  ➡️ *Requires custom parser or separate geo-URL handler.*

---

### 🏗 **Architecture**

* Current architecture needs to be cleaner and more modular.
* Many screens contain repetitive code.
  ➡️ *Refactor into reusable components + shared services.*

---

### 🔀 **Routing & Navigation**

* Missing dedicated routing file.
* Navigation logic is scattered across screens.
  ➡️ *Add `app_router.dart` with named routes and transitions.*

---

## 🤝 Contributions

Pull requests are welcome!
If you'd like to suggest improvements or fix bugs, feel free to fork the repository.

---


