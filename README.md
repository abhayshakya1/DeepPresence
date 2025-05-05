# DeepPresence - Attendance Tracking System

This project is a smart attendance tracking system using face recognition and clustering, built with:

- **Backend**: Python, FastAPI, MySQL
- **Frontend**: SwiftUI (iOS app)

---

## 🚀 Backend (FastAPI) Setup

### ✅ Prerequisites

- Python 3.8+
- MySQL Server running with your schema
- Install dependencies:

```bash
pip install -r requirements.txt

Run the Backend Server:

	uvicorn main:app --host 0.0.0.0 --port 8000 --reload

Make sure your device and iOS simulator are connected to the same WiFi network as your machine.

git clone <your-repo-url>
cd DeepPresence

Open the project in Xcode:
	•	Double-click the .xcodeproj or .xcworkspace file
	•	Make sure your bundle identifier and Team are configured in Signing & Capabilities
Change the Backend IP in Swift Code:
	•	Find and replace all http://192.168.x.x:8000 in your Swift code with your local machine’s IP address on WiFi.
Run on Simulator or Device:
	•	Select a device or simulator from Xcode
	•	Hit Run (▶) to launch the app
