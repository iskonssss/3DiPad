; ============================================================================
; A1 mini START — real sequence (adapted from a working A1 mini print).
; Homes, optionally calibrates, then lays a prime line, in relative-E (M83),
; which is exactly what the engine emits. Braced names are substituted by the
; engine: temperatures from the temp block, the calibration step from the
; calibration block (bed levelling is off by default - see config.example.json).
; ============================================================================
; --- start tune: John Cena, "My Time Is Now" (the trumpet fanfare) ---
; "Duh duh duh DAAH, duh duh duh DAAH, duh-duh-duh-DAAAH."
;
; Not decoration at a booth: a child who has just handed over their drawing has
; no other way to know that THEIR print is the one that started, and a tune
; carries across a fair floor where a screen does not. And this one the whole
; queue joins in on.
;
; Format, worked out from Bambu's own start tune in an exported A1 mini file:
; three voices, each a pitch/duration/volume triple — A,B,L then C,D,M then E,F,N.
; Pitch is a MIDI note number and 0 is a rest; the melody is doubled on voices 2
; and 3, which is what Bambu does. Duration 10 is a beat, 20 holds.
; Kept in a low register — the notes are played by the STEPPER MOTORS, not a
; speaker, so this is the tune of the fanfare, not the trumpet, and a melody two
; octaves up may not carry.
;
; It is the hook by ear: three pickups and a held note, twice, then a rising run
; to a triumphant top. To retune a phrase, the numbers are MIDI notes:
; C=48 D=50 E=52 F=53 G=55 A=57 B=59, and +12 is an octave up.
M17
M400 S1
M1006 S1
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100    ; duh
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100    ; duh
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100    ; duh
M1006 A55 B20 L100 C52 D20 M100 E52 F20 N100  ; DAAH
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100    ; duh
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100    ; duh
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100    ; duh
M1006 A55 B20 L100 C52 D20 M100 E52 F20 N100  ; DAAH
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C55 D10 M100 E55 F10 N100    ; duh
M1006 A0 B0 L100 C57 D10 M100 E57 F10 N100    ; duh
M1006 A0 B0 L100 C59 D10 M100 E59 F10 N100    ; duh
M1006 A60 B20 L100 C60 D20 M100 E60 F20 N100  ; DAAAH
M1006 A60 B20 L100 C60 D20 M100 E60 F20 N100  ; (held)
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
M412 S1 ; filament runout detection on (Bambu start)
M400 P10
M620.3 W1 ; filament tangle detection on (Bambu start)
M400 S2
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
