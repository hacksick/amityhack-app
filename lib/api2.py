from flask import Flask, request, jsonify
import os
from flask_cors import CORS
import zlib,socket,pyqrcode

app = Flask(__name__)

# Define the path to the folder where you want to save the received files
UPLOAD_FOLDER = 'received_files'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)  # ensure the folder exists


@app.route('/compress', methods=['POST'])
def compress_data():
    file = request.files.get('file')
    if not file:
        return jsonify({"error": "File not provided"}), 400

    # Save the uploaded file
    filename = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filename)
    ext=list(filename.split("."))[-1]

    photo_extensions = [
        '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.ico', '.jfif', '.webp', '.heif', '.indd', '.ai', '.raw', '.svg', '.eps'
    ]
    video_extensions = [
        '.mp4', '.mkv', '.flv', '.wmv', '.avi', '.mov', '.m4v', '.mpg', '.mpeg', '.3gp', '.f4v', '.swf', '.h264', '.vob', '.rm'
    ]
    audio_extensions = [
        '.mp3', '.wav', '.ogg', '.m4a', '.flac', '.aac', '.wma', '.aiff', '.alac', '.amr', '.dss', '.dvf', '.m4r', '.mmf', '.mpc', '.msv', '.opus', '.ra', '.rm', '.tta', '.vox', '.webm'
    ]
    other_extensions = [
        '.txt', '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.odt', '.ods', '.odp', '.zip', '.rar', '.7z', '.tar', '.gz', '.csv', '.xml', '.html', '.htm', '.json', '.log', '.sql'
    ]




    print("------------==========")


    with open(filename, 'rb') as f:
        data = f.read()

    compressed_data = zlib.compress(data)
    compressed_filename = os.path.join(UPLOAD_FOLDER, file.filename + ".zlib")
    with open(compressed_filename, 'wb') as f:
        f.write(compressed_data)

    return jsonify({"compressed_size": len(compressed_data), "compressed_filename": compressed_filename})

@app.route('/decompress', methods=['POST'])
def decompress_data():
    file = request.files.get('file')
    if not file:
        return jsonify({"error": "File not provided"}), 400

    # Save the uploaded file
    filename = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filename)

    with open(filename, 'rb') as f:
        compressed_data = f.read()

    decompressed_data = zlib.decompress(compressed_data)
    decompressed_filename = filename.rsplit('.zlib', 1)[0]
    with open(decompressed_filename, 'wb') as f:
        f.write(decompressed_data)

    return jsonify({"decompressed_size": len(decompressed_data), "decompressed_filename": decompressed_filename})


hostname = socket. gethostname()
oi = socket. gethostbyname(hostname)
oi = str(oi)

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
pic = s.getsockname()[0]
s.close()

local_ip = pic
s = "http://%s:5000/" % local_ip
url = pyqrcode.create(s)
url.png("qrcode.png", scale=6)
if __name__ == '__main__':
   CORS(app.run(host=local_ip, port=5000, debug=True))
