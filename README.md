# EWLog is a cross-platform logging program for the radio amateur. SQLite database. 
The program interface was maximally made in the likeness of UR5EQF_Log

![ImageEWLog](https://ewlog.app/images/ewlog.png)

---------------
Main features of EWLog:
  1. Logging
  2. Maintaining additional logs
  3. Import / Export ADI file
  4. Export eQSLcc / HRDLog / Clublog / QRZ.COM / HAMQTH / Cloudlog
  5. Import LOTW / eQSLcc
  6. DX Cluster
  7. Working with external programs (WSJT-X / JTDX / Fldigi)
  8. Working with the transceiver via hamlib
  9. Filling in data from QRZ.COM / QRZ.RU / HAMQTH XML API
  10. Work in Windows and Linux and MacOS

# Build
---------------
To build the program you will need:
  1. Lazarus 4.0
  2. FPC 3.2.2
  
Additional components:
  1. Indy10
  2. LazMapViewer
  3. Synapse 40.1
  4. UniqueInstance
  5. VirtualTreeView V5
  
All of these components are available in the Lazarus Network Component Repository.

  6. sywebsocket https://github.com/seryal/sywebsocket
  
# Tested in:
---------------
  1. Fedora Workstation 42
  2. Fedora KDE Plasma 42
  3. openSUSE Tumbleweed KDE
  4. openSUSE Leap 15.6 KDE
  5. openSUSE Tumbleweed Gnome
  6. openSUSE Leap 15.6 Gnome
  7. Ubuntu 24.04.2 LTS Gnome
  8. Ubuntu 25.04 Gnome