# ImgView – Analogue Pocket openFPGA core

Displays a 160x144 image from the SD card at 1:1 (10x integer scale on the Pocket's 1600x1440 screen).

## Build
1. Clone https://github.com/open-fpga/core-template and open its Quartus project (Quartus Prime Lite 21.1).
2. Replace `src/fpga/core/core_top.v` with the one from this folder (keep the template's `apf/` folder and `core_bridge_cmd`; the PLL is not used).
3. Compile. Take `output_files/*.rbf`, bit-reverse it with the template's reverse tool (or any "reverse bytes" tool) and save it as `core.rbf_r`
   in `Cores/Custom.ImgView/`.
4. Copy `icon.bin` from the template into the core folder, and (optional) a platform image into `Platforms/_images/imgview.bin`.

## Install on SD card
    Cores/Custom.ImgView/{core.json,data.json,video.json,input.json,interact.json,core.rbf_r,icon.bin}
    Platforms/imgview.json
    Assets/imgview/common/image.bin

## Make an image
    python tools/img2pocket.py photo.png image.bin
Launch the core and pick `image.bin` when prompted.
