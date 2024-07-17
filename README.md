# NES-RMW2007
 A test cartridge that runs Read-Modify-Write instructions to address $2007 

# Creating the cartridge
Simply drag VRAMCorruption.asm over nesasm.exe to compile the ROM.

# Using this cartridge
The main screen looks like this:

![_RMW2007_Main](https://github.com/user-attachments/assets/695f4d7d-cf50-437e-8616-47ffb22be5c5)

By pressing Up and Down, you can select the test to run. Run the test by pressing A. You will see a screen like this:

![_RMW2007_INC](https://github.com/user-attachments/assets/6f92e583-6f3e-4c72-a1c5-f7f8bb1a30e8)

From this screen, by pressing the A button, you will run the selected test. In this case, I'll be running the INC test.

These tests start from VRAM Address $2100, and then run the operation. In this case, INC $2007

![_RMW2007_INC_A](https://github.com/user-attachments/assets/7757ae1e-3e62-4d1b-9f1c-25332d5f9f92)

Pressing the A button again will run the test again, but each press will add an additional 1 byte offset by running LDY $2007 before the test.

Since all the bytes from VRAM Address $2100 through $21FF are initialized as zeroes, I figured it would be convenient to have a page full of FFs.

To run the test from address $2200, hold the left button while pressing the A button.

![_RMW2007_INC_AL](https://github.com/user-attachments/assets/6c7a0234-bb6e-4d4c-b58c-3dd489cf2b1b)

You can press the B button to return to the main screen.

You can hold start to run the test every other frame, removing the need to mash the A button.

You can hold select to run the test every other frame, while also running 4 extra instances of the test.
