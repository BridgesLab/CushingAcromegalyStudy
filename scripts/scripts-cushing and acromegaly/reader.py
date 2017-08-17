class Read:
   def __init__(self, filename, token):
      with open(filename, 'rU') as f:
         # remove all empty and comments (starting with #) in data
         self.lines = [ line.strip() for line in f.readlines() if line.strip() and (line.strip()[0] != '#')]

      self.keys = []
      self.data = {}

      if self.lines:
         self.keys = [ k.strip() for k in self.lines.pop(0).split(token) ]
         self.data = { k : [] for k in self.keys }

         for line in self.lines:
            values = [ v.strip() for v in line.split(token) ]
            if len(values) != len(self.keys):
               print "Missing values:",line
               return
            for i,v in enumerate(values):
               try:
                  v = float(v)
               except:
                  pass
               self.data[ self.keys[i] ].append( v )

   def __contains__(self, key):
      return key in self.data

   def __getitem__(self, key):
      if key in self.data:
         return self.data[key]
      return None

   def __len__(self):
      return len(self.lines)



#-----------------------------------------------------------------------------

if __name__ == '__main__':
   data = Read("customer.txt", "\t")
   print data.keys
   print data['COMPANY']
   print data['FIRSTNAME']
   print data['AGE']
