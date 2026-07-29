; ============================================================================
; GENERIC START SEQUENCE — REPLACE THIS FILE.
; Export any simple print for the A1 mini from Bambu Studio / OrcaSlicer with
; YOUR filament, open the .gcode, and paste everything from the top down to the
; first real print move here. That header runs the A1's auto bed levelling and
; flow calibration; without it prints can fail. Keep the {placeholders}.
; ============================================================================
G90
M104 S{nozzleFirst}
M140 S{bedFirst}
M190 S{bedFirst}
M109 S{nozzleFirst}
G28
G1 Z5.0 F600
; prime line along the front edge
M83
G1 X20 Y3 Z0.3 F3000
G1 X140 Y3 Z0.3 E14 F1000
G1 X140 Y3.4 Z0.3 F3000
G1 X20 Y3.4 Z0.3 E14 F1000
G1 Z1.0 F600
