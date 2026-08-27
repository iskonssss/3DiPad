; ============================================================================
; A1 mini END — retract, lift clear, park at the back, cool down.
; ============================================================================
G1 E-0.8 F2100
G91
G1 Z15 F1200
G90
G1 X10 Y170 F12000
M104 S0
M140 S0
M106 S0
; --- end tune: "Witch Doctor" ---
; "Ooh ee ooh ah ah, ting tang, walla walla bing bang." The print is done; this
; is what says so across the booth. Played on the stepper motors (M1006), so
; the steppers go back on for the tune and off again after it. To retune, MIDI:
; C=48 D=50 E=52 F=53 G=55 A=57 B=59, +12 an octave up; duration 10 a beat, 20 a hold.
M17
M400 S1
M1006 S1
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100  ; Ooh
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100  ; ee
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100  ; ooh
M1006 A0 B0 L100 C52 D10 M100 E52 F10 N100  ; ah
M1006 A48 B20 L100 C52 D20 M100 E52 F20 N100  ; ah
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100  ; ting
M1006 A0 B0 L100 C55 D20 M100 E55 F20 N100  ; tang
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C57 D10 M100 E57 F10 N100  ; wal
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100  ; la
M1006 A0 B0 L100 C57 D10 M100 E57 F10 N100  ; wal
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100  ; la
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A52 B20 L100 C52 D20 M100 E52 F20 N100  ; bing
M1006 A48 B20 L100 C48 D20 M100 E48 F20 N100  ; bang
M1006 W
M18
M84
M117 Print complete
