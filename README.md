AV AI is a PowerShell-based security utility that helps monitor running processes on a Windows system by creating a trusted baseline and actively responding to unknown or suspicious processes.
This tool is currently under development — contributions and feedback are welcome!

# 🔧 Features
## `buildBaseLine()`
This function observes all currently running processes and collects key properties:
- Name
- Company
- Path
- Description
These fields are combined into a Unique String Identifier that represents each process instance. The result is a baseline Approved Whitelist, which serves as your reference for known, trusted processes.

# 🛡️ Use this after boot or in a known-good environment to generate your trusted process list.

## `startMonitor()`
Once your whitelist is built, this function starts real-time process monitoring:
It continuously checks for new or spawned processes.
For every process, it creates the same Unique String.
If a process is not found in the Approved Whitelist:
It is suspended using PsSuspend from SysInternals.
The user is prompted to either resume or terminate the process.
⚠️ This adds an extra layer of manual review against potentially unwanted or unknown programs.

# 🚀 Getting Started
Clone or download the repository.
Run PowerShell as Administrator.
Start with buildBaseLine to generate your whitelist.
Use startMonitor to begin monitoring with active enforcement.
Make sure PsSuspend.exe is available in your system path or alongside the script.

# 📦 Requirements
Windows PowerShell (tested on 5.1+)
SysInternals PsSuspend
Administrator privileges for suspension and interrogation of processes

# To-Do
I will be working on it on the side.
- Add sound notification when process is suspended
- Add the capabilities to monitor suspicious parent and child process
- Convert the code to C++ or .NET for some nice GUI
- Find a better solution to build the secureString, I think there is a better way to keep track of them
- Add some type of Machine Learning to the data been capture so it can crunch and make better decisions

# 🔐 Disclaimer
This tool interacts with low-level process management and may affect system stability if misused. Use responsibly and at your own risk.
