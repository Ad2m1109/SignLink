import numpy as np
import time

class SignLanguageModel:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SignLanguageModel, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        # Placeholder for actual model loading (Bi-LSTM / TCN)
        # self.model = load_model('path/to/model.h5')
        print("SignLanguageModel initialized (Mock Mode)")

    def predict(self, sequence):
        """
        sequence: list of frames, each frame is a list of 63 normalized keypoints.
        shape: (30, 63)
        """
        # Convert to numpy for processing
        data = np.array(sequence)
        
        # Simulate inference time
        time.sleep(0.05) 

        # Mock logic: detect "Wave" if there's significant Y movement in the middle finger
        # Middle finger tip is landmark 12 (indices 36, 37, 38)
        y_coords = data[:, 37]
        y_diff = np.max(y_coords) - np.min(y_coords)
        
        if y_diff > 0.2:
            return "Wave / Hello"
        else:
            return "Active / Tracking..."

# Singleton instance
sign_language_model = SignLanguageModel()
