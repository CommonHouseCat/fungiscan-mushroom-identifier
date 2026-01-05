import os
import csv

OUTPUT_DIR = "split_data"
SETS = ["train", "validate", "test"]

for s in SETS:
    split_dir = os.path.join(OUTPUT_DIR, s)
    csv_path = os.path.join(split_dir, f"{s}.csv")

    rows = []
    for cls in os.listdir(split_dir):
        cls_dir = os.path.join(split_dir, cls)
        if not os.path.isdir(cls_dir):
            continue
        for img in os.listdir(cls_dir):
            if img.endswith(".png"):
                # relative path (class/image.png)
                filepath = os.path.join(cls, img)
                rows.append([filepath, cls])

    with open(csv_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["filepath", "label"])
        writer.writerows(rows)

    print(f"✅ CSV generated: {csv_path} ({len(rows)} samples)")
