from Bio import SeqIO
import pandas as pd
import sys
import copy
import ast


#select_feat = ["T7 promoter", "lac operator"]
#path = "/home/schagas/MiVector/renv/library/R-4.1/x86_64-pc-linux-gnu/plasmapR/data/petm20.gb"


class get_gbkfeatures():

    
    def __init__(self,filepath):
        self.final_data = []
        self.gbkfile = [i for i in SeqIO.parse(filepath,"genbank")][0]
        
    def check_feature(self,feature,rm_feat):
      try:
            if feature.qualifiers["label"][0] in rm_feat:
                return True
              
      except:
            return False

    
    def edit_gbk(self, rm_feat):
      
      new_gbkfile = copy.deepcopy(self.gbkfile)
     
      
      for feat in new_gbkfile.features:
        quali_keys = list(feat.qualifiers.items())
        for k, v in quali_keys:
          if v[0] in rm_feat:
            #feat.qualifiers[""] = feat.qualifiers.pop("label")[0]
            del feat.qualifiers[k]
      
      with open("Data/newgbk.gb", "w") as f:
        SeqIO.write(new_gbkfile, f, "genbank")
        
      with open("Data/newgbk.gb", "r") as f:
        lines = f.readlines()
        
        for line in range(len(lines)):
          
            if "/label=" in lines[line]:
              print(lines[line])
              lines[line] = lines[line].replace('"','')
              
      with open("Data/newgbk.gb", 'w') as f:
        f.writelines(lines)
          
     
        #try:
         #   if feature.qualifiers["label"][0] in rm_feat:
        #        return True
        #if k in:
        #mydict[k] = ''
    
      #features = [feature for feature in [feature for feature in self.gbkfile.features if not self.check_feature(feature,rm_feat)]]
      #new_gbkfile = copy.deepcopy(self.gbkfile)
      
      #new_gbkfile.features = features
      #print(new_gbkfile)
      #print(self.gbkfile.features[0])
      #SeqIO.write(new_gbkfile, "newplasmid.gb", 'genbank')
        
      #return(new_gbkfile)

    def sortInfo(self):

        
        for locat in self.gbkfile.features:

            if "label" in locat.qualifiers.keys():
                try:
                    self.final_data.append({
                        "label": str(locat.qualifiers["label"][0]),
                        "loc": str(locat.location)
                        })
                except:
                    self.final_data.append({
                        "label": str("-"),
                        "loc": str(locat.location)
                        })
                        
        data = pd.DataFrame(self.final_data)
        return(data)
