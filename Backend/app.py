from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
import base64
from flask_bcrypt import Bcrypt
bcrypt = Bcrypt()
from dotenv import load_dotenv
from transformers import BlipProcessor, BlipForConditionalGeneration
from PIL import Image
import torch
import io
import os

load_dotenv()
app = Flask(__name__)
CORS(app)
app.config["MONGO_URI"] = os.getenv('MONGO_URI')
mongo = PyMongo(app)

# Load model once at startup
print("Loading BLIP model...")
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-large")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-large")
model.eval()
print("Model loaded!")

def query_model(image_data):
    image = Image.open(io.BytesIO(image_data)).convert("RGB")
    inputs = processor(image, return_tensors="pt")
    with torch.no_grad():
        out = model.generate(**inputs)
    caption = processor.decode(out[0], skip_special_tokens=True)
    return [{"generated_text": caption}]

@app.route('/')
def home():
    return "Welcome to the Flask MongoDB app!"

@app.route('/caption', methods=['POST'])
def get_image_caption():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided. Make sure to include an image file in the request.'}), 400

        image_file = request.files['image']
        image_file.seek(0)
        image_content = image_file.read()

        if not image_content:
            return jsonify({'error': 'The provided image file is empty.'}), 400

        print("Image content length:", len(image_content))

        image_base64 = base64.b64encode(image_content).decode('utf-8')
        print("Base64 encoded image:", image_base64[:100])

        result = query_model(image_content)
        caption = result[0]["generated_text"]
        print("Generated caption:", caption)

        try:
            mongo.db.Assets.insert_one({"image_file": image_base64, "caption": caption})
            print("Inserted into database")
        except Exception as e:
            print(f"Error while uploading the conversation to the database: {e}")

        return jsonify(result[0]["generated_text"])

    except Exception as e:
        return jsonify({'error': str(e)}), 500

collection = mongo.db["Assets"]

@app.route('/conversations', methods=['GET'])
def send_conversations():
    print("Received fetch request")
    try:
        data = list(collection.find({}, {'_id': 0}).sort('_id', -1).limit(5))
        print(f"Fetched {len(data)} conversations")  # debug
        response = jsonify(data)
        response.headers['Content-Type'] = 'application/json'
        return response
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)