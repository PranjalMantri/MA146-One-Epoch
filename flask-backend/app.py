from flask import Flask, Response, jsonify, request
from flask_socketio import SocketIO, emit
import cv2
import firebase_admin
from firebase_admin import credentials, firestore, messaging
import time
from datetime import datetime
import torchvision.transforms as transforms
from PIL import Image
from ultralytics import YOLO

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

cred = credentials.Certificate("security-survelance-firebase-adminsdk-lraah-a3e7c62012.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

notification_cooldown = 30
last_notification_time = 0

camera_location = "Camera 1"
previous_log = None

# Load your models
gun_model = YOLO("Gun.pt")
crash_model = YOLO("Crash.pt")
falling_model = YOLO("Falling.pt")
violence_model = YOLO("Violence.pt")
fire_model = YOLO("Fire.pt")

# Preprocessing function
def preprocess_image(frame):
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])
    image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    return transform(image).unsqueeze(0)

# Model-specific detection functions
def detect_event(frame, model, event_name, confidence_threshold=0.5):
    results = model(frame)
    detections = []
    for result in results:
        for box in result.boxes:
            if box.conf > confidence_threshold:
                detections.append({
                    "box": box.xyxy,
                    "confidence": box.conf,
                    "event": event_name
                })
    return detections


def generate_frames():
    global last_notification_time
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Could not open camera.")
        return

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

    while True:
        success, frame = cap.read()
        if not success:
            print("Error: Failed to capture frame.")
            break
        
        events_detected = []
        detections = []

        # for model, event_name in [(gun_model, "gun"), (crash_model, "crash"), (falling_model, "falling"), (violence_model, "violence"), (fire_model, "fire")]:
        #     event_detections = detect_event(frame, model, event_name)
        #     if event_detections:
        #         detections.extend(event_detections)
        #         events_detected.append(event_name)

        # for model, event_name in [(gun_model, "gun")]:
        #     event_detections = detect_event(frame, model, event_name)
        #     if event_detections:
        #         detections.extend(event_detections)
        #         events_detected.append(event_name)

        # for model, event_name in [(crash_model, "crash")]:
        #     event_detections = detect_event(frame, model, event_name)
        #     if event_detections:
        #         detections.extend(event_detections)
        #         events_detected.append(event_name)

        # for model, event_name in [(falling_model, "falling")]:
        #     event_detections = detect_event(frame, model, event_name)
        #     if event_detections:
        #         detections.extend(event_detections)
        #         events_detected.append(event_name)
    
        # for model, event_name in [(violence_model, "violence")]:
        #     event_detections = detect_event(frame, model, event_name)
        #     if event_detections:
        #         detections.extend(event_detections)
        #         events_detected.append(event_name)

        for model, event_name in [(fire_model, "fire")]:
            event_detections = detect_event(frame, model, event_name)
            if event_detections:
                detections.extend(event_detections)
                events_detected.append(event_name)
        
        # if detections:
        #     frame = annotate_frame(frame, detections)

        if events_detected:
            current_time = time.time()
            if current_time - last_notification_time > notification_cooldown:
                handle_event(events_detected)
                last_notification_time = current_time

        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

def handle_event(events_detected):
    try:
        users_ref = db.collection('users')
        users = users_ref.stream()
        tokens = [user.to_dict().get('fcmToken') for user in users if user.to_dict().get('fcmToken')]

        for event in events_detected:
            if event == "gun" or event == "fire":
                notification = {
                    'title': f'{event.capitalize()} Detected',
                    'body': f'A {event} has been detected in the video feed.'
                }

                log_detection(event)  # Log the detection

                response = send_fcm_notification(tokens, notification)
                print(f"Notification response for {event}:", response)

    except Exception as e:
        print("Error sending notification:", e)

def send_fcm_notification(tokens, notification):
    try:
        messages = [messaging.Message(
            notification=messaging.Notification(
                title=notification['title'],
                body=notification['body']
            ),
            token=token
        ) for token in tokens]

        response = messaging.send_all(messages)
        print(f'Successfully sent message: {response}')
        return {'success': True, 'response': response}

    except Exception as e:
        print(f'Error sending message: {e}')
        return {'success': False, 'error': str(e)}

def log_detection(event_detected):
    global previous_log
    try:
        new_log = {
            'timestamp': datetime.now().strftime('%H:%M'),
            'event_detected': event_detected,
            'camera_location': camera_location,
            "description": "Event detection update"
        }
        
        if new_log != previous_log:
            db.collection('logs').add(new_log)
            print(f"Logged detection: {new_log}")
            previous_log = new_log
            
            socketio.emit('new_log', new_log)
    except Exception as e:
        print(f"Error logging detection: {e}")

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/user/<user_id>', methods=['GET'])
def get_user(user_id):
    try:
        user_ref = db.collection('users').document(user_id)
        user = user_ref.get()
        if user.exists:
            return jsonify(user.to_dict()), 200
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/users', methods=['GET'])
def get_all_users():
    try:
        users_ref = db.collection('users')
        users = users_ref.stream()
        users_list = [user.to_dict() for user in users]
        return jsonify(users_list), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/last_10_logs', methods=['GET'])
def get_last_10_logs():
    try:
        logs_ref = db.collection('logs').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(10)
        logs = logs_ref.stream()
        logs_list = [log.to_dict() for log in logs]
        return jsonify(logs_list), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/latest_log', methods=['GET'])
def get_latest_log():
    try:
        logs_ref = db.collection('logs').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(1)
        logs = logs_ref.stream()
        latest_log = None
        for log in logs:
            latest_log = log.to_dict()
        if latest_log:
            return jsonify(latest_log), 200
        else:
            return jsonify({"error": "No logs found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

if __name__ == "__main__":
    print("Starting server...")
    socketio.run(app, host='0.0.0.0', port=5000, debug=True, allow_unsafe_werkzeug=True)
