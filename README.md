# AGPTCodexProject

This repository contains a simple Move module demonstrating a guessing game on Aptos.

## Aptos Guessing Game

The module is located in `aptos_guess_game/sources/guessing_game.move` and allows up to ten players to submit a guess from 1-99. When the tenth player joins, the game picks a pseudo-random number and distributes prizes based on the closest guess.

### Compile and Test

1. Install the [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/install-cli/).
2. Navigate to the project root and run:
   ```bash
   aptos move test -p aptos_guess_game
   ```
   This will compile the module and run any Move tests. (No tests are currently included, but this ensures the code builds.)

### Deploy

After testing, publish the module to your desired Aptos account:
```bash
aptos move publish -p aptos_guess_game --private-key <PATH_TO_KEY> --profile default
```
Replace `<PATH_TO_KEY>` with your key file or use your configured CLI profile.

### Frontend Example

A minimal web frontend is provided in the `frontend` directory. Open `frontend/index.html` in a browser to test basic interactions. The page uses `aptos.js` from a CDN and demonstrates how to call the `join` entry function.

## Repository Structure

- `aptos_guess_game/` – Move module source code
- `frontend/` – sample webpage to interact with the contract

Feel free to expand on these examples for your own use.
