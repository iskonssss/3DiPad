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
M1006 A48 B51 L100 C48 D51 M100 E48 F51 N100  ; C  (417ms) "Spi-"
M1006 A51 B26 L100 C51 D26 M100 E51 F26 N100  ; Eb (208ms) "-der-"
M1006 A55 B77 L100 C55 D77 M100 E55 F77 N100  ; G  (625ms) "-MAN"
M1006 A53 B77 L100 C53 D77 M100 E53 F77 N100  ; F  (625ms)
M1006 A51 B77 L100 C51 D77 M100 E51 F77 N100  ; Eb (625ms)
M1006 A48 B77 L100 C48 D77 M100 E48 F77 N100  ; C  (625ms)
M1006 A48 B51 L100 C48 D51 M100 E48 F51 N100  ; C  (417ms) "Spi-"
M1006 A51 B26 L100 C51 D26 M100 E51 F26 N100  ; Eb (208ms) "-der-"
M1006 A55 B68 L100 C55 D68 M100 E55 F68 N100  ; G  (556ms) "-MAN"
M1006 A56 B34 L100 C56 D34 M100 E56 F34 N100  ; G# (278ms)
M1006 A55 B34 L100 C55 D34 M100 E55 F34 N100  ; G  (278ms)
M1006 A53 B77 L100 C53 D77 M100 E53 F77 N100  ; F  (625ms)
M1006 A51 B77 L100 C51 D77 M100 E51 F77 N100  ; Eb (625ms)
M1006 A48 B80 L100 C48 D80 M100 E48 F80 N100  ; C  (903ms, hold; capped at 80)
M1006 W
M18
M84
M117 Print complete
