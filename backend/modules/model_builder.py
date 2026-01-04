import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout, Bidirectional
import numpy as np
import os

def build_model(input_shape, num_classes):
    """
    Builds a Bi-directional LSTM model for sign language recognition.
    input_shape: (sequence_length, num_features) -> e.g., (30, 99)
    """
    model = Sequential([
        Bidirectional(LSTM(64, return_sequences=True), input_shape=input_shape),
        Dropout(0.2),
        Bidirectional(LSTM(128, return_sequences=False)),
        Dropout(0.2),
        Dense(64, activation='relu'),
        Dense(num_classes, activation='softmax')
    ])
    
    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    return model

def save_dummy_model():
    """
    Creates and saves a model with dummy weights for pipeline verification.
    """
    sequence_length = 30
    num_features = 99 # 33 landmarks * 3 (x, y, z)
    num_classes = 3 # e.g., ["Hello", "Thank You", "I Love You"]
    
    model = build_model((sequence_length, num_features), num_classes)
    
    # Save the model
    model_path = os.path.join(os.path.dirname(__file__), 'sign_language_model.h5')
    model.save(model_path)
    print(f"Model saved to {model_path}")
    
    # Save labels
    labels_path = os.path.join(os.path.dirname(__file__), 'labels.txt')
    with open(labels_path, 'w') as f:
        f.write("Hello\nThank You\nI Love You")
    print(f"Labels saved to {labels_path}")

if __name__ == '__main__':
    save_dummy_model()
