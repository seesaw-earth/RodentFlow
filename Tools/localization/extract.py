#!/usr/bin/env python3
"""Collect every translation key used by the app: SwiftUI literals, loc()/locf() literals,
component titles and indirect keys, plus extra keys for stored identifiers."""
import sys, re, json
import os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from check import run
def unescape(b):
    out=''; i=0
    while i<len(b):
        c=b[i]
        if c=='\\':
            n=b[i+1]
            if n=='n': out+='\n'; i+=2
            elif n=='t': out+='\t'; i+=2
            elif n=='"': out+='"'; i+=2
            elif n=="'": out+="'"; i+=2
            elif n=='\\': out+='\\'; i+=2
            elif n=='0': out+='\0'; i+=2
            elif n=='u':
                j=b.index('}',i); out+=chr(int(b[i+3:j],16)); i=j+1
            else: raise ValueError('escape '+b[i:i+4])
        else: out+=c; i+=1
    return out
EXTRA = {
 # parameter keys (ExperimentResult.parameters) shown with locKey()
 'params': ["analysis_duration_s","analysis_start_s","arm_length_cm","arm_width_cm","baseline_s","beam_width_mm","center_fraction","cs_duration_s",
   "duration_min","entry_min_s","freeze_min_bout_s","freeze_threshold_pct_body","hole_count","hole_zone_radius_cm","immobility_min_s","interaction_radius_cm",
   "light_fraction","max_trial_s","min_total_exploration_s","moving_threshold_cm_s","platform_radius_cm","platform_stay_s","protocol_offset_s","q_bic","q_nll",
   "reference_body_area_fraction","sucrose_concentration_pct","time_bin_s","wall_zone_cm",
   "center_zone","chambers","cs_onsets_s","error_rule","exploration_rule","light_side","model","motion_pixel_delta","novel_object","open_arms","paired_side",
   "reversals","strides_measured","tracking","trial_type","trials_averaged","unseen_samples","video"],
 'labels': ["arm_sequence","first_choice","hole_visits","search_strategy"],
 # context keys for words that need different translations in different places: loc(_:context:)
 'context': ["tab.experiment","tab.groups","source.trials","setup.importedAt"],
}
def collect(root):
    keys={}
    res=run(root)
    for f,L,cls,ctx in res:
        if cls not in ('LOC','SUI','COMP','IND'): continue
        if L['interp']: raise SystemExit(f"interpolated key at {f}:{L['line']}: {L['body']}")
        if L['multiline']: raise SystemExit(f"multiline key at {f}:{L['line']}")
        k=unescape(L['body'])
        keys.setdefault(k,[]).append(f"{f}:{L['line']}")
    for grp,v in EXTRA.items():
        for k in v: keys.setdefault(k,[]).append('extra:'+grp)
    return keys
if __name__=='__main__':
    keys=collect(sys.argv[1])
    json.dump(keys,open(sys.argv[2],'w'),ensure_ascii=False,indent=0,sort_keys=True)
    print(len(keys),'keys')
