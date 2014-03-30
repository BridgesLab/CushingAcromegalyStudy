import reader
import sys
import os.path

#This python script takes a gsea report file and collect all the GSEA names,
#size, nes, nom p-value, and fdr q-value that have q-value < 0.25.  Then, it
#will find all the files match with the selected GSEA names, open them, and
#collect all the gene names.  It then writes all these results to a text file

rootdir = sys.argv[1] #directory
filename = sys.argv[2] #master file name
outfile = sys.argv[3]   #out put file name
data = reader.Read(os.path.join(sys.argv[1], sys.argv[2]), '\t')

results = []
sub_results = []
#sub_file_name= ""
with open(outfile, 'w') as fout:
	fout.write("Name\tSize\tNES\tNOM p-value\tFDR q-value\tGene Details\n")
	for i in range(len(data)):
		sub_file_name= ""
		if data['FDR q-val'][i] < 0.25:
			#results.append( [data['NAME'][i], data['SIZE'][i], data['NES'][i], data['NOM p-val'][i], data['FDR q-val'][i]] )
			fout.write(str(data['NAME'][i])+'\t'+str(data['SIZE'][i])+'\t'+str(data['NES'][i])+'\t'+str(data['NOM p-val'][i])+'\t'+str(data['FDR q-val'][i])+'\t')
			sub_file_name=str(data['NAME'][i])+'.xls'
    		for root, subFolders, files in os.walk(rootdir):
      			for filename in files:
      				if filename==sub_file_name:
      					sub_data=reader.Read(os.path.join(sys.argv[1],filename),'\t')
      					gene_list =','.join(sub_data['PROBE'])
      					#print gene_list
      					fout.write(gene_list)
      		fout.write('\n')

