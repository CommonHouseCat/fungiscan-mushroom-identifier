import os
import random
import shutil
from glob import glob
from tqdm import tqdm
import cv2

# Config
DATA_DIR = "data"
OUTPUT_DIR = "split_data"
SPLIT_RATIOS = {"train": 0.8, "validate": 0.1, "test": 0.1}
TARGET_SIZE = (224, 224)

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def save_image(image_path, save_path, idx):
    image = cv2.imread(image_path)
    image = cv2.resize(image, TARGET_SIZE)
    cv2.imwrite(os.path.join(save_path, f"{idx}.png"), image)

def main():
    classes = [d for d in os.listdir(DATA_DIR) if os.path.isdir(os.path.join(DATA_DIR, d))]
    print(f"Found {len(classes)} classes.")

    for cls in classes:
        print(f"\nProcessing class: {cls}")
        input_class_dir = os.path.join(DATA_DIR, cls)
        images = glob(os.path.join(input_class_dir, "*.png"))
        num_images = len(images)

        if num_images == 0:
            print(f"⚠️ Skipping {cls}, no images found.")
            continue

        # Shuffle
        random.shuffle(images)

        # Split
        train_count = int(num_images * SPLIT_RATIOS["train"])
        val_count = int(num_images * SPLIT_RATIOS["validate"])
        test_count = num_images - train_count - val_count

        splits = {
            "train": images[:train_count],
            "validate": images[train_count:train_count + val_count],
            "test": images[train_count + val_count:]
        }

        # Save
        for split, split_images in splits.items():
            save_dir = os.path.join(OUTPUT_DIR, split, cls)
            ensure_dir(save_dir)
            for i, img_path in enumerate(tqdm(split_images, desc=f"{cls}-{split}")):
                save_image(img_path, save_dir, i+1)

if __name__ == "__main__":
    main()
