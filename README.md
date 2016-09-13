# language-geant4-macro package

Syntax highlighting and autocompletion for Geant4 macros.

![Geant4 macro syntax highlighting and autocompletion](https://cloud.githubusercontent.com/assets/2887977/13725234/e78cd464-e89b-11e5-8aea-eb46264e2a2d.gif)

How to get it:

```
apm install language-geant4-macro
```

Geant4 is licensed under the
[Geant4 software license](http://geant4.web.cern.ch/geant4/license/LICENSE.html).
This is an unofficial user project.

*Customising the command list*

To rebuild the command dictionary, you can replace G4command.txt with your own
file made by dumping all the Geant4 UI commands within the scope, which you do by
running this command:

```
/control/manual /
```

Then, run (in the package directory):

```
python process_commands.py
```

This will replace the completions.json file with the commands particular to
the G4UI commands within G4command.txt file
