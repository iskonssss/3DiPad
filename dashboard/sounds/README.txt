Booth speaker sounds
====================

The dashboard (open on the booth laptop) plays a sound through the LAPTOP's
speakers when a print starts and finishes. The A1 mini itself has no speaker —
its own tunes are made by the stepper motors — so real audio lives here.

Drop two files in this folder:

    start.mp3     played when a printer begins printing
    finish.mp3    played when a print finishes cleanly

Use whatever you have the right to use. For the John Cena entrance, a short
clip of your own copy of the track works; keep it a few seconds so it does not
run over the next kid. Any browser audio format is fine if you rename it to
.mp3, or ask and the player can be pointed at .wav/.ogg too.

Nothing plays if the files are absent, and the header's "🔊 Sound" button
turns it off. Because browsers block audio until the page is clicked, the first
tap anywhere on the dashboard enables it — the operator has pressed Send long
before anything needs to sound.

These files are NOT committed to git (see .gitignore here), so each booth
laptop keeps its own.
