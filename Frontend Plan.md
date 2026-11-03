**Orchestrator Model** will be selected as ***GPT-5.6-Sol-xHigh***
## Scan Modal

The Scan Modal is a simple tool without any highly involved requirements.
When a user has a row selected and clicks the "Scan" button, a new modal appears on the screen. 
### Scan Modal Requirements
- Displays:
	- **Path** the folder will be created under with a button to copy to clipboard.
	- **Text input** for the folder name, pre-populated with the roll name.
	- **Text input** for notes from the scanner.
	- **Button** to "Start Scanning". When clicked, this will send a command to the server to create the roll folder. **Contract to be determined by the backend team**.
	- **Same Button** then switches to "Finish Scanning", which sends a command to the server to notify it of the change. **Contract to be determined by the backend team**.
The server will embed `isScanning` as a column value for that row with the value set to true whenever start scanning was clicked. This way if a user closes that modal and re-opens it later, it can still show "Finish Scanning". This column is not necessarily meant to be visible or not visible, but generally won't be since users won't know to request it, but the value will always come across with the row itself. When that value is true we can show the Finish button, false shows Start.

## Processing Panel 

The Processing Modal is a direct port of the Formatic .NET terminal application.
#### Before Proceeding
Task a ***GPT-5.6-Luna-High*** to read through the following two artifacts. The goal is to do all the grep, searching, and linking together of files needed to provide a full list of all the source code and configs. Build a file tree of the source and paths to all of the files in it, excluding packages, build scripts and temp folders, and docs.
**Artifact 1**: An unwired demo showcase for a web port of the Formatic terminal can be found on the following commit: 
(**TODO**: Insert formatic-web commit hash)
**Artifact 2**: The original Formatic terminal source code can be found here: 
(**TODO**: Insert local path to Formatic terminal)

Afterward, take the reports from **Luna** and pass them to ***GPT-5.6-Terra-High***. 

**Artifact 1:** Have it fully analyze the Formatic terminal codebase and document the entire feature set, describing each functionality the system has. It should detail exactly how those features make changes to config files, and ignoring all of the Console rendering code cluttering it up. It needs to scope out the domain fully.
**Artifact 2:** Then it should also investigate the web port of Formatic terminal as provided by ***Luna*** to see how the original rough drafts looked as a source of inspiration and to look for differences.

Ultimately, ***Terra*** should produce a final report for you. Take that report and verify/validate the claims in it, with a critical eye. Your goal is to produce a final plan for how to design these pages into the new formatic site on our current commit. We recently redesigned it to be table-centric, with the other pages dropped.

With all of this in mind, the Processing system is going to be more complicated to design.
### Processing Panel Design

The Processing Panel slides out from the right side of the screen when the user clicks the **Process** button, next to the **Scan** button.

### Processing Panel Requirements
Once you are ready, task a ***GPT-5.6-Sol-Medium*** with filling out this section.



---

# QuantumProcess Analysis

Goal 1: 
