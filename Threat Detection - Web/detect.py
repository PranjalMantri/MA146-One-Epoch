from flask import Flask, render_template, request, make_response, send_file
import os
import cv2
import numpy as np
from ultralytics import YOLO

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'mp4'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Load all models
models = {
    'Gun': YOLO('Gun.pt'),
    'Fire': YOLO('Fire.pt'),
    'Falling': YOLO('Falling.pt'),
    'Crash': YOLO('Crash.pt'),
    'Violence': YOLO('Violence.pt'),
    'Flood': YOLO('Flood.pt')
}


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route("/", methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        file = request.files.get("file")
        model_name = request.form.get("model")
        if file and allowed_file(file.filename) and model_name in models:
            filename = os.path.join(UPLOAD_FOLDER, file.filename)
            file.save(filename)
            img = cv2.imread(filename)
            model = models[model_name]
            results = model(img)
            annotated_img = results[0].plot()
            _, img_encoded = cv2.imencode('.jpg', annotated_img)
            response = make_response(img_encoded.tobytes())
            response.headers['Content-Type'] = 'image/jpeg'
            return response

    return render_template("index.html", models=models.keys())


@app.route('/process_frame', methods=['POST'])
def process_frame():
    file = request.files['file']
    model_name = request.form.get("model")
    if model_name not in models:
        return make_response('Model not found', 400)

    nparr = np.fromstring(file.read(), np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    model = models[model_name]
    results = model(frame)
    annotated_frame = results[0].plot()
    _, img_encoded = cv2.imencode('.jpg', annotated_frame)
    response = make_response(img_encoded.tobytes())
    response.headers['Content-Type'] = 'image/jpeg'
    return response


@app.route('/process_video', methods=['POST'])
def process_video():
    file = request.files['file']
    model_name = request.form.get("model")
    if model_name not in models:
        return make_response('Model not found', 400)

    video_path = os.path.join(UPLOAD_FOLDER, 'input_video.mp4')
    file.save(video_path)

    cap = cv2.VideoCapture(video_path)
    frames = []
    model = models[model_name]

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        results = model(frame)
        annotated_frame = results[0].plot()
        frames.append(annotated_frame)

    cap.release()

    # Combine frames into a video
    output_path = os.path.join(UPLOAD_FOLDER, 'output_video.mp4')
    out = cv2.VideoWriter(output_path, cv2.VideoWriter_fourcc(*'mp4v'), 30,
                          (annotated_frame.shape[1], annotated_frame.shape[0]))

    for frame in frames:
        out.write(frame)

    out.release()

    return send_file(output_path, mimetype='video/mp4')


if __name__ == "__main__":
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
    app.run(debug=True)
