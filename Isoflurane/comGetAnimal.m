function animal = comGetAnimal(dtype, did, eid)

switch dtype
    case {"Angio", "Doppler"}
        did1 = split(did, "-");
        if did1(1) == "wt0"
            animal = "wt1";
        else
            animal = did1(1);
        end
        if contains(did, "old")
            animal = sprintf("%s-old", animal);
        end
        
    case "Mangio"
        did1 = split(did, "-");
        if did1(1) == "10x"
            animal = "wt1";
        else
            animal = did1(1);
        end
        if contains(eid, "old")
            animal = sprintf("%s-old", animal);
        end
        
    case "RBC"  % did = eid
        eid1 = split(eid, "_");
        if contains(eid1(2), "wt")
            animal = eid1(2);
        else
            animal = "wt1";
        end
        if contains(eid, "old")
            animal = sprintf("%s-old", animal);
        end
        
    otherwise
        error("unsupported dtype");
end