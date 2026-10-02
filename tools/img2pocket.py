#!/usr/bin/env python3
"""Convert any image to the raw 160x144 RGB565 (big-endian) file ImgView loads.
Usage: python img2pocket.py input.png [image.bin]    (requires: pip install pillow)"""
import struct, sys
from PIL import Image, ImageOps

src = sys.argv[1]
dst = sys.argv[2] if len(sys.argv) > 2 else "image.bin"
im = ImageOps.fit(Image.open(src).convert("RGB"), (160, 144), Image.LANCZOS)  # crop-to-fill
out = bytearray()
for r, g, b in im.getdata():
    out += struct.pack(">H", ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3))
assert len(out) == 160 * 144 * 2
open(dst, "wb").write(out)
print(f"wrote {dst} ({len(out)} bytes)")
