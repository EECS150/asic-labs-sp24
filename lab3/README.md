# ASIC Lab 3: Logic Synthesis
<p align="center">
Prof. John Wawrzynek
</p>
<p align="center">
TA: Kevin He, Kevin Anderson
</p>
<p align="center">
Department of Electrical Engineering and Computer Science
</p>
<p align="center">
College of Engineering, University of California, Berkeley
</p>

## Table of contents
- [ASIC Lab 3: Logic Synthesis](#asic-lab-3-logic-synthesis)
  - [Table of contents](#table-of-contents)
  - [Overview](#overview)
  - [What is Synthesis?](#what-is-synthesis)
    - [Introduction to Static Timing Analysis](#introduction-to-static-timing-analysis)
  - [Synthesis Environment](#synthesis-environment)
    - [Interpreting the YAML files](#interpreting-the-yaml-files)
      - [Interpreting the YAML: *design.yml*](#interpreting-the-yaml-designyml)
      - [Interpreting the YAML: *sim-rtl.yml*](#interpreting-the-yaml-sim-rtlyml)
  - [Handshaking](#handshaking)
  - [The Example Design: GCD](#the-example-design-gcd)
  - [RTL-Simulation](#rtl-simulation)
  - [Synthesize An Example Design: GCD](#synthesize-an-example-design-gcd)
    - [Hammer and Genus Relationship](#hammer-and-genus-relationship)
    - [TCL?](#tcl)
    - [Reports](#reports)
  - [Post-Synthesis Simulation](#post-synthesis-simulation)
  - [Build A Parameterized Divider](#build-a-parameterized-divider)
    - [Write the Design](#write-the-design)
    - [Verify functionality with a RTL simulation](#verify-functionality-with-a-rtl-simulation)
    - [Synthesize Your Design](#synthesize-your-design)
  - [Questions](#questions)
    - [Question 1: Understanding the algorithm](#question-1-understanding-the-algorithm)
    - [Question 2: GCD Reports Questions](#question-2-gcd-reports-questions)
    - [Question 3: GCD Synthesis Questions](#question-3-gcd-synthesis-questions)
    - [Question 4: Delay Questions](#question-4-delay-questions)
    - [Question 5: Synthesized Divder](#question-5-synthesized-divder)
  - [Acknowledgement](#acknowledgement)


## Overview
**Setup:**
Pull lab3 from the staff skeleton:
```
cd /home/tmp/<your-eecs-username>
cd asic-labs-<github-username>
git pull skeleton main
git push -u origin main
```
Setup CAD tools environment:
```
source /home/ff/eecs151/asic/eecs151.bashrc
```
**Objective:** 
This lab will cover logic synthesis. You were briefly introduced to the concept in lab2, but were given all the output products and asked to analyze them. In this lab, you will complete synthesis yourself for a small design. The steps and skills learned in this design can be applied to larger more complex designs (i.e. accelerators, or full SoCs)

**Topics Covered**
- Logic Synthesis
- CAD Tools (emphasis on *Genus*)
- Hammer
- Skywater 130mm PDK
- Behavorial RTL Simulation

**Recommended Reading**
- [Verilog Primer](https://inst.eecs.berkeley.edu/~eecs151/fa21/files/verilog/Verilog_Primer_Slides.pdf)

<span style="color:red"> ***WARNING:*** **Under no circumstance should any third party information, manuals be copied from the instructional servers to personal devices. In addition, do not copy plugins from hammer that interact with third party tools to a personal device.**</span>


## What is Synthesis?

Synthesis is the transformation of register transfer level code (typically Verilog or VHDL) into a gate-level netlist.
Cadence Genus is the tool used to perform synthesis in this class.
The first step in this process is the compilation and elaboration of RTL [1].
From [IEEE Std 1800-2017](https://ieeexplore.ieee.org/document/8299595), **compilation** is the process of reading RTL and analyzing it for syntax and semantic errors.
**Elaboration** is the subsequent process of expanding instantiations and hierarchies, parsing parameter values, and establishing netlist connectivity.
Elaboration in Genus returns a generic netlist formed from generic gates.
**Generic** in this context means that the design is represented structurally in terms of gates such as `CDN_flop` and `CDN_mux2` and that these gates have no physical correlation to the gates provided in the standard cell library associated with a technology.


### Introduction to Static Timing Analysis

In the final part of this section, we introduce Static Timing Analysis (STA).
**STA** is the validation of timing performance through the analysis of timing arcs for violations.
Broadly, this involves identifying timing arcs, calculating propagation delays, and checking for setup and hold time violations.
In this section, basic delay considerations are discussed through the inspection of file fragments, and rudimentary timing analysis is introduced in accompanying exercises.

Now, two classes of delays, **cell delays** and **net delays**, are presented.
First, consider a fragment of the cell delay model for a simple inverter buffer (`A` is the input, `Y` is the output) taken from the [ASAP7](https://github.com/The-OpenROAD-Project/asap7) instructional PDK timing library.
Inspect the fragment starting from `pin(Y)`. Examining the `timing()` relation reveals a table detailing the `cell_rise` based on a template `delay_template_7x7_x1`.
That is to say, the **cell rise time** (delay through a cell) is given by a 2D-lookup of **input net transition** and cell **output capacitance**.
Additionally, observe that the `timing_sense` is defined as **positive unate**.
That is, the timing arc is defined from rising input to rising (or non-changing) output.
While it is impossible to describe the complete capabilities of timing libraries short of copying entire standards, readers should be able to perform inspection and analysis on such files as needed.

    lu_table_template (delay_template_7x7_x1) {
      variable_1 : input_net_transition;
      variable_2 : total_output_net_capacitance;
      index_1 ("5, 10, 20, 40, 80, 160, 320");
      index_2 ("0.72, 1.44, 2.88, 5.76, 11.52, 23.04, 46.08");
    }
    
    ....
      pin (Y) {
        direction : output;
        function : "A";
        power_down_function : "(!VDD) + (VSS)";
        related_ground_pin : VSS;
        related_power_pin : VDD;
        max_capacitance : 368.64;
        output_voltage : default_VDD_VSS_output;
        timing () {
          related_pin : "A";
          timing_sense : positive_unate;
          timing_type : combinational;
          cell_rise (delay_template_7x7_x1) {
            index_1 ("5, 10, 20, 40, 80, 160, 320");
            index_2 ("5.76, 11.52, 23.04, 46.08, 92.16, 184.32, 368.64");
            values ( \
              "16.3122, 18.9302, 23.4928, 31.8294, 47.9742, 80.0606, 144.088", \
              "17.7082, 20.3463, 24.858, 33.2468, 49.3778, 81.4822, 145.567", \
              "20.3545, 22.9433, 27.4932, 35.8118, 51.9385, 84.0089, 148.036", \
              "24.3952, 27.0398, 31.6149, 39.9636, 56.036, 88.0888, 152.111", \
              "29.3454, 32.0006, 36.6138, 45.0047, 61.1147, 93.221, 156.998", \
              "35.5151, 38.3592, 43.2204, 51.6798, 67.7266, 99.5716, 163.503", \
              "41.9998, 45.0837, 50.305, 59.1205, 75.1338, 107.432, 171.049" \
            );
          }

Now consider **wire delays**.
The following fragment is fabricated for instructional purposes as the Intel library does not use `wire_load` definitions for STA nor does Hammer currently have facilities to use the `QRC Techfile` for STA analysis in synthesis.
Despite being fictional, this model is in fact instructive.
Based on the enclosure area of a net, a `wire_load` macro model is chosen.
Multipliers from the macro model are used to scale resistance values (ohms) and capacitance values (fF) based on cell fanout.
Combining this information allows RC delays to be determined.
Because wireload modeling is statistically driven, use of such models often yields pessimistic results.
To improve results, some companies have replaced wireload models from the foundry with wireload models derived from their own designs and observed activities.

    wire_load(10X10) {
      resistance : 6.00 ;
      capacitance : 1.30 ;
      area : 0.08 ;
      slope : 0.05 ;
      fanout_length(1, 2.0000);
      fanout_length(2, 3.2000);
      fanout_length(3, 3.4000);
      fanout_length(4, 4.1000);
      fanout_length(5, 4.6000);
      fanout_length(6, 5.1000);
    }
    default_wire_load_mode : enclosed ;

With this new information, consider how timing analysis from EECS 151/251A may now be performed using real data.
Specifically, timing analysis was previously done largely with cell and wire delays provided as context in exercises.
Correlate the above inspections to the delays that were provided in previous course material, and understand that you can now derive those delays by looking at PDK documents.
Beyond this, there are a slew of other STA topics, including correlated clocks, jitter, insertion delays, etc., but these are ignored for now.


<a id="task-2-putting-it-all-together"></a>

## Synthesis Environment
To perform synthesis, we will be using Cadence Genus. However, we will not be interfacing with
Genus directly, we will rather use Hammer. Just like in lab 2, we have set up the basic Hammer
flow for your lab exercises using Makefile.

In this lab repository, you will see two sets of input files for Hammer:
1. Source code in the *skel* direction
2. YAML files used for Hammer inputs
   - *inst-env.yml* - Configures environment with paths to Cadence tools and their respective licenses
   - *sky130.yml* - Configures Hammer wide settings for design flow
   - *design.yml* - Settings for this particular design
   - *sim-rtl.yml* - Settings for simulating an RTL simulation this design
   - *sim-gl-syn.yml* - Settings for simulating a gate-level simulation this design

<!-- The first set of files are
the source codes for our design that you will explore in the next section. 
The second set of files are
some YAML files (`inst-env.yml`, `sky130.yml`, `design.yml`, `sim-rtl.yml`, `sim-gl-syn.yml`) that
configure the Hammer flow.  -->

<span style="color:red"> 
Of these YAML files, you should only need to modify <i>design.yml</i>, <i>sim-rtl.yml</i>, and <i>sim-gl-syn.yml</i> in order to configure the synthesis and simulation for your
design.
</span> 



<!-- Hammer is already setup at `/home/ff/eecs151/fa23/hammer` with all the required plugins for Cadence
Synthesis (Genus) and Place-and-Route (Innovus), Synopsys Simulator (VCS), Mentor Graphics
DRC and LVS (Calibre). You should not need to install it on your own home directory. **These
Hammer plugins are under NDA. They are provided to us for educational purpose.
They should never be copied outside of instructional machines under any circumstances or else we are at risk of losing access to these tools in the future!!!**

Let us take a look at some parts of `design.yml` file: -->

### Interpreting the YAML files

Let's examine the details of the *design.yml* file

<br />
When you synthesize a design, you tell the tools the expected clock frequency which you anticipate the design will be run at, or the *target frequency*. The line below creates the variable `CLK_PERIOD` to be used within the YAML file and assigns to it the target clock frequency for our design (20ns). 


```yaml
gcd.clockPeriod: &CLK_PERIOD "20ns"
```

<br />
The target clock frequency directly impacts the effort of the synthesis tools. Targetting higher clock frequencies will make the tool work harder and force it to use higher-power gates to meet the constraints. A lower target clock frequency allows the tool to focus on reducing area and/or power.


>**Note:** This sets the target frequency only for the synthesis tool. The define in sim-rtl.yml sets the frequency for simulation. It is generally useful to separate the two as
you might want to see how the circuit performs under different clock frequencies without changing
the design constraints.
>```yaml
>defines:
>  - "CLOCK_PERIOD=20.00"
>```
> &nbsp;


Next, we create the variable `VERILOG_SRC` for all the source files that contain the design.
```yaml
gcd.verilogSrc: &VERILOG_SRC
  - "src/gcd.v"
  - "src/gcd_datapath.v"
  - "src/gcd_control.v"
  - "src/EECS151.v"
```


>**Note:** Below is a snippet from `sim-rtl.yml` showing where we list the the input files for simulation. What's different between the two lists?
> ```yaml
> sim.inputs:
>   input_files:
>     - "src/gcd.v"
>     - "src/gcd_datapath.v"
>     - "src/gcd_control.v"
>     - "src/gcd_testbench.v"
>     - "src/EECS151.v"
> ```
> &nbsp;

This is where we specify to Hammer that we intend on using the `CLK_PERIOD` we defined earlier
as the constraint for our design. We will see more detailed constraints in later labs.

```yaml
vlsi.inputs.clocks: [
  {name: "clk", period: *CLK_PERIOD, uncertainty: "0.1ns"}
]
```



## Understanding the example design

We have provided a circuit described in Verilog that computes the greatest common divisor (GCD)
of two numbers. Unlike the FIR filter from the last lab, in which the testbench constantly provided
stimuli, the GCD algorithm takes a variable number of cycles, so the testbench needs to know when
the circuit is done to check the output. This is accomplished through a “ready/valid” handshake
protocol. This protocol shows up in many places in digital circuit design.
Look [here](https://inst.eecs.berkeley.edu/~eecs151/fa21/files/verilog/ready_valid_interface.pdf) at information on the course website for more background.
The GCD top level is shown in the figure below.

<p align="center">
<img src="figs/block-diagram.png" width="600" />
</p>

The GCD module declaration is as follows:

```v
module gcd#( parameter W = 16 )
(
  input clk, reset,
  input [W-1:0] operands_bits_A,    // Operand A
  input [W-1:0] operands_bits_B,    // Operand B
  input operands_val,               // Are operands valid?
  output operands_rdy,              // ready to take operands

  output [W-1:0] result_bits_data,  // GCD
  output result_val,                // Is the result valid?
  input result_rdy                  // ready to take the result
);
```

On the `operands` boundary, nothing will happen until GCD is ready to receive data (`operands_rdy`).
When this happens, the testbench will place data on the operands (`operands_bits_A` and `operands_bits_B`),
but GCD will not start until the testbench declares that these operands are valid (`operands_val`).
Then GCD will start.

The testbench needs to know that GCD is not done. This will be true as long as `result_val` is 0
(the results are not valid). Also, even if GCD is finished, it will hold the result until the testbench is
prepared to receive the data (`result_rdy`). The testbench will check the data when GCD declares
the results are valid by setting `result_val` to 1.

The contract is that if the interface declares it is ready while the other side declares it is valid, the
information must be transferred.

Open `src/gcd.v`. This is the top-level of GCD and just instantiates `gcd_control` and `gcd_datapath`.
Separating files into control and datapath is generally a good idea. Open `src/gcd_datapath.v`.
This file stores the operands, and contains the logic necessary to implement the algorithm (subtraction and comparison). Open `src/gcd_control.v`. This file contains a state machine that handles
the ready-valid interface and controls the mux selects in the datapath. Open `src/gcd_testbench.v`.
This file sends different operands to GCD, and checks to see if the correct GCD was found. Make
sure you understand how this file works. Note that the inputs are changed on the negative edge
of the clock. This will prevent hold time violations for gate-level simulation, because once a clock
tree has been added, the input flops will register data at a time later than the testbench’s rising
edge of the clock.

Now simulate the design by running `make sim-rtl`. The waveform is located under `build/sim-rundir/`.
Open the waveform in DVE (`dve -vpd vcdplus.vpd &`). You may need to scroll down in DVE to find the testbench and try
to understand how the code works by comparing the waveforms with the Verilog code. It might
help to sketch out a state machine diagram and draw the datapath.


## Synthesis

Synthesis is the process of converting your Verilog RTL description into technology (or platform, in the case of
FPGAs) specific gate-level Verilog. These gates are different from the “and”, “or”, “xor” etc. primitives in Verilog. While the logic primitives correspond to gate-level operations, they do not have
a physical representation outside of their symbol. A synthesized gate-level Verilog netlist only contains
cells with corresponding physical aspects: they have a transistor-level schematic with transistor
sizes provided, a physical layout containing information necessary for fabrication, timing libraries
providing performance specifications, etc. Some synthesis tools also output assign statements that
refer to pass-through interfaces, but no logic operation is performed in these assignments (not even
simple inversion!).


Open the Makefile to see the available targets that you can run. You don’t have to know all of
these for now. The Makefile provides shorthands to various Hammer commands for synthesis,
placement-and-routing, or simulation. Read [Hammer-Flow](https://hammer-vlsi.readthedocs.io/en/latest/Hammer-Flow/index.html) if you want to get more detail.

The first step is to have Hammer generate the necessary supplement Makefile (`build/hammer.d`). To do so, type the
following command in the lab directory:

    make buildfile

This generates a file with make targets specific to the constraints we have provided inside the YAML
files. If you have not run `make clean` after simulating, this file should already be generated. `make buildfile` also copies and extracts a tarball of the SKY130 PDK to your local workspace. It will
take a while to finish if you run this command first time. The extracted PDK is not deleted when
you do `make clean` to avoid unnecessarily rebuilding the PDK. To explicitly remove it, you need to
remove the build folder (and you should do it once you finish the lab to save your allocated disk
space since the PDK is huge). To synthesize the GCD, use the following command:

    make syn

This runs through all the steps of synthesis. 
By default, Hammer puts the generated objects under the directory build. Go to `build/syn-rundir/reports`. 
There are five text files here that contain very useful information about
the synthesized design that we just generated. Go through these files and familiarize yourself with
these reports. One report of particular note is `final_time_ss_100C_1v60.setup_view.rpt`. The
name of this file represents that it is a timing report, with the Process Voltage Temperature corner
of ss(slow-slow) corner, 1.60 V and 100 degrees C, and that it contains the setup timing checks. Another important file
is `build/syn-rundir/gcd.mapped.v`. This is your synthesized gate-level Verilog. Go through it
to see what the RTL design has become to represent it in terms of technology-specific gates. Try
to follow an input through these gates to see the path it takes until the output.
These files are useful for debugging and evaluating your design.

Now open the `final_time_ss_100C_1v60.setup_view.rpt` file and look at the first block of text
you see. It should look similar to this:

```text
Path 1: MET (5201 ps) Setup Check with Pin GCDdpath0/A_register/q_reg[15]/CLK->D
           View: ss_100C_1v60.setup_view
          Group: clk
     Startpoint: (R) GCDdpath0/B_register/q_reg[0]/CLK
          Clock: (R) clk
       Endpoint: (F) GCDdpath0/A_register/q_reg[15]/D
          Clock: (R) clk

                     Capture       Launch     
        Clock Edge:+   20000            0     
       Src Latency:+       0            0     
       Net Latency:+       0 (I)        0 (I) 
           Arrival:=   20000            0     
                                              
             Setup:-     286                  
       Uncertainty:-     100                  
     Required Time:=   19614                  
      Launch Clock:-       0                  
         Data Path:-   14413                  
             Slack:=    5201                  

#--------------------------------------------------------------------------------------------------------------------------------
#            Timing Point             Flags     Arc     Edge           Cell             Fanout Load Trans Delay Arrival Instance 
#                                                                                              (fF)  (ps)  (ps)   (ps)  Location 
#--------------------------------------------------------------------------------------------------------------------------------
  GCDdpath0/B_register/q_reg[0]/CLK   -       -         R     (arrival)                     16    -     0     0       0    (-,-) 
  GCDdpath0/B_register/q_reg[0]/Q     -       CLK->Q    R     sky130_fd_sc_hd__dfxtp_1       5 14.8   237   719     719    (-,-) 
  GCDdpath0/sub_45_24_g453__4319/Y    -       B->Y      F     sky130_fd_sc_hd__nand2_1       2  8.3   160   234     953    (-,-) 
  GCDdpath0/sub_45_24_g450__2398/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   171   878    1831    (-,-) 
  GCDdpath0/sub_45_24_g449__5477/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   171   882    2714    (-,-) 
  GCDdpath0/sub_45_24_g448__6417/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   171   882    3596    (-,-) 
  GCDdpath0/sub_45_24_g447__7410/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   170   882    4478    (-,-) 
  GCDdpath0/sub_45_24_g446__1666/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   171   882    5360    (-,-) 
  GCDdpath0/sub_45_24_g445__2346/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   171   882    6243    (-,-) 
  GCDdpath0/sub_45_24_g444__2883/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   171   882    7125    (-,-) 
  GCDdpath0/sub_45_24_g443__9945/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   170   882    8007    (-,-) 
  GCDdpath0/sub_45_24_g442__9315/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   170   882    8889    (-,-) 
  GCDdpath0/sub_45_24_g441__6161/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   170   882    9771    (-,-) 
  GCDdpath0/sub_45_24_g440__4733/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   171   882   10654    (-,-) 
  GCDdpath0/sub_45_24_g439__7482/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   170   882   11536    (-,-) 
  GCDdpath0/sub_45_24_g438__5115/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   170   882   12418    (-,-) 
  GCDdpath0/sub_45_24_g437__1881/COUT -       CIN->COUT F     sky130_fd_sc_hd__fa_1          1  5.7   170   882   13300    (-,-) 
  GCDdpath0/sub_45_24_g436__6131/Y    -       B->Y      F     sky130_fd_sc_hd__xnor2_1       1  3.5   110   258   13558    (-,-) 
  GCDdpath0/g1209__5477/Y             -       C1->Y     R     sky130_fd_sc_hd__a222oi_1      1  3.6   462   393   13951    (-,-) 
  GCDdpath0/g1201/Y                   -       A->Y      F     sky130_fd_sc_hd__inv_1         1  2.7   102   186   14137    (-,-) 
  GCDdpath0/A_register/g87__2883/Y    -       B_N->Y    F     sky130_fd_sc_hd__nor2b_1       1  2.9    66   276   14413    (-,-) 
  GCDdpath0/A_register/q_reg[15]/D    -       -         F     sky130_fd_sc_hd__dfxtp_1       1    -     -     0   14413    (-,-) 
#--------------------------------------------------------------------------------------------------------------------------------
```

This is one of the most common ways to assess the critical paths in your circuit. 
The setup timing report lists each timing path's **slack**, which is the extra delay the signal can have before a setup
violation occurs, in ascending order. The first block indicates the critical path of the design.
Each row represents a timing path from a gate to the next, and the whole block is the **timing
arc** between two flip-flops (or in some cases between latches). The `MET` at the top of the block
indicates that the timing requirements have been met and there is no violation. If there was, this
indicator would have read `VIOLATED`. Since our critical path meets the timing requirements with
a 5201 ps of slack, this means we can run this synthesized design with a period equal to clock period
(20000 ps) minus the critical path slack (5201 ps), which is 14799 ps.


---

### Synthesis: Step-by-step

Typically, we will be roughly following the above section’s flow, but it is also
useful to know what is going on underneath. In this section,
we will look at the steps Hammer takes to get from RTL Verilog to all the outputs we saw in the
last section.

First, type `make clean` to clean the environment of previous build’s files. Then, use `make buildfile`
to generate the supplementary Makefile as before. Now, we will modify the `make syn` command to
only run the steps we want. Go through the following commands in the given order:

    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step init_environment"

In this step, Hammer invokes Genus to read the technology libraries and the RTL Verilog files, as well as the constraints we
provided in the `design.yml` file.

    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step syn_generic"

This step is the **generic synthesis** step. In this step, Genus converts our RTL read
in the previous step into an intermediate format, made up of technology-independent generic gates. These
gates are purely for gate-level functional representation of the RTL we have coded, and are going
to be used as an input to the next step. This step also performs logical optimizations on our design
to eliminate any redundant/unused operations.

    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step syn_map"

This step is the **mapping** step. Genus takes its own generic gate-level output and converts it to
our SKY130-specific gates. This step further optimizes the design given the gates in our technology.
That being said, this step can also increase the number of gates from the previous step as not
all gates in the generic gate-level Verilog may be available for our use and they may need to be
constructed using several, simpler gates.

    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step add_tieoffs"

In some designs, the pins in certain cells are hardwired to 0 or 1, which requires a tie-off cell.

    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step write_regs"

This step is purely for the benefit of the designer. For some designs, we may need to have a list
of all the registers in our design. In this lab, the list of regs is used in post-synthesis simulation to
generate the `force_regs.ucli`, which sets initial states of registers.

    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step generate_reports"

The reports we have seen in the previous section are generated during this step.

    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step write_outputs"

This step writes the outputs of the synthesis flow. This includes the gate-level `.v` file we looked at
earlier in the lab. Other outputs include the design constraints (such as clock frequencies, output
loads etc., in `.sdc` format) and delays between cells (in `.sdf` format).

## Post-Synthesis Simulation
From the root folder, type the following commands:

    make sim-gl-syn
    
This will run a post-synthesis simulation using annotated delays from the `gcd.mapped.sdf` file.

---

### Checkoff 1: Synthesis Understanding 
Demonstrate that your synthesis flow works correctly, and be prepared to explain the synthesis steps at a high level.
1. What are the sub-steps elaboration and syn_design?
2. Where do the cells for synthesis come from?
3. Describe the process of logic synthesis at a high level?
4. What is output of synthesis?


## Build Your Divider

In this section, you will build a parameterized divider of unsigned integers. Some initial code has
been provided to help you get started. To keep the control logic simple, the divider module uses an input
signal `start` to begin the computation at the next clock cycle, and asserts an output signal `done` to
HIGH when the division result is valid. The input `dividend` and `divisor` should be registered
when `start` is HIGH. You are not required to handle corner cases such as dividing by 0. You are
free to modify the skeleton code to implement a ready/valid interface instead, but it is not required.

It is suggested that you implement the divide algorithm described [here](http://bwrcs.eecs.berkeley.edu/Classes/icdesign/ee141_s04/Project/Divider%20Background.pdf). Use the **Divide Algorithm Version 2** (slide 9).
A simple testbench skeleton is also provided to you. You should change it to add more test vectors,
or test your divider with different bitwidths. You need to change the file `sim-rtl.yml` to use your
divider instead of the GCD module when testing.


## Questions


### Question 1: Understanding the algorithm

Hint: Look up Euclidean Algorithm for calculating GCD if you're stucked :)

By reading the provided Verilog code and/or viewing the RTL level simulations, demonstrate that
you understand the provided code:

1. Draw a table with 5 columns (cycle number, value of A_reg, value of B_reg, A_next, B_next) and fill in all of the rows for the first test vector (GCD of 27 and 15). Count the cycle number from 0 when `operands_rdy` and `operands_val` are 1. Fill in the table until the first test vector is done and upload a screenshot of the table. Use decminal number instead of binary or hex. Hint: It might be easier to view the waveforms instead of tracing the code. Hint: take a look starting at 140ns.

    | Cycle number | A_reg | B_reg | A_next | B_next |
    |:-------:|:-------:|:-------:|:-------:|:-------:|
    | 0 | 0 | 0 | 27 | 15 |
    | 1 |  |  |  |  |
    | 2 |  |  |  |  |
    | 3 |  |  |  |  |
    | ... |  |  |  |  |

2. In `src/gcd_testbench.v`, the inputs are changed on the negative edge of the clock to prevent hold time violations. Is the output checked on the positive edge of the clock or the negative edge of the clock? Why?

3. In `src/gcd_testbench.v`, what will happen if you change `result_rdy = 1;` to `result_rdy = 0;`? What state will the `gcd_control.v` state machine be in?

<!-- ### Question 2: Testbenches
a) Modify `src/gcd_testbench.v` so that intermediate steps are displayed in the format below.
Copy and paste the code you wrote/revised in your report (Also explain where in `src/gcd_testbench.v` you added).
Copy and paste the display result of 20~29 cycle count.


```shell
 0: [ ...... ] Test ( x ), [ x == x ]  (decimal)
 1: [ ...... ] Test ( x ), [ x == x ]  (decimal)
 2: [ ...... ] Test ( x ), [ x == 0 ]  (decimal)
 3: [ ...... ] Test ( x ), [ x == 0 ]  (decimal)
 4: [ ...... ] Test ( x ), [ x == 0 ]  (decimal)
 5: [ ...... ] Test ( x ), [ x == 0 ]  (decimal)
 6: [ ...... ] Test ( 0 ), [ 3 == 0 ]  (decimal)
 7: [ ...... ] Test ( 0 ), [ 3 == 0 ]  (decimal)
 8: [ ...... ] Test ( 0 ), [ 3 == 27 ] (decimal)
 9: [ ...... ] Test ( 0 ), [ 3 == 12 ] (decimal)
10: [ ...... ] Test ( 0 ), [ 3 == 15 ] (decimal)
11: [ ...... ] Test ( 0 ), [ 3 == 3 ]  (decimal)
12: [ ...... ] Test ( 0 ), [ 3 == 12 ] (decimal)
13: [ ...... ] Test ( 0 ), [ 3 == 9 ]  (decimal)
14: [ ...... ] Test ( 0 ), [ 3 == 6 ]  (decimal)
15: [ ...... ] Test ( 0 ), [ 3 == 3 ]  (decimal)
16: [ ...... ] Test ( 0 ), [ 3 == 0 ]  (decimal)
17: [ ...... ] Test ( 0 ), [ 3 == 3 ]  (decimal)
18: [ passed ] Test ( 0 ), [ 3 == 3 ]  (decimal)
19: [ ...... ] Test ( 1 ), [ 7 == 3 ]  (decimal)
``` -->


### Question 2: Reporting Questions
1. Which report would you look at to find the total number of each different standard cell that the design contains?
2. Which report contains area breakdown by modules in the design?

3. What is the cell used for `A_register/q_reg[7]`? How much leakage power does `A_register/q_reg[7]` contribute? How did you find this?

### Question 3: Synthesis Questions
1. Looking at the total number of instances of sequential cells synthesized and the number of `reg` definitions in the Verilog files, are they consistent? If not, why?

2. Reduce the clock period by the amount of slack in the timing report. Does it still meet timing? Why or why not? Does the critical path stay the same? If not, what changed?

 <!-- Modify the clock period (with a resolution of 1ns) in the `design.yml` file to make the design go faster. What is the highest clock frequency (in terms of MHz) this design can operate at in this technology? (only write the numeric value. Assume the unit is in MHz)** -->

### Question 4: Delay Questions
Check the waveforms in DVE. 
```
cd build/sim-rundir
dve -vpd vcdplus.vpd &
```

1. Report the clk-q delay of `state[0]` in `GCDctrl0` at 350 ns and submit a screenshot of the waveforms showing how you found this delay.

2. Which line in the sdf file specifies this delay and what is the delay?

3. Is the delay from the waveform the same as from the sdf file? Why or why not?

### Question 5: Synthesize your divider
1. Push your 4-bit divider design through the synthesis tool, and determine its critical path, cell area, and maximum operating frequency from the reports. You might need to re-run synthesis multiple times to determine the maximum achievable frequency(with a period resolution of 100ps).

2. Change the bitwidth of your divider to 32-bit, what is the 
   - critical path
   - area
   - maximum operating frequency(with a period resolution of 100ps) now?

3. Submit your divider code and testbench to the report. Also, `git push` all your work to github repository. Add comments to explain your testbench and why it provides sufficient coverage for your divider module. (You don't have to run post-synthesis simulation for Question 5). That is, run `make sim-rtl` to verify your testbench).


## Acknowledgement

This lab is the result of the work of many EECS151/251 GSIs over the years including:
Written By:
- Nathan Narevsky (2014, 2017)
- Brian Zimmer (2014)

Modified By:
- John Wright (2015,2016)
- Ali Moin (2018)
- Arya Reais-Parsi (2019)
- Cem Yalcin (2019)
- Tan Nguyen (2020)
- Harrison Liew (2020)
- Sean Huang (2021)
- Daniel Grubb, Nayiri Krzysztofowicz, Zhaokai Liu (2021)
- Dima Nikiforov (2022)
- Roger Hsiao, Hansung Kim (2022)
- Chengyi Lux Zhang, (2023)
- Kevin Anderson, Kevin He (Sp2024)

<!-- 
## WASTE
Hammer abstracts some details of the synthesis process. Let's examine step-by-step what each step Hammer takes does to gain an intuition of what steps Genus performs:

1. In the *skel* directory, run the following command.
```
make buildfile
```
This generates another Makefile, *hammer.d* in the *build* subdirectory, specific to the GCD design with unique targets. We use some of these targets to run individual synthesis steps in the following commands.


2. Next, we need to provide Genus with the technology libraries from the PDK, constraints for the synthesis process (from *design.yml*), and the source code for our design. Lastly, and critically, the step always commands *Genus* to elaborate our design.
```
make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step init_environment"
```

3. This step is the **generic synthesis** step. In this step, Genus converts our RTL read
in the previous step into an intermediate format, made up of technology-independent generic gates. These
gates are purely for gate-level functional representation of the RTL we have coded, and are going
to be used as an input to the next step. This step also performs logical optimizations on our design
to eliminate any redundant/unused operations.
```
    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step syn_generic"
```

4. This step is the **mapping** step. Genus takes its own generic gate-level output and converts it to
our SKY130-specific gates. This step further optimizes the design given the gates in our technology.
That being said, this step can also increase the number of gates from the previous step as not
all gates in the generic gate-level Verilog may be available for our use and they may need to be
constructed using several, simpler gates.
```
    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step syn_map"
```

5. In some designs, the pins in certain cells are hardwired to 0 or 1, which requires a tie-off cell. This step adds these cells.
```
    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step add_tieoffs"
```

6.  This step is purely for the benefit of the designer. For some designs, we may need to have a list
of all the registers in our design. In this lab, the list of regs is used in post-synthesis simulation to
generate the `force_regs.ucli`, which sets initial states of registers.
```
    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step write_regs"
```


7. The reports we have seen in the previous section are generated during this step.
```
    make redo-syn HAMMER_EXTRA_ARGS="--stop_after_step generate_reports"
``` -->
