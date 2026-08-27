; ============================================================================
; A1 mini START — real sequence (adapted from a working A1 mini print).
; Homes, optionally calibrates, then lays a prime line, in relative-E (M83),
; which is exactly what the engine emits. Braced names are substituted by the
; engine: temperatures from the temp block, the calibration step from the
; calibration block (bed levelling is off by default - see config.example.json).
; ============================================================================
; --- start tune: Spider-Man 3, "Black Suit" theme ---
; Transcribed from "Spiderman 3 Black suit theme.mid": four quick notes, a lift
; and a long held note, then the same four and a lower held note. The dark,
; brooding motif — D F D F Bb A(hold), D F D F G#(hold).
;
; Not decoration at a booth: a child who has just handed over their drawing has
; no other way to know that THEIR print is the one that started, and a tune
; carries across a fair floor where a screen does not.
;
; Format, worked out from Bambu's own start tune in an exported A1 mini file:
; three voices, each a pitch/duration/volume triple — A,B,L then C,D,M then E,F,N.
; Pitch is a MIDI note number and 0 is a rest; the melody plays on all three
; voices for volume. Each B/D/F is proportional to the MIDI's real note length
; (the ms is in each line's comment), so the rhythm matches the song; the long
; held notes are capped so a single tone does not drone for three seconds. The
; notes are played by the STEPPER MOTORS, not a speaker, so it is the tune, not
; the orchestra — but it carries. Pitches are the MIDI file's own (56-70), which
; already sit in the register this hardware plays.
M17
M400 S1
M1006 S1
;===== duration is proportional to the MIDI's real note lengths (ms in comments)
M1006 A62 B12 L100 C62 D12 M100 E62 F12 N100  ; D  (109ms)
M1006 A65 B12 L100 C65 D12 M100 E65 F12 N100  ; F  (109ms)
M1006 A62 B12 L100 C62 D12 M100 E62 F12 N100  ; D  (111ms)
M1006 A65 B12 L100 C65 D12 M100 E65 F12 N100  ; F  (109ms)
M1006 A70 B37 L100 C70 D37 M100 E70 F37 N100  ; Bb (332ms)
M1006 A69 B72 L100 C69 D72 M100 E69 F72 N100  ; A  (2665ms, held; capped at 72)
M1006 A62 B12 L100 C62 D12 M100 E62 F12 N100  ; D  (109ms)
M1006 A65 B12 L100 C65 D12 M100 E65 F12 N100  ; F  (109ms)
M1006 A62 B12 L100 C62 D12 M100 E62 F12 N100  ; D  (111ms)
M1006 A65 B12 L100 C65 D12 M100 E65 F12 N100  ; F  (109ms)
M1006 A56 B72 L100 C56 D72 M100 E56 F72 N100  ; G# (2999ms, held; capped at 72)
M1006 W
M18

G90
M83
M140 S{bedFirst}
M104 S140 ; preheat nozzle for homing/levelling
M190 S{bedFirst} ; wait for bed temp
G28 ; home all axes
; --- prepare material: Bambu's own start section, transcribed line for line from a
; --- real Bambu Studio export for this printer (external spool, no AMS). This is
; --- where the firmware learns that filament 0 is the one loaded: "M620 M" enables
; --- the tool remap and T0 binds it. Without it the later T1 in the colour change
; --- resolved to an AMS slot and the load died on "AMS Lite communication is
; --- abnormal" — the cut and eject worked, the reload never came. Costs ~100 mm
; --- of filament and about half a minute, which is what Bambu spends too.
G1 X0.0 F30000
G1 X-13.5 F3000
M620 M ;enable remap
M620 S0A   ; switch material if AMS exist
    G392 S0
    M1002 gcode_claim_action : 4
    M400
    M1002 set_filament_type:UNKNOWN
    M109 S{nozzleFirst}
    M104 S220
    M400
    T0
    G1 X-13.5 F3000
    M400
    M620.1 E F299.339 T220
    M109 S220 ;set nozzle to common flush temp
    M106 P1 S0
    G92 E0
    G1 E50 F200
    M400
    M1002 set_filament_type:PLA
    M104 S220
    G92 E0
    G1 E50 F299.339
    M400
    M106 P1 S178
    G92 E0
    G1 E5 F299.339
    M109 S200 ; drop nozzle temp, make filament shink a bit
    M104 S180
    G92 E0
    G1 E-0.5 F300
    G1 X0 F30000
    G1 X-13.5 F3000
    G1 X0 F30000 ;wipe and shake
    G1 X-13.5 F3000
    G1 X0 F12000 ;wipe and shake
    G1 X0 F30000
    G1 X-13.5 F3000
    M109 S180
    G392 S0
M621 S0A
M400
M106 P1 S0
; --- prepare material end ---
{calibration}
M104 S{nozzleFirst}
M109 S{nozzleFirst} ; wait for full print temp before any extrusion
M106 S0 ; part fan off for the first layer
G1 Z5 F1200
; Filament sensors deliberately NOT enabled. The Bambu start these were copied
; from turns on runout (M412) and TANGLE detection (M620.3) — but tangle is an
; AMS odometer feature, and on a bare external spool it can false-trigger and
; CANCEL a print at a random point (HMS 0300_400C). Job 82 cancelled at 11% and
; then, re-sent, at 33% — same file, different point, while its siblings printed
; fine: the signature of an intermittent sensor trip, not a bad line. A booth
; operator is watching the spools anyway. Do not re-add these without a reason.
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
