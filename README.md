# asic-labs-sp24
Welcome to the repository for EECS 151/251A Spring 2024 ASIC labs! This repository will contain all the information you need to complete lab exercises. If you are just getting started make sure to see the [Setup](#Setup) section to create your environment.

## Lab Policies

1. Collaboration is encouraged, but all work must be individual
2. Use [queue](https://forms.gle/NHcuqonSwAQALuea7) for question, debugging help, concept review, etc
3. Do not run heavy workloads on servers
4. Check-offs must be done in person

## Lab Due Dates

All labs must be checked off **before** your next lab session. 

| Lab |    Due Date    |
|:---:|:--------------:|
|  1  | 1/29 (11:59pm) |
|  2  |                |
|  3  |                |
|  4  |                |
|  5  |                |

## Setup <a name="paragraph1"></a>

<details open>
  <summary>See Instructions</summary>

### Getting an Instructional Account

You are required to get an EECS instructional account to login to the workstations in the lab, since you will be doing all your work on these machines (whether you're working remotely or in-person). 

1. Visit WebAcct: http://inst.eecs.berkeley.edu/webacct.
2. Click "Login using your Berkeley CalNet ID"
3. Click on "Get a new account" in the *eecs151* row. 

Once the account has been created, you can email your class account form to yourself to have a record of your account information.  You can follow the instructions on the emailed form to change your Linux password with `ssh update.eecs.berkeley.edu` and following the prompts.


### Logging into the Classroom Servers

The servers used for this class are primarily `eda-[1-12].eecs.berkeley.edu`.  You may also use the `c111-[1-17].eecs.berkeley.edu` machines (which are physically located in Cory 111/117). You can access all of these machines remotely through SSH. 


#### SSH: 

**SSH is the preferred connection for ASIC labs because most work will be performed using the terminal and should be used unless a GUI is required**.  The SSH protocol also enables file transfer between your local and lab machines via the `sftp` and `scp` utilities. **WARNING: DO NOT transfer files related to CAD tools to your personal machine. Only  transfer files needed for your reports.**

How To:
<ul style="list-style: none;">
 <li>
<details>
<summary>Linux, BSD, MacOS</summary>
<br>

Access your workstation through SSH by running:

```shell
ssh eecs151-YYY@eda-X.eecs.berkeley.edu
```

In our examples, this would be:

```shell
ssh eecs151-abc@eda-8.eecs.berkeley.edu
```
</details>
</li>
 <li>
<details>
<summary>Windows</summary>
<br>
The classic and most lightweight way to use SSH on Windows is PuTTY (https://www.putty.org/). Download it and login with the FQDN above as the Host and your instructional account username. You can also use WinSCP (winscp.net) for file transfer over SSH.

Advanced users may wish to install Windows Subsystem for Linux (https://docs.microsoft.com/en-us/windows/wsl/install-win10, Windows 10 build 16215 or later) or Cygwin (cygwin.com) and use SSH, SFTP, and SCP through there.

</details>
</li>
</ul>


It is ***highly*** recommended to utilize one of the following SSH session management tools: `tmux` or `screen`. This would allow your remote terminal sessions to remain active even if your SSH session disconnects, intentionally or not. Below are tutorials for both:
* [Tmux Tutorial](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)
* [Screen Tutorial](https://www.rackaid.com/blog/linux-screen-tutorial-and-how-to/)


#### X2Go

For situations in which you need a graphical interface (waveform debugging, layout viewing, etc.) use X2Go. This is a faster and more reliable alternative to more traditional XForwarding over SSH. X2Go is also recommended because it connects to a persistent graphical desktop environment, which continues running even if your internet connection drops.

Download the X2Go client for your platform from the website: https://wiki.x2go.org/doku.php/download:start.

> **_NOTE:_**  MacOS sometimes blocks the X2Go download/install, if it does follow the directions here: https://support.apple.com/en-us/HT202491.

To use X2Go, you need to create a new session (look under the Session menu). Give the session any name, but set the "Host" field to the FQDN of your lab machine and the "Login" field to your instructional account username. For “Session type”, select “GNOME”. Here’s an example from macOS:

<p align="center">
<img src="./figs/x2gomacos.png" width="500" />
</p>


### Create Subdirectory for Work
Before you begin exercises, you need to create a directory for your work. Your `/home` directory has limited space, therefore you will create a personal subdirectory underneath `/home/tmp/<your-eecs-username>` for all development work (copy any important results to your home directory). 

Steps: 
1. Log into the EECS Instructional WebAccount (http://inst.eecs.berkeley.edu/webacct) with your CalNet ID. 
2. Click on "*More...*"
3. Select "*Make /home/tmp Directory*"

<p align="center">
<img src="./figs/make_home_tmp_dir.png" width="400" />
</p>

### Remote Access

It is important that you can remotely access the instructional servers. Remote into server using either SSH (Secure SHell) or X2Go. The range of accessible machines are `eda-[1-12]` and `c111-[1-17]`. The fully qualified DNS name (FQDN) is `eda-X.eecs.berkeley.edu` or `c111-X.eecs.berkeley.edu`. For example, if you select machine `eda-8`, the FQDN would be `eda-8.eecs.berkeley.edu`.

<!-- Next, note your instructional class acccount name - the one that looks like `eecs151-YYY`, for example `eecs151-abc`. This is the account you created at the start of this lab. -->

#### VPN
If you're not on campus connected to *eduroam*, you need to use a global protect VPN to get over the instructional machine's firewall. Follow this guide to install the VPN: https://software.berkeley.edu/bsecure-remote-access-vpn


> **_NOTE:_** You can use any lab machine, but our lab machines aren’t very powerful; if everyone uses the same one, everyone will find that their jobs perform poorly. ASIC design tools are resource intensive and will not run well when there are too many simultaneous users on these machines. We recommend that every time you want to log into a machine, examine its load on https://hivemind.eecs.berkeley.edu/ for the `eda-X` machines, or using `top` when you log in. If it is heavily loaded, consider using a different machine. If you also notice other `eecs151` users with jobs consuming excessive resources, do feel free to reach out to the GSIs about it.

</details>


## Clone this Repo

You are now ready to complete the lab exercises! In this course, we use GitHub Classroom to manage labs and the project. Click the link below to create a lab repo on your GitHub account.
<p align="center" style="font-size:1.5em">
<a href="https://classroom.github.com/a/5WvvqY9q" > Accept GitHub Classroom Invitation </a>
</p>

### SSH Keys
We will use SSH keys to authenticate with Github.
Run these commands when logged in on your `eecs151-xxx` account.

- Create a new SSH key:
```shell
ssh-keygen -t ed25519 -C "your_email@berkeley.edu"
```
Keep hitting enter to use the default settings.
You can set up a passphrase if you want, then you'll need to type it whenever you ssh using public key.

- Copy your public key:
```
cat ~/.ssh/id_ed25519.pub
```
Copy the text that's printed out.

- Add the key to your Github account. [Go here](https://github.com/settings/keys), click on "New SSH Key", paste your public key, and click "Add SSH key".

- Finally test your SSH connection
```shell
ssh -T git@github.com
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

Clone the repo to your work directory.

```shell
cd /home/tmp/<your-eecs-username>
git clone git@github.com:EECS151-sp24/asic-labs-sp24-(your GitHub user ID).git
```

This repository contains all lab materials including lab manuals (README.md) and all skeleton code in the *skel* subdirectories. 
