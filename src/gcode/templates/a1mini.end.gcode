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
; --- end tune: Spider-Man (1967) theme ---
; "Spider-Man, Spider-Man, does whatever a spider can." The print is done; this
; is what says so across the booth. Transcribed from "Spiderman Theme.mid" —
; C Eb G F Eb C, then C Eb G G# G F Eb C. Played on the stepper motors (M1006),
; so the steppers go back on for the tune and off again after it. The pitches
; are the MIDI file's own (48-56); durations scaled from it, 10 short to 40 long.
M17
M400 S1
M1006 S1
M1006 A48 B18 L100 C48 D18 M100 E48 F18 N100  ; C  "Spi-"
M1006 A51 B10 L100 C51 D10 M100 E51 F10 N100  ; Eb "-der-"
M1006 A55 B26 L100 C55 D26 M100 E55 F26 N100  ; G  "-MAN"
M1006 A53 B26 L100 C53 D26 M100 E53 F26 N100  ; F
M1006 A51 B26 L100 C51 D26 M100 E51 F26 N100  ; Eb
M1006 A48 B26 L100 C48 D26 M100 E48 F26 N100  ; C
M1006 A48 B18 L100 C48 D18 M100 E48 F18 N100  ; C  "Spi-"
M1006 A51 B10 L100 C51 D10 M100 E51 F10 N100  ; Eb "-der-"
M1006 A55 B24 L100 C55 D24 M100 E55 F24 N100  ; G  "-MAN"
M1006 A56 B12 L100 C56 D12 M100 E56 F12 N100  ; G#
M1006 A55 B12 L100 C55 D12 M100 E55 F12 N100  ; G
M1006 A53 B26 L100 C53 D26 M100 E53 F26 N100  ; F
M1006 A51 B26 L100 C51 D26 M100 E51 F26 N100  ; Eb
M1006 A48 B40 L100 C48 D40 M100 E48 F40 N100  ; C  (hold)
M1006 W
M18
M84
M117 Print complete
