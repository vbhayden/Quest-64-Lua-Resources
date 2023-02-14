# Quest 64 Lua Resources
This repo contains various resources for practicing Quest 64 speedrun categories, particularly categories allowing glitches.  The primary motivation for this repo is to help runners learn and practice the tricky parts of these categories, namely: 

- Going Out of Bounds
- Performing the Death Dupe

These tricks are the most time-saving parts of Quest's glitched categories, but have historically eaten a significant amount of time from both newer and experienced runners alike -- with Death Dupe being particularly infamous. 

To use these resources, you will need the latest version of the Bizhawk emulator and a legally obtained ROM of Quest 64.

## Emulator Setup

For the emulator, you can download **[the latest version of Bizhawk](https://tasvideos.org/BizHawk/ReleaseHistory#Bizhawk28)** from tasvideos.org.  It shouldn't need to be installed and can run just fine from within a folder.

Next, open your legally obtained copy of the Quest 64 ROM and configure your controller until everything looks good.  

As an optional last step, download the `HelloWorld.lua` script and open it with Bizhawk's Lua Console, available via `Tools -> Lua Console`.  Aside from seeing a simple `"Hello World!"` in the console, it's good to become familiar with this step, as we will repeat this process when loading in practice scripts etc.

## Death Dupe Practice 💀

The very first trick used in the unrestricted categories also happens to be the most difficult: Death Dupe.  This trick is actually several tricks executed in quick succession, with the timing of each being important to ensure the reliability of the next.

### Setting up the Practice Environment
All required resources (including the save states) can be found in this repo, so you shouldn't need anything other than Bizhawk and your Quest ROM to get started.

To get started:
- **[Download the practice states](https://github.com/vbhayden/Quest-64-Lua-Resources/releases/tag/v0.1)** from the releases page
- Copy the practice states into your Bizhawk folder, the path should be `<Your Bizhawk>/N64/State`
- **[Download the practice script](https://raw.githubusercontent.com/vbhayden/Quest-64-Lua-Resources/master/lua/Quest64_DeathDupePractice.lua)** from this repo
- Load the practice script into your Lua Console
- (Optional) <kbd>CTRL</kbd>+<kbd>S</kbd> to save the Lua Session for faster loading next time

Once those are complete, loading the Quest 64 ROM and pressing <kbd>F1</kbd> should present a low-health Brian ready to escape an encounter.

### Using the Practice States

There are 5 practice states included in the zip file:
- <kbd>F1</kbd> An encounter to escape from to ensure our step count is at 0.
- <kbd>F2</kbd> *Unused, will be overwritten by the Auto-Save Lua script if used.*
- <kbd>F3</kbd> Encounter with 2x Hell Hounds.
- <kbd>F4</kbd> Encounter with 1x Hell Hound.
- <kbd>F5</kbd> Encounter with Parassault and Bumpershoot.

### Practicing with the Lua

To more reliably set up the Death Dupe, the Lua script will display a few values on the screen and provides feedback for how accurately we are satisfying the Death Dupe conditions.  

For some context, the Death Dupe requires us to trigger an encounter with a few conditions:
1. We are standing on a spirit
2. We have the spell menu open
3. We are slower than the encounter
4. We can be killed instantly during the encounter
5. We can escape the encounter

Since conditions 4 and 5 are already satisfied and condition 3 is random due to Were Hare and Big Mouth being in the encounter table, we are left to practice the act of triggering an encounter while standing on a spirit with the spell menu open.

The Lua script will display when the next encounter will trigger, allowing you to work out the timing for accumulating distance and attempting to trigger one on the spirit.
