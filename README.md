# 🏫 Classroom Monitoring Counter (FPGA | Verilog | Basys 3)

> Real-time intelligent occupancy monitoring system implemented on FPGA using Verilog HDL with FSM-based bidirectional people counting.

---

## 📌 Overview

This project implements a **real-time classroom occupancy monitoring system** on the **:contentReference[oaicite:0]{index=0}**, designed using **Verilog HDL** in **:contentReference[oaicite:1]{index=1}**.

Two IR sensors detect entry and exit movements, and a **finite state machine (FSM)** determines direction. The system displays live occupancy on a **7-segment display**, along with LED indicators and a buzzer alert for full capacity conditions.

---

## 🎯 Objectives

- Design a real-time embedded monitoring system using FPGA  
- Implement FSM-based direction detection  
- Develop modular Verilog architecture  
- Interface sensors, LEDs, buzzer, and 7-segment display  
- Ensure noise-free input using debouncing techniques  

---

## ✨ Key Features

- 👥 Bidirectional people counting (Entry / Exit detection)  
- 🔁 FSM-based movement tracking  
- 🔢 Real-time 0–99 occupancy display  
- 🚦 Status indicators:
  - Green → Safe
  - Yellow → Near capacity
  - Red → Full capacity  
- 🔔 Buzzer alert at threshold limit  
- 💡 Automatic room light control  
- 🔄 Manual override mode support  
- 🛡️ Debounced sensor inputs for stability  



## 🧠 System Architecture

IR Sensors → Debounce → FSM → Counter → Comparator
                                      ↓
     LEDs ← LED Controller ← Status Flags
                                      ↓
       7-Segment Display + Buzzer + Light Control


---

-📊 Schematic & Circuit Diagram Smart Classroom People Counter System using Verilog HDL on Basys3 FPGA:
---
<img width="461" height="617" alt="Screenshot 2026-06-05 211639" src="https://github.com/user-attachments/assets/187efede-f499-4883-b6c8-bcbcb97f79ef" />

| Component  | Detail                            |
| ---------- | --------------------------------- |
| FPGA Board | Basys 3 (Artix-7)                 |
| Clock      | 100 MHz onboard                   |
| IR Sensors | 2× LM393 (Active Low) via PMOD JA |
| Buzzer     | 1× via PMOD JA Pin 3              |
| Display    | Onboard 4-digit 7-segment         |
| LEDs       | Onboard LEDs (Red, Yellow, Green) |

---
📁 Project Structure
classroom-monitoring-counter/
│
├── src/
│   ├── full_system.v        # Top-level module
│   ├── fsm.v               # Entry/Exit detection FSM
│   ├── counter.v           # Up/Down counter (0–99)
│   ├── debounce.v          # Button/sensor debouncer
│   ├── comparator.v        # Threshold logic (full/warn/empty)
│   ├── led_control.v       # RGB LED driver
│   ├── seven_seg.v         # Multiplexed 7-segment display
│   ├── buzzer_ctrl.v       # Buzzer controller
│   ├── light_ctrl.v        # Auto light logic
│   └── override_ctrl.v     # Manual/auto mode selector
│
├── constraints/
│   └── pinmapping.xdc      # Basys 3 pin assignments
│
└── README.md


---

# 🔧 Module Description

### full_system.v
Top-level module that integrates all submodules and acts as the system entry point for synthesis.

---

### fsm.v
Finite State Machine for movement detection:

- S1 → S2 → Person entering → increment counter  
- S2 → S1 → Person exiting → decrement counter  
- Timeout reset if sequence is incomplete  

---

### counter.v
- Up/Down counter (range: 0–99)  
- Saturated logic (prevents overflow/underflow)  

---

### debounce.v
- Removes noise from IR sensor signals  
- Uses ~500,000 clock cycle stability window (~5 ms @ 100 MHz)  

---

### comparator.v
Generates system status flags:

- FULL → count ≥ 20  
- WARNING → count ≥ 18  
- EMPTY → count = 0  

---

### seven_seg.v
- Multiplexed 2-digit 7-segment display  
- Clock divider based refresh system  

---

### led_control.v
Priority-based LED system:

Red > Yellow > Green

---

### buzzer_ctrl.v
Activates buzzer when system reaches full capacity.

---

### light_ctrl.v
Controls automatic room light based on occupancy.

---

### override_ctrl.v
Enables manual/auto control switching mode.

---

# 🚀 How to Run

- Open Xilinx Vivado  
- Create a new RTL project  
- Add all `.v` files from `src/`  
- Add constraint file `pinmapping.xdc`  
- Run:
  - Synthesis  
  - Implementation  
  - Generate Bitstream  
- Connect Basys 3 via USB  
- Program the FPGA  

--- ## 💾 Direct Hardware Deployment (Pre-Compiled Bitstream)

If you have a **Basys3 FPGA Board (XC7A35T)** and want to run this project instantly without opening Xilinx Vivado or compiling the Verilog source code, you can flash the pre-compiled programming file directly.
---

### Deployment Steps:
1. Download the `full_system.bit` file from the release section of this repository.
2. Connect your Basys3 board to your PC via USB and power it ON.
3. Open **Xilinx Vivado** and click on **Hardware Manager** -> **Open Target**.
4. Right-click on the target FPGA chip (`xc7a35t_0`), select **Program Device**, and browse to the downloaded `full_system.bit` file.
5. Click **Program**. The Smart Classroom Counter logic will be fully operational on your board instantly!

# 📐 Pin Mapping (Basys 3)

| Signal | Pin | Description |
|--------|-----|------------|
| clk | W5 | 100 MHz system clock |
| rst | U18 | Reset |
| s1_raw | J1 | Outer IR sensor (PMOD JA) |
| s2_raw | L2 | Inner IR sensor (PMOD JA) |
| buzzer | J2 | Buzzer output |
| mode | V17 | Auto/Manual switch |
| manual_light | V16 | Manual light control |
| red | U16 | Red LED |
| yellow | E19 | Yellow LED |
| green | U19 | Green LED |
| light | V19 | Room light output
---
