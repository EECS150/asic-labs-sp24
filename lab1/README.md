<h1 style="text-align: center;">
ASIC Lab 1: Setup and Getting Around the Compute Environment
</h1>
<p align="center">
Prof. John Wawrzynek
</p>
<p align="center">
TAs: (ordered by section) Kevin He, Kevin Anderson
</p>
<p align="center">
Department of Electrical Engineering and Computer Science
</p>
<p align="center">
College of Engineering, University of California, Berkeley
</p>



## Table of contents
- [Table of contents](#table-of-contents)
- [Overview](#overview)
  - [Submission](#submission)
- [Setup](#setup)
- [Regular Expressions  ](#regular-expressions--)
- [File Permissions ](#file-permissions-)
- [Makefiles ](#makefiles-)
- [Diffing Files ](#diffing-files-)
- [Git ](#git-)
- [Conclusion ](#conclusion-)
  - [Customization](#customization)
- [Lab Deliverables  ](#lab-deliverables--)
  - [Questions](#questions)
    - [Question 1: Setup](#question-1-setup)
    - [Question 2: Common terminal tasks](#question-2-common-terminal-tasks)
    - [Question 3: Fun with Regular Expressions](#question-3-fun-with-regular-expressions)
    - [Question 4: Understanding File Permissions](#question-4-understanding-file-permissions)
    - [Question 5: Makefile Targets](#question-5-makefile-targets)
    - [Question 6: Checking Git Understanding](#question-6-checking-git-understanding)
- [Appendix](#appendix)
  - [Cheatsheets](#cheatsheets)
- [Acknowledgement](#acknowledgement)


<!-- 1. [Overview](#Overview) 
2. [Setup](#paragraph1)
3. [Regular Expressions](#paragraph2)
4. [File Permissions](#paragraph3)
5. [Makefiles](#paragraph4) 
6. [Diffing Files](#paragraph5)
7. [Git](#paragraph6)
8. [Conclusion](#paragraph7)
9. [Lab Deliverables](#paragraph8) -->

## Overview

In course labs you will be introduced to Very-Large Scale Integration (VLSI) design.
The process of VLSI design is different than developing software, designing analog circuits, and even FPGA-based design. Instead of using a single graphical user interface (GUI) or environment (eg. Eclipse, Cadence Virtuoso, or Xilinx Vivado), VLSI design is done using dozens of command line interface tools on a Linux machine.  These tools primarily use text files as their inputs and outputs, and include GUIs mainly for only visualization, rather than design.  Therefore, familiarity with Linux, text manipulation, and scripting is required to successfully complete the labs this semester.

**Objective:** 
The goal of this lab is to introduce some basic techniques needed to use the computer aided design (CAD) tools that are taught in this class. Mastering the topics in this lab will help you save hours of time in later labs and make you a much more efficient chip designer.

- Setup Instructional Account
- Successfully remote into lab machines
- Install X2Go
- Building familarity with Git
- Learn Linux Basics


<!-- ### Tools:
- Cadence Genus
- Cadence Innovus -->

### Submission
1.  Solutions for lab [questions](#paragraph8) will be submitted electronically using **Gradescope**. 
2. In person check-off by lab TA (can be done anytime before next lab)

## Setup

The first step for this lab is to setup your environment. ***If you have not performed the steps in the [Setup](./README.md) section of the README.md for the repo, please go follow those instructions to get setup.*** Afterward, please [Clone this Repo](./README.md).


## Regular Expressions  <a name="paragraph2"></a>

Regular expressions allow you to perform complex ’Search’ or ’Search and Replace’ operations. 

> **TASK:** Please work through this  [tutorial](http://regexone.com).

Regular expressions can be used from many different programs: Vim, Emacs, `grep`, `sed`, Python, etc. From the command line, use `grep` to search, and `sed` to search and replace. Unfortunately, deciding what characters needs to be escaped can be somewhat confusing. For example, to find all instances of `dcdc_unit_cell_x`, where `x` is a single digit number, using grep:

```shell
grep "unit_cell_[0-9]\{1\}\." force_regs.ucli
```

And you can do the same search in Vim:

```vim
vim force_regs.ucli
/unit_cell_[0-9]\{1\}\.
```

Notice how you need to be careful what characters get escaped (the `[` is not escaped but `{` is). Now
imagine we want to add a leading 0 to all of the single digit numbers. The match string in `sed` could be:

```shell
sed -e 's/\(unit_cell_\)\([0-9]\{1\}\.\)/\10\2/' force_regs.ucli
```

Both `sed`, vim, and `grep` use ”Basic Regular Expressions” by default. For regular expressions heavy with special characters, sometimes it makes more sense to assume most characters except `a-zA-Z0-9` have special meanings (and they get escaped with only to match them literally). This is called ”Extended Regular Expressions”, and `?+{}()` no longer need to be escaped. A great resource for learning more is [Wikipedia](http://en.wikipedia.org/wiki/Regular_expression#POSIX_basic_and_extended). 

In Vim, you can do this with `\v`:

```shell
:%s/\v(unit_cell_)([0-9]{1}\.)/\10\2/
```

And in sed, you can use the -r flag:

```shell
sed -r -e 's/(unit_cell_)([0-9]{1}\.)/\10\2/' force_regs.ucli
```

And in grep, you can use the -E flag:

```shell
grep -E "unit_cell_[0-9]{1}\." force_regs.ucli
```

`sed` and grep can be used for many purposes beyond text search and replace. For example, to find all files in the current directory with filenames that contain a specific text string:

```shell
find . | grep ".ucli"
```

Or to delete all lines in a file that contain a string:

```shell
sed -e '/reset/d' force_regs.ucli
```

You may notice that the `sed` commands above do not alter the content of the file and just dumps everything to the terminal.  You can pass `-i` flag to `sed` to edit the file in-place, but this is error-prone because you don't get to check if there were any mistake in your regex before the original content is lost!

So when working with `sed`, using [Bash redirections] to save the output into a separate file is a good idea:

```shell
sed -e 's/\(unit_cell_\)\([0-9]\{1\}\.\)/\10\2/' force_regs.ucli > force_regs.ucli.zeropadded
```

Manpages are helpful resources to learn more about what different flags of the commands do:

```shell
man sed
/-r
```

[Bash redirections]: https://www.gnu.org/software/bash/manual/html_node/Redirections.html

## File Permissions <a name="paragraph3"></a>

A tutorial about file permissions can be found [here](http://www.tutorialspoint.com/unix/unix-file-permission.htm) and answer the [question 4](#Questions).

## Makefiles <a name="paragraph4"></a>

Makefiles are a simple way to string together a bunch of different shell tasks in an intelligent manner. This allows someone to automate tasks and save time when doing repetitive tasks since make targets allow for only files that have changed to need to be updated. The official documentation on make can be found [here](http://www.gnu.org/software/make/manual/make.html).

> **TASK (optional):** Please read through this [tutorial](http://www.cs.colby.edu/maxwell/courses/tutorials/maketutor/) . 

Let’s look at a simple makefile to explain a few things about how they work - this is not meant to be anything more than a very brief overview of what a makefile is and how it works. If you look at the Makefile in the provided folder in your favorite text editor, you can see the following lines:

```shell
output_name = force_regs.random.ucli

$(output_name): force_regs.ucli
    awk 'BEGIN{srand();}{if ($$1 != "") { print $$1,$$2,$$3,int(rand()*2)}}' $< > $@

clean:
    rm -f $(output_name)
```

While this may look like a lot of random characters, let us walk through each part of it to see that it really is not that complicated.

Makefiles are generally composed of rules, which tell Make how to execute a set of commands to build a set of targets from a set of dependencies. A rule typically has this structure:

```shell
targets: dependencies
    commands
```

**It is very important that indentation in Makefiles are tabs, not spaces.**
The two rules in the above Makefile have targets which are clean and output name. Here, output name is the name of a variable within the Makefile, which means that it can be overwritten from the command line. This can be done with the following command:

```shell
make output_name=foo.txt
```

This will result in the output being written to `foo.txt` intstead of `force_regs.random.ucli`.

Generally, a rule will run everytime that its dependencies have been updated more recently than its own targets, so by editing/updating the `force_regs.ucli` file (including via the touch command), you can regenerate the output name target. This is different than a bash script, as you can see in `runalways.sh`, which will always generate `force_regs.random.ucli` regardless of whether `force_regs.ucli` is updated or not.

Inside the output name target, the `awk` command has a bunch of \$ characters. This is because in normal `awk` the variable names are `$1`, `$2`, and then in the makefile you have to escape those variable names to get them to work properly. In Make, the character to do that is `$`.

The other characters after the awk script are also special characters to make. The `$<` is the first dependency of that target, the `>` simply redirects the output of awk, and the `$@` is the name of the target itself. This allows users to create makefiles that can be reusable, since you are operating on a dependency and outputting the result into the name of your own target.

## Diffing Files <a name="paragraph5"></a>

Comparing text files is another useful skill. The tools generally behave as black boxes, so comparing output files to prior output files is an important debugging technique. From the command lines, you can use `diff` to compare files:

```shell
diff force_regs.ucli force_regs.random.ucli
```

You can also compare the contents of directories (the `-q` flag will summarize the results to only show the names of the files that differ, and the `-r` flag will recurse through subdirectories). For Vim users, there is a useful built-in `diff` tool:

```shell
vimdiff force_regs.ucli force_regs.random.ucli
```

## Git <a name="paragraph6"></a>

Build your familiarity with Git by answering [question 6](#paragraph8)

## Conclusion <a name="paragraph7"></a>

### Customization

Many of the commands and tools you will use on a daily basis can be customized. This can dramatically improve your productivity. Some tools (e.g. vim and bash) are customized using “dotfiles,” which are hidden files in your home directory (e.g. `.bashrc` and `.vimrc`) that contain a series of commands which set variables, create aliases, or change settings. Try adding the following lines to your `.bashrc` and restart your session or source `~/.bashrc`. Now when you change directories, you no longer need to type `ls` to show the directory contents.

```shell
function cd {
    builtin cd "$@" && ls -F
}
```

The following links are useful for learning how to make some common customizations. You can read these but are not required to turn in anything for this section.
* [Bash aliases and functions](https://www.digitalocean.com/community/tutorials/an-introduction-to-useful-bash-aliases-and-functions)
* [Vim](http://statico.github.io/vim.html)


## Lab Deliverables  <a name="paragraph8"></a>

### Questions

Submit your answers to the lab questions on Gradescope, then ask your lab TA to check you off.
#### Question 1: Setup
1. Show the output of running `ssh -T git@github.com` on the lab machines.
2. What is your instructional account's disk quota (to the nearest GB)? Do files in your temporary directory count against your quota?
3. What text editor are you using?
4. Which instructional machine(s) should you use while completing the labs and the project?

#### Question 2: Common terminal tasks

For 1-6 below, submit the command/keystrokes needed to generate the desired result.  For 1-4, try generating only the desired result (no extraneous info). 

1. List the 5 most recently modified items in `/usr/bin`
2. What directory is `git` installed in?
3. Show the hidden files in your lab directory (the `lab1` folder in the repo you cloned from GitHub).
4. What version of Vim is installed? Describe how you figured this out.
5. (optional) Make a new directory called `backup` within `/home/tmp/<your-eecs-username>`. Copy all the files in this lab directory to the new `backup` directory and then delete all the copies in the new directory.
6. Run `ping www.google.com`, suspend it, then kill the process. Then run it in the background, report its PID, then kill the process.
7. Run `top` and report the average CPU load, the highest CPU job, and the amount of memory used (just report the results for this question; you don't need to supply the command/how you got it).

#### Question 3: Fun with Regular Expressions

For each regular expression, provide an answer for **both** **basic** and **extended** mode (`sed` and `sed -r`).

You are allowed to use multiple commands to perform each task. Operate on the `force_regs.ucli` file.

1. Change all x surrounding numbers to angle brackets. For example, `regx15xx79x` becomes `reg<15><79>`. Hint: remember to enable global subsitution.
2. *(optional)* Make every number in the file be exactly 3 digits with padded leading zeros (except the last 0 on each line). Eg. line 120/121 should read:

```
force -deposit rocketTestHarness.dut.Raven003Top_withoutPads.TileWrap.
... .io_tilelink_release_data.sync_w002r.rq002_wptr_regx000x.Q 0
force -deposit rocketTestHarness.dut.Raven003Top_withoutPads.TileWrap.
... .io_tilelink_release_data.fifomem.mem_regx015xx098x.Q 0
```
#### Question 4: Understanding File Permissions

For each task below, please provide the commands that result in the correct permissions being set. Make no assumptions about the file's existing permissions. Operate on the `runalways.sh` script.

1. Change the script to be executable by you and no one else.
2. Add permissions for everyone in your group to be able to execute the same script
3. Make the script writable by you ane everyone in your group, but unreadable by others
4. *(optional)* Change the owner of the file to be `eecs151` (Note: you will not be able to execute this command, so just provide the command itself)

#### Question 5: Makefile Targets

1. Add a new make rule that will create a file called `foo.txt`.  Make it also run the `output_name` rule.
2. Name at least two ways that you could have the makefile regenerate the `output_name` target after its rule has been run.

#### Question 6: Checking Git Understanding

Submit the **command** required to perform the following tasks:

1. How do you diff the Makefile versus its state as of the previous commit, if you have **not** staged the Makefile?
1. How do you diff the Makefile versus its state as of the previous commit, if you **have** staged the Makefile?
1. How do you make a new branch without switching to it?
1. How do you switch to a new branch?

## Appendix

### Cheatsheets
That was a lot of commands and a lot of new things to memorize (especially if you have not used them extensively in the past)! As a result, these are some cheatsheets that contains the key commands of some of the productivity tools we went through. *These are all the top results of searching "xx cheatsheet" in google, and are **not** created by the staff.*

* [Linux Commands](https://www.guru99.com/linux-commands-cheat-sheet.html)
* [Vim](https://vim.rtorr.com/)
* [Emacs](https://www.gnu.org/software/emacs/refcards/pdf/refcard.pdf)
* [Regex](https://cheatography.com/davechild/cheat-sheets/regular-expressions/)
* [Make](https://gist.github.com/rueycheng/42e355d1480fd7a33ee81c866c7fdf78)
* [Git](https://education.github.com/git-cheat-sheet-education.pdf)
* [Screen](https://gist.github.com/jctosta/af918e1618682638aa82)
* [Tmux](https://tmuxcheatsheet.com/)

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
- Erik Anderson, Roger Hsiao, Hansung Kim, Richard Yan (2022)
- Chengyi Zhang (2023)
- Rahul Kumar, Rohan Kumar (2023)
- Kevin Anderson, Kevin He (Sp2024)


