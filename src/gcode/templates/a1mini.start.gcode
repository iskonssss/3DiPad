; ============================================================================
; A1 mini START — real sequence (adapted from a working A1 mini print).
; Homes, optionally calibrates, then lays a prime line, in relative-E (M83),
; which is exactly what the engine emits. Braced names are substituted by the
; engine: temperatures from the temp block, the calibration step from the
; calibration block (bed levelling is off by default - see config.example.json).
; ============================================================================
; --- start tune: "Witch Doctor" ---
; "Ooh ee ooh ah ah, ting tang, walla walla bing bang."
;
; Not decoration at a booth: a child who has just handed over their drawing has
; no other way to know that THEIR print is the one that started, and a tune
; carries across a fair floor where a screen does not. One they can sing back is
; worth more than a chime.
;
; Format, worked out from Bambu's own start tune in an exported A1 mini file:
; three voices, each a pitch/duration/volume triple — A,B,L then C,D,M then E,F,N.
; Pitch is a MIDI note number and 0 is a rest; here the melody is doubled on
; voices 2 and 3, which is what Bambu does. Duration 10 is a beat, 20 holds.
; Kept in the same low register as Bambu's own tune, which is known to sound on
; this hardware — the notes are played by the stepper motors, so pitch is not
; free and a melody two octaves up may not carry.
;
; The tune is by ear. If a phrase is wrong, the numbers below are MIDI notes:
; C=48 D=50 E=52 F=53 G=55 A=57 B=59, and +12 is an octave up.
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

G90
M83
M140 S{bedFirst}
M104 S140 ; preheat nozzle for homing/levelling
M190 S{bedFirst} ; wait for bed temp
G28 ; home all axes
{calibration}
M104 S{nozzleFirst}
M109 S{nozzleFirst} ; wait for full print temp before any extrusion
M106 S0 ; part fan off for the first layer
G1 Z5 F1200
; --- prime line ---
G1 E-0.8 F2100
G1 X10 Y3 F12000
G1 Z0.25 F1200
G1 E0.8 F2100
G1 X65 Y3 E4.116 F720
G1 X65 Y3.8 E0.06 F720
G1 X10 Y3.8 E4.116 F720
G1 X18 Y3.8 F4800
G1 E-0.8 F2100
G1 Z0.85 F1200
