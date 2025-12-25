import torch
import torch.nn as nn
from PIL import Image
import io
import numpy as np
import pandas as pd
from transformers import ViTModel
from litserve import LitServer, LitAPI
from fastapi import UploadFile
import albumentations as A
from albumentations.pytorch import ToTensorV2

class ViTOnly(nn.Module):
    def __init__(self, num_classes):
        super().__init__()
        self.vit = ViTModel.from_pretrained(
            "google/vit-base-patch16-224-in21k"
        )

        hidden = self.vit.config.hidden_size
        self.classifier = nn.Sequential(
            nn.Linear(hidden, 512),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(512, num_classes)
        )

    def forward(self, x):
        outputs = self.vit(x).last_hidden_state[:, 0, :]
        return self.classifier(outputs)

class MushroomPredictor(LitAPI):
    def setup(self, device):
        device = "cuda" if torch.cuda.is_available() else "cpu"
        self.device = device

        # Load labels
        df = pd.read_csv("/teamspace/studios/this_studio/train.csv")
        self.labels = sorted(df["label"].unique())
        num_classes = len(self.labels)

        # Build model
        self.model = ViTOnly(num_classes=num_classes)
        ckpt = "/teamspace/studios/this_studio/vit.pth"

        # Load state dict
        state = torch.load(ckpt, map_location=device)
        clean_state = {k.replace("module.", ""): v for k, v in state.items()}
        self.model.load_state_dict(clean_state)

        self.model.to(device).eval()

        # Preprocessing
        self.transform = A.Compose([
            A.Resize(224, 224),
            A.Normalize(),
            ToTensorV2()
        ])

    def predict(self, data) -> dict:
        file = data["data"]
        img_bytes = file.file.read()
        img = np.array(Image.open(io.BytesIO(img_bytes)).convert("RGB"))

        tensor = self.transform(image=img)["image"].unsqueeze(0).to(self.device)

        with torch.no_grad():
            logits = self.model(tensor)
            probs = torch.softmax(logits, dim=1)

            idx = probs.argmax(dim=1).item()
            conf = probs[0, idx].item()

        return {
            "predicted_class": self.labels[idx],
            "confidence": f"{conf * 100:.2f}%",
            "index": idx
        }

if __name__ == "__main__":
    server = LitServer(MushroomPredictor())
    server.run(host="0.0.0.0", port=8000)