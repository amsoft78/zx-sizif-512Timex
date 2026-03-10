
## Modified palette

In all experimental multicolor modes, the regular IGRB ZX Spectrum palette has been slightly modified.
The "I" attribute has been changed to be "Red++/Green+" boost. It introduces new colors, but it is not compatible with ZX Spectrum original palette.
The colors are:
| Color number (binary) | Samples 0 - 7 | Samples for 8-15 |  Color number (binary) |
|:-----------------------:|:---------------:|:------------------:|------------------------:|
|      0       (0b0000) |  $\textsf{\color{#000000}{000000}}$     |  $\textsf{\color{#806000}{806000}}$        |       8      (0b1000) |
|      1       (0b0001) |  $\textsf{\color{#000080}{000080}}$     | $\textsf{\color{#8060FF}{8060FF}}$        |       9      (0b1001) |
|      2       (0b0010) |  $\textsf{\color{#800000}{800000}}$     | $\textsf{\color{#FF6000}{FF6000}}$        |      10      (0b1010) |
|      3       (0b0011) |  $\textsf{\color{#800080}{800080}}$     | $\textsf{\color{#FF60FF}{FF60FF}}$        |      11      (0b1011) |
|      4       (0b0100) |  $\textsf{\color{#008000}{008000}}$     | $\textsf{\color{#80FF00}{80FF00}}$       |      12      (0b1100) |
|      5       (0b0101) |  $\textsf{\color{#008080}{008080}}$     | $\textsf{\color{#80FFFF}{80FFFF}}$        |      13      (0b1101) |
|      6       (0b0110) |  $\textsf{\color{#808000}{808000}}$     | $\textsf{\color{#FFFF00}{FFFF00}}$        |      14      (0b1110) |
|      7       (0b0111) |  $\textsf{\color{#808080}{808080}}$     | $\textsf{\color{#FFFFFF}{FFFFFF}}$       |      15      (0b1111) |

## 256x192 and 128x192 4 colors modes details.
Opposite to PC CGA card, 256x192 the 4 colors are not limited to fixed palette.
The bit combination in this mode (and in Dual Playfield mode), with ULAPlus register not enabled, means the following:
- 00 - border color - one of 8, common for the entire screen,
- 01 - paper color - from 256 UlaPlus palette, shared for the 8x8/4x8 pixel field
- 10 - additional color, from equal to bits 5:3 in #FF register. This color is from the higher 8 of palette. The exception is DualPlayField 1st playfield, when this value means transparency.
- 11 - ink color - from 256 UlaPlus palette, shared for the 8x8/4x8 pixel field
The attributes are read from attributes memory areas in both video pages (0x5800 and 0x7800), but the interpretation is different than in original ZX Spectrum modes.
For first 8x8 bits field, the whole byte (256 colors palette) at address 0x5800 contains value for ink, the value from 0x780 - for paper.
In dual playfield mode, the field is only 4x8, but colors for first and second playfield overlaps.
The organization of attributes example for first column and ink color:

| P.field 1, bits 0..3 | P.field 2, bits 0..3 | P.field 1, bits 4..7 | P.field 2, bits 4..7 |
| -------------------- | -------------------- | -------------------- | -------------------- |
| 0x5800 ink (1)       | P0x5801 ink (2)      | 0x5802 ink (1)       | 0x5803 ink (2)       |
| 0x7800 paper (1)     | P0x7801 paper (2)    | 0x7802 paper (1)     | 0x7803 paper (2)     |

### 256x192 and 128x192 4 colors modes - ULAPlus options.
When ULAPlus is enabled, most of its registers are used to enhance available colors in 4 colors mode.
In 256x192x4 mode, each "text line" on the screen has assigned replacement for color 00 (background), from full palette of 256 colors. For the technical reasons, the color is read in the last line of each text line, and updates the color for the next line.
The 00 colors replacements are stored in the ULAPlus registers 0..7, 16..23 and 32..38.
In 256x192x4 mode and in dual playfield 128x192x4, each "text line" on the screen has assigned additionally a replacement for color 10 ("Timex register" color). The main rule is the same as previous, but ULAPlus register for the same line has a number with +8 added.

## 128x192 16 colors mode details.
The 128x192 16 colors mode uses groups Timex HiColor bits data into groups of 4 bits, to choose one of 16 independent color for a single picture.
12 of 16 colors are always direct from the pallette.
Additionally, basic version of the 16 color mode, (when mode is set with OUT 255, 8), allows substitute 4 of the colors with colors from 255 colors palette defined in attributes area for each 4x8 pixels field.
The colors to be substituted are:
- 1 (0b0001) - ink (2)
- 5 (0b0101) - ink (1)
- 8 (0b1000) - paper (2)
- 12 (0b1100) - paper (1)

The mechanism of reading colors is exactly the same as for Dual Playfield mode (reading of colors 00/10 and 01/11 overlaps).

To give up using colors defined in attributes area, and use all 16 palette entries directly, bit 5 in mode number must be set (OUT 255, 40).
To use the Pentagon byte organization, set the bit 4 (OUT 255, 24).
Regular pixel pair (left/right pixel) organization in byte is RG+l Gl Rl Bl  RG+r Gr Rr Br.
Pentagon order is Yr Yl Gr Rr  Br Gl Rl Bl.

For best compatibility with Pentagon 16col mode use both bits (OUT 255, 56). The same effect can be achieved by running OUT 61431, 1.