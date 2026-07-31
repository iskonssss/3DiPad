; ============================================================================
; A1 mini START — real sequence (adapted from a working A1 mini print).
; Homes, optionally calibrates, then lays a prime line, in relative-E (M83),
; which is exactly what the engine emits. Braced names are substituted by the
; engine: temperatures from the temp block, the calibration step from the
; calibration block (bed levelling is off by default - see config.example.json).
; ============================================================================
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
