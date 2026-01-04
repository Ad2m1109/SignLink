import numpy as np
import os
from tensorflow.keras.models import load_model

class SignLanguageModel:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SignLanguageModel, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        # Load the Bi-LSTM model
        model_path = os.path.join(os.path.dirname(__file__), 'sign_language_model.h5')
        try:
            self.model = load_model(model_path)
            print(f"SignLanguageModel loaded from {model_path}")
        except Exception as e:
            print(f"Error loading model: {e}")
            self.model = None

        # Load labels
        labels_path = os.path.join(os.path.dirname(__file__), 'labels.txt')
        try:
            with open(labels_path, 'r') as f:
                self.labels = [line.strip() for line in f.readlines()]
            print(f"Labels loaded: {self.labels}")
        except Exception as e:
            print(f"Error loading labels: {e}")
            self.labels = ["Unknown"]

    def predict(self, sequence):
        """
        sequence: list of frames, each frame is a list of 99 normalized keypoints.
        shape: (30, 99)
        """
        if self.model is None:
            return "Model Error"

        # Convert to numpy and add batch dimension
        data = np.array(sequence) # (30, 99)
        data = np.expand_dims(data, axis=0) # (1, 30, 99)
        
        # Run inference
        prediction = self.model.predict(data, verbose=0)
        class_idx = np.argmax(prediction[0])
        
        if class_idx < len(self.labels):
            return self.labels[class_idx]
        else:
            return "Unknown"

# Singleton instance
sign_language_model = SignLanguageModel()
