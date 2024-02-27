# ASIC Lab 6: Macros (SRAM Integration)
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



## Overview

**Setup:**
Pull lab6 from the staff skeleton:
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
In this lab, we will cover how to integrate blocks beyond standard cells in VLSI designs with an example desing.

1. Implement a dot product module
2. PAR design with SRAM macros


**Topics Covered**
- Place and Route 
- Metal Layers
- Standard Cell
- CAD Tools (emphasis on *Innovus*)
- Hammer
- Skywater 130mm PDK
- Reading Reports

**Recommended Reading**
- [Verilog Primer](https://inst.eecs.berkeley.edu/~eecs151/fa21/files/verilog/Verilog_Primer_Slides.pdf)
- [Hammer-Flow](https://hammer-vlsi.readthedocs.io/en/latest/Hammer-Flow/index.html)
- [Ready-Valid Interface](https://inst.eecs.berkeley.edu/~eecs151/fa21/files/verilog/ready_valid_interface.pdf)

<span style="color:red"> ***WARNING:*** **Under no circumstance should any third party information, manuals be copied from the instructional servers to personal devices. In addition, do not copy plugins from hammer that interact with third party tools to a personal device.**</span>


# Background
Designs include black-boxed circuits called *macros*. Macros are custom, pre-builted logically circuit that have already gone through synthesis and PAR, and are to be integrated directly into your design. The most common custom block is SRAM, which is a dense addressable memory block used in most VLSI designs.
You will learn about SRAM in more detail later in the lectures,
but the [Wikipedia article on SRAM](https://en.wikipedia.org/wiki/Static_random-access_memory)
provides a good starting point.
SRAM is treated as a hard macro block in VLSI flow.
It is created separately from the standard cell libraries.
The process for adding other custom, analog, or mixed signal circuits will be similar to what we use for SRAMs.
In your project, you will use the SRAMs extensively for caching.
It is important to know how to design a digital circuit and run a CAD flow with these hard macro blocks.
The lab exercises will help you get familiar with SRAM interfacing.
We will use an example design of computing a dot product of two vectors to walk you through how to use the SRAM blocks.

<!-- ************************************** -->
<!-- MACROS -->
<!-- ************************************** -->

## Macros

A macro is a predefined, custom logic block that is intellectual property (IP) from third parties. Examples of macros include: SRAMs, PLLs, or SerDes. Macros are integrated into a design to provide some (typically complex) capability. For example, SRAMs are optimized high density blocks for storage (e.x. register file). Macros are categorized by two flavors:

<ul>
  <li> <i>Soft Macros</i> - configurable, synthesizable, RTL logic blocks which are technology independent (portable between technology nodes). They are directly integrated into the RTL design, then synthesized and place and routed together.

  <li> <i>Hard Macros</i> - fixed (not configurable), technology dependent highly optimized blocks provide by a foundry or IP manufacturing company which are already synthesized and run through place and route. Hard macros are essentially black boxes exposing only pins to the external design. Analog blocks are delivered as hard macros.
</ul>


### Support Files for Macros

Hard macros are delivered a GDS and/or a collection of specific files containing information necessary to integrate them into a design. These files are collateral from the design flow (synthesis and PAR) of the individual macros itself. 

#### Graphical Database System (*.gds)
[GDS](https://www.artwork.com/gdsii/gdsii/) files encode the entire detailed layout of macro. This file is an output product of PAR. A macro's GDS layouts are merged with the PAR’d layout to integrate the PAR'd layout of the rest of the design before running DRC, LVS, and sending the design off to the fabrication house.

#### Liberty Timing Files (*.lib)
[Liberty](http://web.engr.uky.edu/~elias/lectures/LibertyFileIntroduction.pdf) files
must be generated for macros at every relevant process, voltage, and temperature (PVT) corner
that you are using for setup and hold timing analysis.
Detailed models contain descriptions of what each pin does,
the delays depending on the load given in tables, and power information.
There are also 3 types of Liberty files:
[CCS, ECSM, and NLDM](https://chitlesh.ch/wordpress/liberty-ccs-ecsm-or-ndlm/),
which tradeoff accuracy with tool runtime.

#### Library Exchange Format (*.lef)
[LEF](http://web.engr.uky.edu/~elias/lectures/LibertyFileIntroduction.pdf) files
must be generated for macros in order to denote where pins are located and encode
any obstructions (places where the PAR tool cannot place other cells or routing).
Incorrect or inaccurate LEFs can often confuse PAR tools, making them produce
layouts with many errors.

#### Data Exchange Format (*.def)
[DEF](https://signoffsemiconductors.com/lef-def-lib/) files specify the exact placement information for all aspects of a physical layout. Common aspects listed in a DEF is the die area, IO placement, blockages, and nets.


> **Note:** Let it be known these file type aren't only for macros. In fact, other aspects of a design can be represented using these files. For example, routing for a specific metal layer can be represented in a DEF file.

## Example: SRAM

In this lab, an SRAM is a design component. Let's look at it to understand how a hard macro is integrated into a digital design.

The Sky130 PDK does not come with SRAMs by default, so some of your TAs wrote an SRAM generator called [SRAM22](https://github.com/rahulk29/sram22) to programatically generate SRAMs of varying dimensions. These SRAMs are synchronous-write and synchronous-read; the read data is only available at the next rising edge, and the write data is only written at the next rising edge. Hard macros are instantiated by *Innovus* as black boxes that are connected to the rest of the circuit as specified in your Verilog. For Synthesis and PAR, the SRAMs must be abstracted away from the tools, because the only things that the flow is concerned about at these stages are the timing characteristics and the outer layout geometry of the SRAM macros. For simulation purposes, Verilog behavioral models for the SRAMs from the HAMMER repository are used.


Below is in the instantiation of the SRAM from *src/dot_product.v*. This is the SRAM you will use for your design.

```v
sram22_64x32m4w8 sram (
  .clk(clk),
  .we(we),
  .wmask(wmask),
  .addr(addr),
  .din(din),
  .dout(dout)
);
```
The specifications for the SRAM are contained in the name: *sram22_64x32m4w8* (the *"64x32"* specifies the SRAM is 64 entries deep and each entry is 32-bits wide). This is a single-port read/write SRAM block which is often written as 1RW SRAM. It is single port because there is a single port to specify the read/write address, therefore a single address is either written to and read from in a single cycle. This means there is a 6-bit address for selecting one 32-bit entry. To write to the SRAM, we must set the write enable (`we`) signal high. The write mask port (`wmask`) allows us to select which bytes we want to write. For example, if we want to write to bits `31:24` and `7:0`, we would set `wmask = 4'b1001`.


### How Hammer Generates SRAMs with SRAM22 
In order to generate the database that Innovus will use, type the following command:
```shell
make srams
```

This make target create a technology cache directory includes models for various types of SRAMs: *build/tech-sky130-cache*. In this directory, you will find Verilog behavioral models for the SRAMs to be used during simulation. The technology cache directory includes models for various types of SRAMs.
Peruse the directory to see the dimensions of SRAMs available to you. The SRAMs that we have in this process only support single-port memories, but in other processes, you may be able to use SRAMs with different numbers of ports. **For the final project, you will need to select the appropriate SRAMs to use in your design.** The SRAM Verilog models are only intended for simulation. **Do not include these files in your project configuration for Synthesis or PAR**, or else you will produce incorrect post-synthesis or post-PAR netlists.

<!-- ************************************** -->
<!-- DOT PRODUCT -->
<!-- ************************************** -->

# Dot product

We will now implement a module that computes the dot product of two vectors. Look at the ports declared in `src/dot_product.v`.
In particular, note that:

- It has input and output ready-valid interfaces
- The module expects to be fed two input vectors (`a` and `b`) element-by-element
- The `len` input indicates vector length. Vectors can be a maximum of 32 elements long 
- Elements from either vector can be fed concurrently
- All elements from both vectors should be stored in the SRAM prior to computation
- The SRAM is logically partitioned for each vector with vector `a` stored in the top half of the address range, and vector `b` stored in the bottom half of the address range. In other words, given that the vector index is zero-indexed, the i<sup>th</sup> entry of `a` should be stored at address `i` in the SRAM; the i<sup>th</sup> entry of `b` should be stored at address `32+i` in the SRAM. 
- You should compute the dot product and provide it on the output ready-valid interface.

Note that the SRAM can only perform one operation per cycle. So if both `a` and `b` have data ready to be written, you would need to write `a` to the SRAM in one cycle, then write `b` the next cycle (or vice versa).

You should create a 3 state FSM to orchestrate the dot product: 
- `DONE`: the idle state; your module should sit idle until the dot product result is read.
- `READ`: the FSM will accept inputs from `a` and `b` and store them in the SRAM.
- `CALC` state, your FSM should calculate the dot product.


**Your dot product should spend `2*len` cycles in the CALC state.
You should not instantiate more than 1 SRAM.**

To run RTL simulation, run the following command:

```shell
make sim-rtl
```

Ensure all tests pass. To inspect the RTL simulation waveform, run the following commands:

```shell
cd build/sim-rundir
dve -vpd vcdplus.vpd
```
<!-- ************************************** -->
<!-- PLACE AND ROUTE -->
<!-- ************************************** -->
# Place and route (PAR)

We will now run PAR on your design:

```shell
make par
```

This command will run synthesis as well, if it has not been run already
(however, make sure to re-run synthesis if you update your `design.yml` file).
After PAR finishes, you can open the floorplan of the design by running:

```shell
cd build/par-rundir
./generated-scripts/open_chip
```

This will launch Cadence *Innovus* GUI and load your final design database.
This floorplan has one SRAM instance called `sram`.
The placement constraints for that SRAM were given in the file `design.yml`.
You can look at `build/par-rundir/floorplan.tcl`
to see how HAMMER translated these constraints into Innovus floorplanning commands.
Note that you should:

- Always generate a placement constraint for hard macros like SRAMs, because Innovus is not able to auto-place them in a valid location most of the time.
- Ensure that the hierarchical path to the macro instance is specified correctly, otherwise Innovus will not know what to place.
- Pre-calculate valid locations for the macros. This will involve:
  - Looking at the LEF file to find out its width and height 
  (e.g. 279.45um × 269.21um for `sram22_64x32m4w8`) <!---tech-->
  to make sure it fits within the core boundary/desired area.
  - Legalizing the x and y coordinates.
    These generally need to be a multiple of a technology grid to avoid layout rule violations.
    The most conservative rule of thumb is a multiple of the site height (height of a standard cell row, which is 2.72um in this technology).
  - Ensuring that the macros receive power. You can see that the SRAMs in the picture above are placed beneath the met4 power straps. This is because the SRAM’s power pins are on met3.


You can play around with those constraints to change the SRAM placement to a geometry you like.
If you change the placement constraint only in `design.yml` and only want to redo PAR (skipping
synthesis), you can run:

```shell
make redo-par HAMMER_EXTRA_ARGS='-p build/sram_generator-output.json -p design.yml'
```

Finally, we will perform post-PAR gate-level simulation and power estimation.

```shell
make sim-gl-par
make power-par
```

Theoretically, if you don’t have any setup/hold time violations, your post-PAR gate-level simulation should pass.
However, when are you pushing the timing constraints, the gate-level simulation may not pass.




# Questions

## Question 1: Understanding SRAMs
For this question, you may find it convenient to reference
the [`sram22_sky130_macros`](https://github.com/rahulk29/sram22_sky130_macros)
repository, which stores all the SRAM variants that are directly supported in our tool flow.

a) Open the `build/` directory.
If you do not see this directory, make sure you ran `make srams`.
How many SRAM sizes are available?
Pick one size and describe what each number in the name of the macro means.
The [SRAM22](https://github.com/rahulk29/sram22) documentation may be helpful.

b) Look at one of the SRAM Verilog model (*.v) files.
Based on the model, what happens to the `dout` port when a write operation is performed?
Note that other SRAM designs may have different behavior.

c) Open one of the SRAM layout (`*.gds`) or abstract (`*.lef`) files.
Where are the pins located? Which layer are they on?
What layer are the power straps on?

You can open LEFs in the Innovus GUI.
If you want to see the full layout, you can use Calibre DRV
on the instructional machines, or install [KLayout](https://www.klayout.de/) locally.
If you choose to install KLayout, you'll also need to set up the SKY130 layermap
by following the instructions [here](https://github.com/laurentc2/SKY130_for_KLayout).

d) (Ungraded thought experiment #1) SRAM libraries in real process technologies are much larger than the list you see in the build directory.
What features do you think are important for real SRAM libraries?
Think in terms of number of ports, masking, improving yield, or anything else you can think of.
What would these features do to the size of the SRAM macros?

e) (Ungraded thought experiment #2) SRAMs should be integrated very densely in a circuit’s layout.
To build large SRAM arrays, often times many SRAM macros are tiled together, abutted on one or more sides.
Knowing this, take a guess at how SRAMs are laid out.

i) In Sky130, there are only 5 metal layers, but realistically only 4 layers to route on in order to leave the top layer for power distribution, as you saw in Lab 4.* <!---tech-->
*How many layers should a well-designed SRAM macro use (i.e. block off from PAR routing), at maximum?

ii) Where should the pins on SRAMs be located, if you want to maximize the ability for them to abut together?


## Question 2: Performance and area optimization
a) Find the maximum clock frequency that gives no timing violations for your design,
to the nearest 0.2ns.
Report the final frequency and describe (in English) the critical path.
Submit output from running `make sim-gl-par` showing that you pass all tests
using your post-PAR design.
Note that you'll need to update the `CLOCK_PERIOD` in `sim-gl-par.yml`
to match the frequency at which you ran synthesis/PAR.

b) The floorplan we've given you has lots of empty space.
Adjust the SRAM position and design area bounds to reduce
the overall area of your design to the nearest 100um.
Report the final area used, and submit a screenshot of your post-PAR layout.

c) How many cycles does your dot product module take for each of the test cases?
Describe two ways to reduce the total cycle count.
You don't need to implement these changes.
You are free to make reasonable modifications to the structure of the problem
(e.g. you can change the inputs to be something other than ready/valid interfaces).

d) Open your final design's floorplan.
Identify one or more locations where the SRAM is connected to power and ground,
and submit a screenshot in your report.


# Acknowledgement

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
