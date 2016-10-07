"""
command-processor.py

Generate the coffeescript arrays of geant4 commands
"""
import json


def read_command_file():
    f = open("G4command.txt", "r")
    d = dict()
    inGuidance = False
    current_command = ""
    for line in f.readlines():
        # clean line
        line = line.replace(r"//", "")
        line = line[:-1]
        if line[:24] == r"Command directory path :":
            inGuidance = False
            current_command = ""
        if line[:9] == r"Command /":
            print(line)
            inGuidance = False
            command = line[9:]
            current_command = command
            d[command] = {"guidance": "", "params": []}
            param_idx = -1
        elif line[:10] == "Guidance :" and current_command != "":
            inGuidance = True
        elif line[:11] == "Parameter :":
            inGuidance = False
            d[current_command]["params"].append({"name": line[12:]})
            param_idx += 1
        elif line[:17] == "Parameter type  :":
            d[current_command]["params"][param_idx]["type"] = line[18:]
            inGuidance = False
        elif line[:17] == "Omittable       :":
            d[current_command]["params"][param_idx]["omit"] = line[18:]
            inGuidance = False
        elif line[:17] == "Default value   :":
            d[current_command]["params"][param_idx]["default"] = line[18:]
            inGuidance = False
        else:
            if inGuidance is True:
                if d[current_command]["guidance"] == "":
                    d[current_command]["guidance"] += line
                else:
                    d[current_command]["guidance"] += "\n" + line
    f.close()
    return d


def recurse_dictionary(d):
    out = dict()
    for (k, v) in d.items():
        splitkey = k.split(r"/")
        if len(splitkey) > 1:
            key_prefix = "/".join(splitkey[:(len(splitkey) - 1)])
            key_suffix = splitkey[len(splitkey) - 1]
            if key_prefix in out:
                if key_suffix in out[key_prefix]:
                    out[key_prefix][key_suffix].update(v)
                else:
                    out[key_prefix][key_suffix] = v
            else:
                out[key_prefix] = {}
                out[key_prefix][key_suffix] = v
        else:
            if k in out:
                out[k].update(v)
            else:
                out[k] = v

    return out


def to_json():
    outfile = open("completions.json", "w")
    a = read_command_file()
    while True in [(r"/" in key) for key in a.keys()]:
        a = recurse_dictionary(a)
    outfile.write(json.dumps(a, sort_keys=True, indent=4))
    outfile.close()
    return None


if __name__ == "__main__":
    to_json()
