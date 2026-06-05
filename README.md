🏫 Classroom Monitoring Counter
A real-time people counting system for classroom occupancy monitoring, implemented in Verilog on the Basys 3 FPGA board using Xilinx Vivado.

📌 Overview
This project uses two IR sensors placed at a classroom door to detect the direction of movement — counting people entering and exiting in real time. The current occupancy is displayed on a 7-segment display, with LED indicators and a buzzer alert when the room reaches full capacity.

 #✨ Features

-👥 Bidirectional People Counting — Detects entry vs exit using sensor sequence (FSM-based)
-🔢 7-Segment Display — Shows live count (0–99) on the Basys 3 onboard display
-🚦 LED Status Indicators — Green (empty), Yellow (near full ≥18), Red (full ≥20)
-🔔 Buzzer Alert — Activates when room reaches capacity (count ≥ 20)
-💡 Auto Room Light Control — Light turns on when room is occupied (count > 0)
-🔄 Manual Override — Switch between auto and manual light control
-🛡️ Debounce Circuit — Cleans up noisy IR sensor signals (500K cycle stable window)



🎓DIAGRAM:
<img width="461" height="617" alt="Screenshot 2026-06-05 211639" src="https://github.com/user-attachments/assets/187efede-f499-4883-b6c8-bcbcb97f79ef" />


🛠️ Hardware
-ComponentDetailFPGA BoardBasys 3 (Artix-7)Clock100 MHz onboardIR 
-Sensors2× LM393 (Active Low) via PMOD 
-JABuzzer1× via PMOD JA Pin 3
-DisplayOnboard 4-digit 7-segmentLEDsOnboard LEDs (Red, Yellow, Green)

📁 Project Structure
classroom-monitoring-counter/
-├── src/
-│   ├── full_system.v       # Top-level module
-│   ├── fsm.v               # Entry/Exit detection FSM
-│   ├── counter.v           # Up/Down counter (0–99)
-│   ├── debounce.v          # Button/sensor debouncer
-│   ├── comparator.v        # Threshold logic (full/warn/empty)
-│   ├── led_control.v       # RGB LED driver
-│   ├── seven_seg.v         # Multiplexed 7-segment display
-│   ├── buzzer_ctrl.v       # Buzzer controller
-│   ├── light_ctrl.v        # Auto light logic
-│   └── override_ctrl.v     # Manual/auto mode selector
-├── constraints/
-│   └── pinmapping.xdc      # Basys 3 pin assignments
-└── README.md

🔧 Module Description
-full_system.v — Top Level
 Wires all submodules together. Entry point for synthesis.
-fsm.v — Finite State Machine
-Detects movement direction based on IR sensor trigger sequence:

S1 → S2: Person entering → inc pulse
S2 → S1: Person exiting → dec pulse
Timeout resets FSM if sequence is incomplete

-counter.v
Up/down counter clamped between 0 and 99.
debounce.v
Filters noisy sensor signals using a 500,000 clock cycle stable window (~5 ms at 100 MHz).
comparator.v
Generates threshold flags:

full → count ≥ 20
warn → count ≥ 18
empty → count == 0

-seven_seg.v
Multiplexed 2-digit display, refreshed via clock divider.
led_control.v
Priority-encoded LED output: Red > Yellow > Green.

🚀 How to Run

Open Xilinx Vivado
Create a new project and add all .v files from src/
Add constraints/pinmapping.xdc as the constraint file
Run Synthesis → Implementation → Generate Bitstream
Connect Basys 3 via USB and program the board


-📐 Pin Mapping (Basys 3)
SignalPinDescriptionclkW5100 MHz system clockrstU18Reset buttons1_rawJ1Outer IR sensor (PMOD JA)s2_rawL2Inner IR sensor (PMOD JA)buzzerJ2Buzzer output (PMOD JA)modeV17Auto/Manual switchmanual_lightV16Manual light switchredU16Red LEDyellowE19Yellow LEDgreenU19Green LEDlightV19Room light output

-🎓 Concepts Demonstrated

Finite State Machine (FSM) design in Verilog
Modular hardware design (multi-module architecture)
Clock-based debouncing
Multiplexed 7-segment display driving
Hardware sensor interfacing (LM393 IR, Active Low)
Constraint-based FPGA pin assignment (XDC)

