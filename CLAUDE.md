# CLAUDE.md

Instructions for Claude Code when working with this repository.

## Project Overview

Braids module for Move Anything - a macro oscillator with 47 synthesis algorithms based on Mutable Instruments Braids.

## Architecture

```
src/
  dsp/
    braids_plugin.cpp   # Main plugin wrapper (V2 API)
    param_helper.h      # Parameter definition helpers (shared)
    braids/             # Braids DSP engine (MIT, Emilie Gillet)
      macro_oscillator  # Entry point - routes to analog/digital
      analog_oscillator # Classic waveforms
      digital_oscillator # FM, physical modeling, noise, etc.
      envelope.h        # AR envelope
      svf.h             # State variable filter
      resources         # Lookup tables
    stmlib/             # Mutable Instruments support library
  module.json           # Module metadata
  chain_patches/        # Signal Chain presets
```

## Key Implementation Details

### Plugin API

Implements Move Anything plugin_api_v2 (multi-instance):
- `create_instance`: Initializes 4 voices, each with MacroOscillator + Envelope + SVF
- `destroy_instance`: Cleanup
- `on_midi`: Note on/off with voice allocation, pitch bend, mod wheel (FM)
- `set_param`: engine, timbre, color, attack, decay, fm, cutoff, resonance, volume, octave_transpose
- `get_param`: ui_hierarchy, chain_params, state serialization, engine_name
- `render_block`: Renders 24-sample Braids blocks into 128-sample Move blocks

### Parameters

- `engine` (int 0-46): Synthesis algorithm (CSAW, MORPH, FM, PLUK, BELL, etc.)
- `timbre` (float 0-1): Primary tone parameter
- `color` (float 0-1): Secondary tone parameter
- `attack` (float 0-1): Envelope attack time
- `decay` (float 0-1): Envelope decay time
- `fm` (float 0-1): FM amount (also controlled by mod wheel)
- `cutoff` (float 0-1): SVF filter cutoff
- `resonance` (float 0-1): SVF filter resonance
- `volume` (float 0-1): Output gain
- `octave_transpose` (int -3 to +3): Octave shift

### Voice Management

4-voice polyphonic with voice stealing (oldest voice). Each voice has independent MacroOscillator, AR Envelope, and SVF filter.

### Sample Rate

Braids lookup tables are calibrated for 96kHz. A pitch correction offset of +1724 (128ths of semitone) compensates for Move's 44.1kHz operation.

## Build

```bash
./scripts/build.sh           # Cross-compile via Docker
./scripts/install.sh         # Deploy to Move
```

## License

MIT (inherited from Mutable Instruments Braids)
