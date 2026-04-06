# Lecture 2 Preparation

## Objective

The objective of this preparation is to set up a virtual machine (VM) environment for Windows 7 Auditor, which will be used for software and database security analysis in the upcoming lectures. This VM will allow you to practice various security techniques and tools in a controlled environment.

## Instructions

1. Download the custom VM: Win7_Auditor_v2.2_2025_auditor.ova
2. Download VMWare Workstation Pro: VMware-Workstation-Full-25H2-24995812.exe

## Mac M Series users

If you have a MAC with M CPU, here are instructions to run it on UTM:
Windows 7 instructions for Mac M1/M2/M3/M4:

- UTM is based on QEmu
- UTM does emulate Win7 required instructions (intel x86) on Mac M1/M2
- install UTM + QEmu
- rename the Win7 .ova file to .zip, extract it
- command line: use qemu-img to convert the .vmdk to qcow2 (qemu hard disk format): qemu-img convert -f vmdk -O qcow2 image.vmdk image.qcow2
- on UTM, create a new VM for Windows 7 using the "Add new VM" feature
    - Emulate
	- Other
	- Skip ISO boot
	- CPU core 4
	- Hard disk default
	- shared folder default
	- name the VM to Auditor VM
- on UTM, go to settings, then QEMU, then disable UEFI
- on UTM, go to settings, then:
	- edit the HDD devices list, delete actual hdds from the list, and add the newly created qcow2
	- add a new IDE device, tick "Removable device", then "Create"
- Start the VM, On the toolbar click the CD icon and select "Install Windows Guest Tools…", then install them from the CD ROM in Computer.