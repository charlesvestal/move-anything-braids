# Braids for Move Everything

Macro oscillator module based on [Mutable Instruments Braids](https://github.com/pichenettes/eurorack) by Emilie Gillet.

47 synthesis algorithms covering analog waveforms, FM, physical modeling, noise, and more.

## Features

- 47 synthesis engines (CSAW, FM, PLUK, BELL, DRUM, etc.)
- 4-voice polyphony with voice stealing
- AR envelope and SVF filter per voice
- Preset browser
- Works standalone or as a sound generator in Signal Chain patches

## Prerequisites

- [Move Everything](https://github.com/charlesvestal/move-anything) installed on your Ableton Move
- SSH access enabled: http://move.local/development/ssh

## Install

### Via Module Store (Recommended)

1. Launch Move Everything on your Move
2. Select **Module Store** from the main menu
3. Navigate to **Sound Generators** > **Braids**
4. Select **Install**

### Build from Source

Requires Docker (recommended) or ARM64 cross-compiler.

```bash
git clone https://github.com/charlesvestal/move-anything-braids
cd move-anything-braids
./scripts/build.sh
./scripts/install.sh
```

## Controls

| Control | Function |
|---------|----------|
| Jog wheel | Browse presets / navigate menus |
| Knobs 1-8 | Engine, Timbre, Color, Attack, Decay, Cutoff, Resonance, Octave |

## Parameters

| Parameter | Range | Description |
|-----------|-------|-------------|
| engine | 0-46 | Synthesis algorithm |
| timbre | 0.0-1.0 | Primary tone control |
| color | 0.0-1.0 | Secondary tone control |
| attack | 0.0-1.0 | Envelope attack time |
| decay | 0.0-1.0 | Envelope decay time |
| fm | 0.0-1.0 | FM amount (also via mod wheel) |
| cutoff | 0.0-1.0 | SVF filter cutoff |
| resonance | 0.0-1.0 | SVF filter resonance |
| volume | 0.0-1.0 | Output gain |
| octave_transpose | -3 to +3 | Octave shift |

## Credits

- **Braids DSP engine**: [Emilie Gillet / Mutable Instruments](https://github.com/pichenettes/eurorack) (MIT License)
- **stmlib support library**: [Emilie Gillet / Mutable Instruments](https://github.com/pichenettes/eurorack) (MIT License)
- **Move Everything port**: Charles Vestal

## License

MIT License - See [LICENSE](LICENSE)

## AI Assistance Disclaimer

This module is part of Move Everything and was developed with AI assistance, including Claude, Codex, and other AI assistants.

All architecture, implementation, and release decisions are reviewed by human maintainers.  
AI-assisted content may still contain errors, so please validate functionality, security, and license compatibility before production use.
