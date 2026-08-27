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
; are the MIDI file's own (48-56). Timing is taken from the MIDI's note ONSETS
; (the gaps between note starts) with a short rest after each note, so the hook
; phrases as short-short-LONG ('Spi-der-MAN') instead of dragging as equal notes.
M17
M400 S1
M1006 S1
;===== duration is proportional to the MIDI's real note lengths (ms in comments)
M1006 A48 B38 L100 C48 D38 M100 E48 F38 N100  ; C  "Spi-"  (417ms slot)
M1006 A0  B8  L100 C0  D8  M100 E0  F8  N100  ; -
M1006 A51 B25 L100 C51 D25 M100 E51 F25 N100  ; Eb "-der-"  (278ms)
M1006 A0  B5  L100 C0  D5  M100 E0  F5  N100  ; -
M1006 A55 B80 L100 C55 D80 M100 E55 F80 N100  ; G  "-MAN"  (972ms, long)
M1006 A0  B19 L100 C0  D19 M100 E0  F19 N100  ; -
M1006 A53 B38 L100 C53 D38 M100 E53 F38 N100  ; F   (417ms)
M1006 A0  B8  L100 C0  D8  M100 E0  F8  N100  ; -
M1006 A51 B25 L100 C51 D25 M100 E51 F25 N100  ; Eb  (278ms)
M1006 A0  B5  L100 C0  D5  M100 E0  F5  N100  ; -
M1006 A48 B80 L100 C48 D80 M100 E48 F80 N100  ; C  (972ms, phrase end)
M1006 A0  B19 L100 C0  D19 M100 E0  F19 N100  ; -
M1006 A48 B38 L100 C48 D38 M100 E48 F38 N100  ; C  "Spi-"  (417ms)
M1006 A0  B8  L100 C0  D8  M100 E0  F8  N100  ; -
M1006 A51 B25 L100 C51 D25 M100 E51 F25 N100  ; Eb "-der-"  (278ms)
M1006 A0  B5  L100 C0  D5  M100 E0  F5  N100  ; -
M1006 A55 B38 L100 C55 D38 M100 E55 F38 N100  ; G   (417ms)
M1006 A0  B8  L100 C0  D8  M100 E0  F8  N100  ; -
M1006 A56 B19 L100 C56 D19 M100 E56 F19 N100  ; G#  (208ms, passing)
M1006 A0  B4  L100 C0  D4  M100 E0  F4  N100  ; -
M1006 A55 B38 L100 C55 D38 M100 E55 F38 N100  ; G   (417ms)
M1006 A0  B8  L100 C0  D8  M100 E0  F8  N100  ; -
M1006 A53 B38 L100 C53 D38 M100 E53 F38 N100  ; F   (417ms)
M1006 A0  B8  L100 C0  D8  M100 E0  F8  N100  ; -
M1006 A51 B25 L100 C51 D25 M100 E51 F25 N100  ; Eb  (278ms)
M1006 A0  B5  L100 C0  D5  M100 E0  F5  N100  ; -
M1006 A48 B80 L100 C48 D80 M100 E48 F80 N100  ; C  (final, held)
M1006 W
M18
M84
M117 Print complete
