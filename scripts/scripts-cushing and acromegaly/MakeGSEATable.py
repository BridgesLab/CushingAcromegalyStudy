import reader
import sys
import os.path

#This python script takes a gsea report file and collect all the GSEA names,
#size, nes, nom p-value, and fdr q-value that have q-value < 0.25.  Then, it
#will find all the files match with the selected GSEA names, open them, and
#collect all the gene names.  It then writes all these results to a text file

rootdir = sys.argv[1] #directory
#infile1 = sys.argv[2] #master file name1: the positive file
#infile2 = sys.argv[3] #master file name2: the negative file
outfile = sys.argv[2]   #out put file name

for root, subFolders, files in os.walk(rootdir):
   for filename in files:
      if filename.startswith("gsea_report_for_na_pos"):
         data = reader.Read(os.path.join(rootdir, filename), '\t')
      if filename.startswith("gsea_report_for_na_neg"):
         data2 = reader.Read(os.path.join(rootdir, filename), '\t') #negative report file

results = []
sub_results = []
#sub_file_name= ""
with open(outfile, 'w') as fout: #open output file to write
   fout.write("Name\tSize\tNES\tNOM p-value\tFDR q-value\tGene Details\n")
   for i in range(len(data)):
      sub_file_name= ""
      if data['FDR q-val'][i] < 0.25: #work on the positive report file
         #results.append( [data['NAME'][i], data['SIZE'][i], data['NES'][i], data['NOM p-val'][i], data['FDR q-val'][i]] )
         fout.write(str(data['NAME'][i])+'\t'+str(data['SIZE'][i])+'\t'+str(data['NES'][i])+'\t'+str(data['NOM p-val'][i])+'\t'+str(data['FDR q-val'][i])+'\t')
         sub_file_name=str(data['NAME'][i])+'.xls'
         for root, subFolders, files in os.walk(rootdir):
            for filename1 in files:
               if filename1==sub_file_name:
                  gene_list=""
                  sub_data=reader.Read(os.path.join(rootdir,filename1),'\t')
                  for j in range(len(sub_data)):
                    if sub_data['CORE ENRICHMENT'][j]=='Yes':
                        gene_list += str(sub_data['PROBE'][j])+','
                  gene_list = gene_list[:-1] #remove the last ','
                        #print gene_list
                  fout.write(gene_list)
         fout.write('\n')
   for i in range(len(data2)): #work on the negative report file
      sub_file_name2= ""
      if data2['FDR q-val'][i] < 0.25:
         fout.write(str(data2['NAME'][i])+'\t'+str(data2['SIZE'][i])+'\t'+str(data2['NES'][i])+'\t'+str(data2['NOM p-val'][i])+'\t'+str(data2['FDR q-val'][i])+'\t')
         sub_file_name2=str(data2['NAME'][i])+'.xls'
         for root, subFolders, files in os.walk(rootdir):
            for filename2 in files:
               if filename2==sub_file_name2:
                  gene_list=""
                  sub_data=reader.Read(os.path.join(rootdir,filename2),'\t')
                  for j in range(len(sub_data)):
                    if sub_data['CORE ENRICHMENT'][j]=='Yes':
                        gene_list += str(sub_data['PROBE'][j])+','
                  gene_list = gene_list[:-1] #remove the last ','
                        #print gene_list
                  fout.write(gene_list)
         fout.write('\n')

