"""
command-processor.py

Generate the coffeescript arrays of geant4 commands
"""
import json

# class NestedDict(dict):
#     def __init__(self, *args):
#         super(NestedDict, self).__init__(args)
#
#     def __getitem__(self, idx_list):
#         obj = self
#         for idx in idx_list:
#             obj = obj.__getitem__(idx)
#         return obj
#
#     def __setitem__(self, idx_list, value):
#         self


def read_command_file():
    f = open("G4command.txt", "r")
    d = dict()
    inGuidance = False
    current_command = ""
    for line in f.readlines():
        # clean line
        line = line.replace(r"//", "")
        line = line[:-1]
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
                d[current_command]["guidance"] += line
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
                out[key_prefix][key_suffix] = v
            else:
                out[key_prefix] = {}
                out[key_prefix][key_suffix] = v
        else:
            out[k] = v

    return out


def to_json():
    outfile = open("completions.json", "w")
    a = read_command_file()
    oldlen = 0
    while oldlen != len(a):
        oldlen = len(a)
        a = recurse_dictionary(a)
    outfile.write(json.dumps(a, sort_keys=True, indent=4))
    outfile.close()
    return None
