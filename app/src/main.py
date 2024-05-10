from flask import Flask, request, jsonify
import random
import string

app = Flask(__name__)

def generate_password(length, special_chars, numbers):
    password = []
    password.extend(random.choices(string.ascii_letters, k=length - special_chars - numbers))
    password.extend(random.choices(string.digits, k=numbers))
    password.extend(random.choices(string.punctuation, k=special_chars))
    random.shuffle(password)
    return ''.join(password)

@app.route('/',methods=['GET'])
def start():
    return "Welcome to Password Generator"

@app.route('/generate-passwords', methods=['POST'])
def generate_passwords():
    min_length = int(request.json['min_length'])
    special_chars = int(request.json['special_chars'])
    numbers = int(request.json['numbers'])
    num_passwords = int(request.json['num_passwords'])

    passwords = []
    for _ in range(num_passwords):
        password = generate_password(min_length, special_chars, numbers)
        passwords.append(password)

    return jsonify(passwords)

if __name__ == '__main__':
    app.run(debug=True)