# AMBA APB Protocol Verification 

## 📌 Project Overview
This repository contains the functional verification of an AMBA APB (Advanced Peripheral Bus) slave utilizing a custom **SystemVerilog** testbench. The environment is engineered to aggressively stress the hardware-software boundary of the digital logic by leveraging constrained-random stimuli, functional coverage models, and error-injection techniques.

All simulations, assertions, and coverage reports were executed using **QuestaSim**.

## 🛠️ Verification Architecture & Features
The verification environment is built on a robust, class-based SystemVerilog architecture featuring a complete Generator-Driver-Monitor-Scoreboard pipeline. 

* **Constrained-Random Testing:** Achieved 80/80 passing read/write transactions via automated test vector generation.
* **SystemVerilog Assertions (SVA):** Developed a 9-property SVA suite to continuously monitor APB handshake timing (e.g., `PSEL` to `PENABLE` transitions), signal stability, and the legality of the `PSLVERR` response.
* **Error-Injection Constraints:** Purposefully drove invalid-address corner cases to validate the Device Under Test's (DUT) error handling and edge-case reliability.
* **Coverage-Driven Verification:** Reached a 100% functional coverage goal across targeted covergroups.

---

## 📊 Simulation Results & Reports

### 1. Automated Test Execution
The testbench handles fully automated data parsing and validation. The scoreboard successfully matched all driven and monitored transactions, resulting in 0 test failures across 80 iterations.

<img width="1162" height="616" alt="terminal" src="https://github.com/user-attachments/assets/b9396760-9b93-4bd8-aae9-67ddca861d74" />

### 2. Waveform Analysis
The physical signal timing, including successful memory-mapped data writes/reads and the correct toggling of error flags (`pslverr`), was fully verified via QuestaSim waveform analysis.

<img width="2696" height="424" alt="waveform_zoom" src="https://github.com/user-attachments/assets/ae59bc5b-b3d0-437c-8de5-2c540a5bada0" />


### 3. Assertion & Protocol Checking
The SVA suite ran concurrently with the data-driven tests. All 9 properties successfully passed with zero failure counts, mathematically verifying APB protocol compliance.

<img width="936" height="414" alt="new_Ass" src="https://github.com/user-attachments/assets/e7df372b-ce54-46b9-ade6-daf70bae490b" />


### 4. Functional & Code Coverage
Coverage metrics were heavily prioritized to ensure complete testing of the RTL logic, ensuring all predefined corner cases (like back-to-back writes and invalid addresses) were hit.

<img width="938" height="804" alt="bins" src="https://github.com/user-attachments/assets/c22a4702-e3d2-495d-bbfa-202ed30a4ac3" />





---

## ⚙️ Environment Setup & How to Run
To run this verification environment locally using QuestaSim/ModelSim:

1. Clone the repository:
   ```bash
   git clone [https://github.com/Kalra-harshit/APB-Verification.git](https://github.com/Kalra-harshit/APB-Verification.git)
