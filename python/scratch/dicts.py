import itertools

obj = {
    "some": 123,
    "fields": [0, 100, 200, 300],
    "here": ["hello", "there"]
}

def expand(some_obj):
    
    list_keys = [key for key in some_obj if isinstance(some_obj[key], list)]
    non_list_keys = [key for key in some_obj if not isinstance(some_obj[key], list)]
    
    base_obj = {key: some_obj[key] for key in non_list_keys}
    out_objs = []
    
    list_bounds = [list(range(len(some_obj[key]))) for key in list_keys]
    index_permutations = list(itertools.product(*list_bounds))
    
    for permutation in index_permutations:
        
        out_obj = base_obj.copy()
        for k, key in enumerate(list_keys):
            out_obj[list_keys[k]] = some_obj[key][permutation[k]]
            
        out_objs.append(out_obj)
            
    return out_objs

def main():
    expanded = expand(obj)
    
    print(obj)
    print("-----------------")
    for e in expanded:
        print(e)
    pass

if __name__=="__main__":
    main()
