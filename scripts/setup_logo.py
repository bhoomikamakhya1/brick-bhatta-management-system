import shutil
import os

src = r"C:/Users/Kanaka/.gemini/antigravity/brain/680e7f51-813e-4a4b-af27-46fba985a463/app_logo_brown_1767666026423.png"
dst_dir = "assets"
dst = os.path.join(dst_dir, "logo.png")

if not os.path.exists(src):
    print(f"Error: Source file not found: {src}")
    exit(1)

if not os.path.exists(dst_dir):
    os.makedirs(dst_dir)
    print(f"Created directory: {dst_dir}")

shutil.copy(src, dst)
print(f"Copied logo to {dst}")
