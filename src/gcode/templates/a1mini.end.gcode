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
; are the MIDI file's own (48-56); each B/D/F is proportional to that note's
; real length in the MIDI (ms in the comments), so the rhythm matches the song.
M17
M400 S1
M1006 S1
;===== duration is proportional to the MIDI's real note lengths (ms in comments)
M1006 A48 B46 L100 C48 D46 M100 E48 F46 N100  ; C  (417ms) "Spi-"
M1006 A51 B23 L100 C51 D23 M100 E51 F23 N100  ; Eb (208ms) "-der-"
M1006 A55 B69 L100 C55 D69 M100 E55 F69 N100  ; G  (625ms) "-MAN"
M1006 A53 B69 L100 C53 D69 M100 E53 F69 N100  ; F  (625ms)
M1006 A51 B69 L100 C51 D69 M100 E51 F69 N100  ; Eb (625ms)
M1006 A48 B69 L100 C48 D69 M100 E48 F69 N100  ; C  (625ms)
M1006 A48 B46 L100 C48 D46 M100 E48 F46 N100  ; C  (417ms) "Spi-"
M1006 A51 B23 L100 C51 D23 M100 E51 F23 N100  ; Eb (208ms) "-der-"
M1006 A55 B61 L100 C55 D61 M100 E55 F61 N100  ; G  (556ms) "-MAN"
M1006 A56 B31 L100 C56 D31 M100 E56 F31 N100  ; G# (278ms)
M1006 A55 B31 L100 C55 D31 M100 E55 F31 N100  ; G  (278ms)
M1006 A53 B69 L100 C53 D69 M100 E53 F69 N100  ; F  (625ms)
M1006 A51 B69 L100 C51 D69 M100 E51 F69 N100  ; Eb (625ms)
M1006 A48 B72 L100 C48 D72 M100 E48 F72 N100  ; C  (903ms, hold; capped at 72)
M1006 W
M18
M84
M117 Print complete
