import imslib
import os.path
import sys
import time

import tkinter as tk
from tkinter import filedialog

from ims_scan import iMSScanner
from imslib import FileSystemManager, FileSystemTableViewer

print("Test 13: File System Operations")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available system
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

fsm = FileSystemManager(ims)
fstv = FileSystemTableViewer(ims)

#############################
# Write a File / String / List
#############################
def WriteFile(filename):
    try:
        f = open(filename, "rb")
    except FileNotFoundError:
        print('error')
    else:
        with f:
            writer = imslib.UserFileWriter(ims, f, "file.bin")
            writer.Program()

def WriteString(s):
    if isinstance(s, str):
        writer = imslib.UserFileWriter(ims, s.encode(encoding="utf-8"), "str.bin")
        writer.Program()
        return True
    else:
        return False
 
def WriteList(l):
    if isinstance(l, list):
        writer = imslib.UserFileWriter(ims, l, "list.bin")
        writer.Program()
        return True
    else:
        return False    

#############################
# Read File
#############################
def ReadToFile(filename, s):
    reader = imslib.UserFileReader(ims, s)
    with open(filename, "wb") as f:
        if reader.Readback(f):
            print("Wrote file successfully")
        else:
            print("Readback failed")

def ReadToString(s):
    r = imslib.UserFileReader(ims, s)
    data = r.Readback()
    if data is not None:
        print("Read back", len(data), " bytes:")
        print(data.decode("utf-8"))

def ReadToList(s):
    r = imslib.UserFileReader(ims, s)
    data_list = [b for b in r.Readback()]
    if data_list is not None:
        print("Read back", len(data_list), " values:")
        print(data_list)

#############################
# Display FileSystem Menu
#############################

def display_menu():
    print()
    print("File System Menu ")
    print("    (1) -> Write a File")
    print("    (2) -> Write a String")
    print("    (3) -> Write a List")
    print("    (4) -> Read a File")
    print("    (5) -> Set Default Flag")
    print("    (6) -> Clear Default Flag")
    print("    (7) -> Delete File")
    print("    (8) -> Execute File")
    print("    (q) -> Quit")
    print()


while True:
    if fstv.IsValid:
        for fste in fstv:
            print(fste)
    else:
        print("No File System found in connected iMS")

    display_menu()
    choice = input("Select an option or 'q' to quit: ").strip().lower()
    if choice == 'q':
        break
    elif choice == '1':
        # open-file dialog
        root = tk.Tk()
        filename = tk.filedialog.askopenfilename(
            title='Select a file...',
        )
        root.destroy()
        WriteFile(filename)
    elif choice == '2':
        #write a string
        s = input("Enter a string to write: ").strip()
        WriteString(s)
    elif choice == '3':
        print("Type a space-seperated list of numbers to write: ")
        a = [int(x) for x in input().split()]
        WriteList(a)
    elif choice == '4':
        try:
            val = int(input("Read which file index? "))
            fileIdx = val
        except ValueError:
            print("Invalid value.")
        if fileIdx < len(fstv):
            name = fstv[fileIdx].Name
            if name == "file.bin":
                # save-as dialog
                root = tk.Tk()
                filename = tk.filedialog.asksaveasfilename(
                    title='Save as...',
                )
                root.destroy()
                ReadToFile(filename, name)
            elif name == "str.bin":
                ReadToString(name)
            elif name == "list.bin":
                ReadToList(name)
    elif choice == '5':
        try:
            val = int(input("Set Default on which file index? "))
            fileIdx = val
        except ValueError:
            print("Invalid value.")
        fsm.SetDefault(fileIdx)
    elif choice == '6':
        try:
            val = int(input("Clear Default on which file index? "))
            fileIdx = val
        except ValueError:
            print("Invalid value.")
        fsm.ClearDefault(fileIdx)
    elif choice == '7':
        try:
            val = int(input("Delete which file index? "))
            fileIdx = val
        except ValueError:
            print("Invalid value.")
        fsm.Delete(fileIdx)
    elif choice == '8':
        try:
            val = int(input("Execute which file index? "))
            fileIdx = val
        except ValueError:
            print("Invalid value.")
        fsm.Execute(fileIdx)

ims.Disconnect()